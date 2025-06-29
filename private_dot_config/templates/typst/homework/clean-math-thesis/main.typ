// global
#import "lib.typ": template

//local
#import "customization/colors.typ": *

// // wordcount
// #import "@preview/wordometer:0.1.4": word-count, total-words
// #show: word-count
// In this document, are #total-words words all up.

// // Pin main typ file
// You can use "<space> tp" to pin the main file
// Or you can use `:lua vim.api.nvim_buf_get_name(0)` to pin the main file


#show: template.with(
  // personal/subject related stuff
  author: "Meng-Qi Yuan, 522024710016",
  title: "My Very Fancy and Good-Looking Thesis About Interesting Stuff",
  program: "Advanced Optimization",
  university: "Nanjing University",
  institute: "School of Intelligence Science and Technology",
  deadline: datetime.today(),
  city: "Suzhou",

  // file paths for logos etc.
  uni-logo: image("images/nju_all.svg", width: 100%),

  // formatting settings
  body-font: "Times New Roman", // "Libertinus Serif", "Times New Roman", "Linux Libertine O"
  cover-font: "Times New Roman", // same as above

  // chapters that need special placement
  abstract: include "chapter/abstract.typ",

  // equation settings
  equate-settings: (breakable: true, sub-numbering: true, number-mode: "label"),
	equation-numbering-pattern: "(1.1)",

  // colors
  cover-color: color1,
  heading-color: color2,
  link-color: color3,
  
  // type
  subtype: "report"
)

// ------------------- content -------------------
#include "chapter/introduction.typ"
#include "chapter/dummy_chapter.typ"
#include "chapter/conclusions_outlook.typ"
#include "chapter/appendix.typ"

// // New figure type
// You can add it to a typ file
// make the typ file show image camption like paper(long description)
// #show figure.caption: it => {
//   set align(left)
//   set text(size: 9pt)
//   it
// }


// ------------------- bibliography -------------------
#bibliography("References.bib")

// ------------------- declaration -------------------
#include "chapter/declaration.typ"
