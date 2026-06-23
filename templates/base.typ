#let conf(
  page-title: "",
  description: "",
  date: "",
  doc,
) = {
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
}
