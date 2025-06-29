// global
#import "@preview/great-theorems:0.1.2": great-theorems-init
#import "@preview/hydra:0.5.2": hydra
#import "@preview/equate:0.3.1": equate
#import "@preview/i-figured:0.2.4": reset-counters, show-equation

#let template(
  // personal/subject related stuff
  author: "Stuart Dent",
  title: "My Very Fancy and Good-Looking Thesis About Interesting Stuff",
  supervisor1: none,
  supervisor2: none,
  degree: "Example",
  program: "Example-Studies",
  university: "Nanjing University",
  institute: "School of Intelligence Science and Technology",
  deadline: datetime.today(),
  city: "Suzhou",


  // file paths for logos etc.
  uni-logo: image("images/nju_all.svg"),
  institute-logo: none,

  // formatting settings
  body-font: "Libertinus Serif",
  cover-font: "Libertinus Serif",

  // content that needs to be placed differently then normal chapters
  abstract: none,

  // colors
  cover-color: rgb("#800080"),
  heading-color: rgb("#0000ff"),
  link-color: rgb("#000000"),

  // equation settings
  equate-settings: none,
  equation-numbering-pattern: "(1.1)",

  // type
  subtype: "thesis",

  // the content of the thesis
  body
) = {
// ------------------- settings -------------------
set document(author: author, title: title)
set heading(numbering: "1.1")  // Heading numbering
set enum(numbering: "(i)") // Enumerated lists
show link: set text(fill: link-color)
show ref: set text(fill: link-color)

// ------------------- Math equation settings -------------------

// either use equate if equate-settings is set or use i-figured if equate-settings is none
// i-figured settings
show math.equation: it => {
  if equate-settings == none {
    show-equation(prefix: "eq:", only-labeled: true, numbering: equation-numbering-pattern, it)
  } else {
    it
  }
}
set math.equation(supplement: none) if equate-settings == none

// equate settings
show: it => {
  if equate-settings != none {
    equate(..equate-settings, it)
  } else {
    it
  }
}
set math.equation(numbering: equation-numbering-pattern) if equate-settings != none

// Reference equations with parentheses (for equate)
// cf. https://forum.typst.app/t/how-can-i-set-numbering-for-sub-equations/1603/4
show ref: it => {
  let eq = math.equation
  let el = it.element

  let is-normal-equation = el != none and el.func() == eq
  let with-subnumbers = equate-settings != none and equate-settings.keys().contains("sub-numbering") and equate-settings.sub-numbering
  let is-sub-equation = el != none and el.func() == figure and el.kind == eq
  if equate-settings != none and is-normal-equation {
    link(el.location(), numbering(
      el.numbering,
      ..counter(eq).at(el.location())
    ))
  } else if equate-settings != none and not with-subnumbers and is-sub-equation {
    link(el.location(), numbering(
      el.numbering,
      counter(eq).at(el.location()).at(0) - 1
    ))
  } else if equate-settings != none and is-sub-equation {
    link(el.location(), numbering(
      el.numbering,
      ..el.body.value
    ))
  } else {
    it
  }
}

show math.equation: box  // no line breaks in inline math
show: great-theorems-init  // show rules for theorems


// ------------------- Settings for Chapter headings -------------------
show heading.where(level: 1): set heading(supplement: [Chapter])
show heading.where(
  level: 1,
): it => {
  if it.numbering != none {
    block(width: 100%)[
      #line(length: 100%, stroke: 0.6pt + heading-color)
      #v(0.1cm)
      #set align(left)
      #set text(22pt)
      #text(heading-color)[Chapter
      #counter(heading).display(
        "1:" + it.numbering
      )]

      #it.body
      #v(-0.5cm)
      #line(length: 100%, stroke: 0.6pt + heading-color)
    ]
  }
  else {
    block(width: 100%)[
      #line(length: 100%, stroke: 0.6pt + heading-color)
      #v(0.1cm)
      #set align(left)
      #set text(22pt)
      #it.body
      #v(-0.5cm)
      #line(length: 100%, stroke: 0.6pt + heading-color)
    ]
  }
}
// Automatically insert a page break before each chapter
show heading.where(
  level: 1
): it => {
  pagebreak(weak: true)
  it
}
// only valid for abstract and declaration
show heading.where(
  outlined: false,
  level: 2
): it => {
  set align(center)
  set text(18pt)
  it.body
  v(0.5cm, weak: true)
}
// Settings for sub-sub-sub-sections e.g. section 1.1.1.1
show heading.where(
  level: 4
): it => {
  it.body
  linebreak()
}
// same for level 5 headings
show heading.where(
  level: 5
): it => {
  it.body
  linebreak()
}

// reset counter from i-figured for section-based equation numbering
show heading: it => {
  if equate-settings == none {
    reset-counters(it)
  } else {
    it
  }
}
// ------------------- other settings -------------------
// Settings for Chapter in the outline
show outline.entry.where(
  level: 1
): it => {
  v(14.75pt, weak: true)
  strong(it)
}

// table label on top and not below the table
show figure.where(
  kind: table
): set figure.caption(position: top)

// ------------------- Cover -------------------
set text(font: cover-font)  // cover font

v(1fr)
//logos
  if uni-logo != none and institute-logo != none {
    grid(
      columns: (1fr, 1fr),
      rows: (auto),
      column-gutter: 100pt,
      row-gutter: 7pt,
      grid.cell(
        colspan: 1,
        align: center,
        uni-logo,
      ),
      grid.cell(
        colspan: 1,
        align: center,
        institute-logo,
      ),
    )
  } else if uni-logo != none {
    grid(
      columns: (0.5fr),
      rows: (auto),
      column-gutter: 100pt,
      row-gutter: 7pt,
      grid.cell(
        colspan: 1,
        align: center,
        uni-logo,
      )
    )
  } else if institute-logo != none {
    grid(
      columns: (0.5fr),
      rows: (auto),
      column-gutter: 100pt,
      row-gutter: 7pt,
      grid.cell(
        colspan: 1,
        align: center,
        institute-logo,
      )
    )
  }
v(3fr)
//title
line(length: 100%, stroke: cover-color)
align(center, text(3em, weight: 700, title))
line(start: (10%, 0pt), length: 80%, stroke: cover-color)
v(3fr)
//author
if subtype == "thesis" {
  align(center, text(1.5em, weight: 500, degree + " Thesis by " + author))
} else {
  align(center, text(1.5em, weight: 500, author))
}
//study program
if subtype == "thesis" {
  if program != none {
    align(center, text(1.3em, weight: 100, "Study Programme: " + program))
  }
} else {
  if program != none {
    align(center, text(1.1em, "in"))
    align(center, text(1.3em, weight: 100, program))
  }
}
v(2fr)
//university
align(center, text(1.3em, weight: 100, institute + " at " + university))
//date
let deadlinetext = none
if type(deadline) == datetime {
  deadlinetext = deadline.display("[month repr:long] [year]")
} else {
  deadlinetext = deadline
}
if city != none {
  deadlinetext = city + ", " + deadlinetext
}
align(center, text(1.3em, weight: 100, deadlinetext))
// supervisors
if supervisor1 != none and supervisor2 != none {
  align(center + bottom, text(1.3em, weight: 100, " supervised by" + linebreak() + supervisor1 + linebreak() +  supervisor2))
}
pagebreak()

// ------------------- Abstract -------------------
set text(font: body-font)  // body font
if abstract != none{
  abstract
}


set page(
  numbering: "1",
  number-align: center,
  header: context {
    align(center, emph(hydra(1)))
    v(0.2cm)
  },
)  // Page numbering after cover & abstract => they have no page number
pagebreak()

// ------------------- Tables of ... -------------------

// Table of contents
set outline.entry(fill: line(length: 100%, stroke: (thickness: 1pt, dash: "loosely-dotted")))
outline(depth: 3, indent: 1em)
pagebreak()

// List of figures
outline(
  title: [List of Figures],
  target: figure.where(kind: image)
)
pagebreak()


// List of Tables
outline(
  title: [List of Tables],
  target: figure.where(kind: table)
)
pagebreak()



// ------------------- Content -------------------
body
}

