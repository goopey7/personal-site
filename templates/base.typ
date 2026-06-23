#let conf(
  page-title: "",
  description: "",
  date: "",
  giscus: false,
  doc,
) = {
  set document(title: page-title)

  html.link(rel: "stylesheet", href: "/style.css")

  [#metadata(
    (
      "page-title": page-title,
      "description": description,
      "date": date,
    )
  ) <data>]

  html.nav[
    #html.a(href: "/")[home]
    #html.a(href: "/blog/")[blog]
  ]

  html.header[
    #html.h1(page-title)
  ]

  html.main[
    #doc
  ]

  if giscus [
    #html.elem("script", attrs: (
      src: "https://giscus.app/client.js",
      data-repo: "goopey7/personal-site",
      data-repo-id: "R_kgDOH9XFbw",
      data-category: "Announcements",
      data-category-id: "DIC_kwDOH9XFb84CvHG_",
      data-mapping: "title",
      data-strict: "0",
      data-reactions-enabled: "1",
      data-emit-metadata: "0",
      data-input-position: "bottom",
      data-theme: "dark",
      data-lang: "en",
      data-loading: "lazy",
      crossorigin: "anonymous",
      async: "",
    ))
  ]
}
