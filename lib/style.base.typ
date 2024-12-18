#let default_font = "Pretendard"
#let fontsize_big = 30pt
#let fontsize_medium = 25pt
#let fontsize_small = 20pt
#let fontsize_extrasmall = 16pt
#let fontsize_copyright = 6pt

#let (margin_x, margin_y) = (1.1cm, 1.1cm)

// ======= CHANGABLE THINGS =======
#let color_light = rgb("#e0f0ed")
#let color_medium = rgb("#a7dad5")
#let color_dark = rgb("#47be9b")
#let date = datetime(year: 2024, month: 11, day: 22)
// ================================

#let copyright(date: date) = [
  ⓒ #date.year(). Je Sung Yang all rights reserved.
]
