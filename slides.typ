#import "@preview/fletcher:0.3.0" as fletcher: node, edge
#import "@preview/pinit:0.1.3": *
#import "@preview/sourcerer:0.2.1": code
#import "@preview/xarrow:0.3.0": xarrow
#import "lib/index.typ": *

#show: conf

// 1
#title-slide(title: "Asynchrony Deep Dive")[

  #line(length: 65%, stroke: 2pt + color_medium)

  #poolc_badge #h(.3em) 양제성

  #v(.5em)
  #set text(size: fontsize_small)
  #let date = datetime(year: date.year(), month: date.month(), day: date.day()).display(
    "[year]/[month]/[day] ([weekday repr:short])"
  )

  Source: #github_icon_link("https://github.com/J3m3/poolc-async.git") #h(1em) #date
]