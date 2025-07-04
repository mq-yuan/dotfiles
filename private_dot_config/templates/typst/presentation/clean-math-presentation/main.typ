#import "@preview/touying:0.5.5": *
#import "lib.typ": *

#show: clean-math-presentation-theme.with(
  config-info(
    title: [An example presentation to show how this template can be used],
    short-title: [Short title that will be shown in the footer],
    authors: (
      (name: "MengQi Yuan, 522024710016", affiliation-id: 1)),
    author: "MengQi Yuan",
    affiliations: (
      (id: 1, name: "School of Intelligence Science and Technology, Nanjing University"),
    ),
    date: datetime.today(),
  ),
  config-common(
    slide-level: 2,
  ),
  progress-bar: true,
)

#title-slide(
  logo1: image("images/logo_nju.png", height: 4.5em),
)

// == Outline <touying:hidden>

// #components.adaptive-columns(outline(title: none))

= First Section

#slide(title: "Using the template")[
  To use this template,
  - import it at the beginning of your presentation like this: `#import "@preview/clean-math-presentation:0.1.1": *`
  - import touying by `#import "@preview/touying:0.5.5": *`
  - call the `#show: clean-math-presentation-theme.with()` function to set the title, authors, and other information of your presentation.
  中文也可以用!

  The title slide can be created with the `#title-slide()` command. You can pass a `background` (an image or `none`) and up to two logos `logo1` and `logo2`. \
  The outline can be included, e.g., with `#components.adaptive-columns(outline(title: none))`.\
  Normal slides can be created with `#slide()`. \
  A lot of general documentation about the Touying package can be found #link("https://touying-typ.github.io/")[in the Touying documentation]. The general #link("https://typst.app/docs/")[typst documentation] is also helpful.
]

#focus-slide[
  Focus!
]

#slide(title: "Theorems")[
  Theorems can be created with the `#theorem` command. Similarly, there are `#proof`, `#definition`, `#example`, `#lemma`, and `#corollary`. \
  For example, here is a theorem:
  #theorem(title: "Important one")[
    Using theorems is easy.
  ]
  #proof[
    This was very easy, wasn't it?
  ]
  #pause
  A definition already given by well-known mathematicians @Author1978definition is:
  #definition(title: "Important stuff")[
    _Important stuff_ is defined as the stuff that is important to me:
    $
      exp(upright(i) pi) + 1 = 0.
    $
  ]
]

#slide(title: "Equations")[
  Equations with a label with a label will be numbered automatically:
  $
    integral_0^oo exp(-x^2) dif x = pi/2
  $<eq:important>
  We can then refer to this equation as @eq:important.
  Equations without a label will not be numbered:
  $
    sum_(n=1)^oo 1/n^2 = pi^2/6
  $
  Inline math equations will not break across lines, which can be seen here: $a x^2 + b x + c = 0 => x_(1,2) = (-b plus.minus sqrt(b^2 - 4 a c))/(2 a)$
]

#show: appendix

= References

#slide(title: "References")[
  #bibliography("bibliography.bib", title: none)
]
