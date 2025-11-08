---
layout: post
title: "UE5 Crash Reporting: Episode 3"
date: 2025-11-10
thumbnail: /assets/thumbs/CrashReportThumb.png
description: "Making my own crash reporting server"
---

This is the easy part. I went with rust for our crash report server. I used axum for the webserver and askama for generating the html for the UI.
The server runs two services on two different ports. One is just the endpoint to receive POST requests from the crash report client, and the other
is to serve the Web UI which we protect with cloudflare and OIDC.

Here is the function that handles incoming crash reports.
Slices in rust are awesome and you can see heavy use of them here as we parse out the bytes from the request.

We also send a discord webhook notification to our server!
<img src="../../../assets/CrashReportDiscord.png" alt="Crash Report Discord" width="1000"/>

```rust
async fn handle_crash_report(
    State(path): State<PathBuf>,
    Query(_params): Query<CrashReportParams>,
    _headers: HeaderMap,
    body: Bytes,
) -> impl IntoResponse {
    let content = match decompress_data(&body) {
        Ok(content) => content,
        Err(e) => {
            error!("Failed to decompress request body with zlib: {e}");
            return StatusCode::BAD_REQUEST;
        }
    };

    let mut bytes_read = 0;
    if &content[0..3] != b"CR1" {
        error!("Malformed crash report file header! {:?}", &content[0..3]);
        return StatusCode::BAD_REQUEST;
    }
    bytes_read += 3;

    let crash_id = match read_string(&content[bytes_read..], &mut bytes_read) {
        Ok(crash_id_str) => crash_id_str,
        Err(e) => {
            error!("{}", e);
            return StatusCode::BAD_REQUEST;
        }
    };
    info!("Received Crash Report: {}", crash_id);

    bytes_read += advance_to_next_item(&content[bytes_read..]);
    let _crash_filename = match read_string(&content[bytes_read..], &mut bytes_read) {
        Ok(crash_filename_str) => crash_filename_str,
        Err(e) => {
            error!("{}", e);
            return StatusCode::BAD_REQUEST;
        }
    };

    bytes_read += advance_to_next_item(&content[bytes_read..]);
    let file_size = u32::from_le_bytes(content[bytes_read..bytes_read + 4].try_into().unwrap());
    bytes_read += 4;
    if file_size as usize != content.len() {
        error!("File size specified in file is different from size of data extracted!");
        return StatusCode::BAD_REQUEST;
    }

    let number_of_files = content[bytes_read];
    bytes_read += 1;

    bytes_read += advance_to_next_item(&content[bytes_read..]);
    let files = match extract_files(&content[bytes_read..], &mut bytes_read, number_of_files) {
        Ok(files) => files,
        Err(e) => {
            error!("{}", e);
            return StatusCode::BAD_REQUEST;
        }
    };

    let crash_context_file = match files
        .iter()
        .find(|file| file.name == "CrashContext.runtime-xml")
    {
        Some(crash_context_file) => crash_context_file,
        None => {
            error!("CrashContext.runtime-xml not found!");
            return StatusCode::BAD_REQUEST;
        }
    };

    let crash_context_xml = str::from_utf8(crash_context_file.contents).unwrap();
    let crash_overview = CrashOverview::parse(crash_context_xml, &files);
    info!("{}", crash_overview.error);

    let timestamp = Utc::now().format("%Y-%m-%d_%H%M%S").to_string();
    let path = Path::new(&path).join(&timestamp).join("CrashData.zlib");
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent).unwrap();
    }
    let mut file = fs::File::create(&path).unwrap();
    file.write_all(&body as &[u8]).unwrap();

    let mut json_file =
        fs::File::create(&path.parent().unwrap().join("CrashOverview.json")).unwrap();
    let json_content = serde_json::to_string_pretty(&crash_overview).unwrap();
    json_file.write_all(&json_content.as_bytes()).unwrap();

    let url = match std::env::var("CRASH_REPORT_DISCORD") {
        Ok(url) => url,
        Err(_) => return StatusCode::OK,
    };
    let client = WebhookClient::new(&url);
    let base_url = match std::env::var("CRASH_REPORT_BASE_URL") {
        Ok(url) => url,
        Err(_) => return StatusCode::OK,
    };
    client
        .send(|message| {
            message
                .username("Crash Report")
                .embed(|embed| {
                    embed
                        .title("Crash!")
                        .description(&format!("{}#{}", base_url, timestamp))
                        .field(
                            "User Description",
                            &format!("{}", crash_overview.user_description),
                            false,
                        )
                        .field("Error", &format!("{}", crash_overview.error), false)
                })
        })
        .await
        .unwrap();

    StatusCode::OK
}
```

# Generating HTML for the UI

I shamelessly used an LLM to generate the CSS and add the modal that pops up when you click on a crash. But using askama to generate html from rust was so
easy.

To list out the crash reports in HTML I just had to do this:
{% raw %}
```html
<h1>Crash Reports</h1>

{% if crashes.is_empty() %}
    <div class="no-crashes">No Crashes Found</div>
{% else %}
    <div class="summary">
        Total Crashes: <strong>{{ crashes.len() }}</strong>
    </div>

    <div class="search-container">
        <input id="search" class="search-input" type="text" placeholder="Search by timestamp, error, or user description..." oninput="filterCrashes()">
    </div>

    <div class="crash-list">
        {% for crash in crashes %}
            <div class="crash-row" 
                 data-timestamp="{{ crash.timestamp | lower }}" 
                 data-error="{{ crash.overview.error | lower }}"
                 data-user-description="{{ crash.overview.user_description | lower }}"
                 onclick="openModal('{{ crash.timestamp }}')">
                <div class="timestamp">{{ crash.timestamp }}</div>
                <div class="error-preview">{{ crash.overview.error }}</div>
            </div>
```
The stuff inside {% %} is for askama which generates the HTML on the fly with the `.render()` method at the end of the following snippet:
{% endraw %}
```rust
#[derive(Template)]
#[template(path = "crash_list.html")]
struct CrashListTemplate {
    crashes: Vec<Crash>,
}

async fn handle_list(State(path): State<PathBuf>) -> impl IntoResponse {
    let mut crashes = Vec::new();

    for entry in fs::read_dir(&path).unwrap() {
        let entry = entry.unwrap();
        let path = entry.path();
        let timestamp = path
            .file_name()
            .unwrap()
            .to_os_string()
            .to_str()
            .unwrap()
            .to_string();
        let json_file = fs::read(path.join("CrashOverview.json")).unwrap();
        let json_str = str::from_utf8(&json_file).unwrap();
        let overview = serde_json::from_str::<CrashOverview>(json_str).unwrap();
        crashes.push(Crash {
            timestamp,
            overview,
        });
    }

    let crash_template = CrashListTemplate { crashes };
    (StatusCode::OK, Html(crash_template.render().unwrap())).into_response()
}
```

With a bit of CSS magic we can get a site that looks like this
<img src="../../../assets/CrashReportUIList.png" alt="Crash Report UI" width="1000"/>
<img src="../../../assets/CrashReportUI.png" alt="Crash Report UI" width="1000"/>

The code is not open source yet. Still need to decide if I release it through 777 studios or just personally.
Feel free to leave a comment if you want the code open sourced and I'll do my best to expedite it!
