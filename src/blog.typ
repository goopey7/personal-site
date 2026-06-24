#import "../templates/base.typ": conf

#show: conf.with(
  page-title: "blog",
  description: "where all my memories lie",
)

#let files = json("../files.json")

#let format-date(d) = {
  if d == "" { return "" }
  let inner = d.replace("datetime(", "").replace(")", "")
  let parts = inner.split(", ")
  let months = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
  let y = parts.at(0).split(": ").at(1)
  let m = months.at(int(parts.at(1).split(": ").at(1)) - 1)
  let day = parts.at(2).split(": ").at(1)
  m + " " + day + ", " + y
}

#let date-sort-key(d) = {
  if d == "" { return "0000-00-00" }
  let inner = d.replace("datetime(", "").replace(")", "")
  let parts = inner.split(", ")
  let y = parts.at(0).split(": ").at(1)
  let m = parts.at(1).split(": ").at(1)
  let day = parts.at(2).split(": ").at(1)
  if m.len() < 2 { m = "0" + m }
  if day.len() < 2 { day = "0" + day }
  y + "-" + m + "-" + day
}

#let posts = ()
#for (path, queried) in files.pairs() {
  if queried.len() > 0 and path.contains("/blog/") {
    let page = queried.at(0).at("value")
    let post-path = (path.split("/blog/").at(-1).replace(regex("\\.typ$"), "/"))
    posts.push((path: post-path, page: page))
  }
}
#let sorted = posts.sorted(key: p => date-sort-key(p.page.at("date", default: "")))

#let n = sorted.len()
#for i in range(n) {
  let post = sorted.at(n - 1 - i)
  let page = post.page
  html.p[
    #html.a(href: post.path)[#page.at("page-title")]
    #if page.at("date", default: "") != "" [
      #html.span(class: "date")[
        #format-date(page.at("date"))
      ]
    ]
    #if page.at("description", default: "") != "" [
      \
      #page.at("description")
    ]
  ]
}

#html.p(class: "rss-link")[
  #html.a(href: "/feed.xml")[rss feed]
]
