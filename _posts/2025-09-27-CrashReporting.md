---
layout: post
title: "UE5 Crash Reporting: Episode 1"
date: 2025-09-27
thumbnail: /assets/thumbs/CrashReportThumb.png
description: "Crash reporting without spending a dime"
---

We ran into crashes all the time while playtesting our game over the past couple years.
If it was a crash while playing in editor, the tester/designer would call for a programmer to look at the callstack in the crash window before it disappears!
And maybe copy/paste or send a screenshot. For packaged builds of our game, we'd just get a dialogue popup that says "Fatal Error!" with no additional information.
In that case we ask what they were doing just as crash happened because that's all we have to go off of.

It'd be really sick if instead, whenever the game crashes, callstacks and crash dumps are automatically collected and sent out.

# Unreal's Crash Reporter
Unreal has [some docs on Crash Reporting](https://dev.epicgames.com/documentation/en-us/unreal-engine/crash-reporting-in-unreal-engine).
Unreal has a crash reporter client available in the engine, but does not provide a server. Instead it recommends external services which cost money.

At a glance, all of these services look great, but we're skint. We have time, but we don't have money.
The server shouldn't have to do much anyways, we just need the crash data to be accessible. We don't need a fancy UI platform thing.

Since Unreal's source is available, we can observe and tweak the crash reporter client as needed.
We can also observe the http requests sent out from the client to see what we get out the box.

## Setup the Crash Report Client
To configure the crash report client I added the following to my project's `Config/DefaultEngine.ini`:
```ini
[CrashReportClient]
bAgreeToCrashUpload=false
bSendUnattendedBugReports=false
CompanyName="Triple 7 Studios"
DataRouterUrl="http://localhost:8080"
UserCommentSizeLimit=4000
bAllowToBeContacted=true
bSendLogFile=true
```

Then to package the crash report client with the game we have to add the following to `Config/DefaultGame.ini`:
```ini
[/Script/UnrealEd.ProjectPackagingSettings]
IncludeCrashReporter=True
```

Now let's write a crash that we can easily reproduce.
I bound the following code to the 'C' key:
```cpp
int* p = nullptr;
*p = 42;
```

### Mistakes were made
Do not use the project launcher to test this out! It doesn't package the crash reporter binaries!
Instead use the package project button hidden away here:

<img src="../../../assets/PackageProject.png" alt="Package Project" width="500"/>

## What happens out of the box?
Now instead of crashing with an ominous fatal error box, we get this:

<img src="../../../assets/CrashReporterWindow.png" alt="Crash Reporter Window" width="800"/>

I've got a source engine build here. The development engine build I'm planning to make available to the team (via my cool binary delta patcher, stay tuned) won't have symbols,
so it'll be interesting to see how the callstack log changes.

I've spun up an http server which will echo all http requests. Let's see what happens when we click "Send and close":

```
Received request:
==================
POST /?AppID=CrashReporter&AppVersion=5.6.1-0%2BUE5&AppEnvironment=Release&UploadType=crashreports&UserID=fb1395264275145b52c8cca3e0fd2fcd%7C%7C6536aa78-2595-4e2a-b190-86ad21120ab8 HTTP/1.1
Host: localhost:8080
Accept: */*
Accept-Encoding: deflate, gzip
Content-Type: application/octet-stream
User-Agent: CrashReportClient/UE5-CL-0 (http-eventloop) Windows/10.0.26100.1.256.64bit
Content-Length: 80199
```

We've received one single request! I've omitted the data here since it's binary. Looks like all the data is sent in a gzip format. So let's see if we can extract it!

Nope! The data doesn't have a gzip header.
So I fed the first few bytes to chatgpt and it correctly identified it as a zlib header. So despite the Accept-Encoding saying gzip, it's actually compressed using zlib!

What I get out of zlib appears to be a proprietary unreal format which stiches together all the files.
From nosing around in neovim I've found the following embedded in this proprietary file:

- CrashContext.runtime-xml
    - Error message (in our case EXCEPTION_ACCESS_VIOLATION)
    - IsAssert, IsStall, IsEnsure
    - Callstacks of every thread
    - Hardware info
    - Engine version
    - Build Configuration
- CrashReportClient.ini
    - All the settings used for the crash report client
- GoodTiming.log
    - Since I had bSendLogFile set to true in the crash report client settings. We got the entire log!
- UEMinidump.dmp
    - A crash dump we can open in visual studio. Will have to try this out to see what we can get out of it!
    - Fingers crossed this'll save us a load of headache!
