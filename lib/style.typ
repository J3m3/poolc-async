#import "style.base.typ": *
#import "@preview/octique:0.1.0": octique-inline

#let haskell_color = rgb("#5e5086")

#let poolc_badge = link("https://poolc.org/")[
  #box(outset: .2em, fill: color_light, radius: .2em)[
    #set text(weight: "regular", font: "D2Coding")
    #box(image("../assets/poolc.icon.transparent.png", height: .75em))
    #h(-.2em)
    PoolC
  ]
]

#let github_icon_link(_link) = link(_link)[
  #octique-inline("mark-github")
]
