// 16pt对应的是三号字体
// 15pt对应的是小三号字体
// 14pt对应的是四号字体
// 12pt对应的是小四号字体
// 10.5pt对应的是五号字体

#let project(
    title: "",
    authors: (),
    abstract: none,
    keywords: (),
    body
) = {
    let zh_hei = ("Noto Sans CJK SC", )        // 黑体，用于标题和强调
    let zh_shusong = ("Noto Serif CJK SC", )    // 宋体，用于正文
    let zh_kai = ("AR PL UKai", )             // 楷体，用于引文等
    let zh_fangsong = ("AR PL UKai", )        // 仿宋体(暂无)，使用风格相近的楷体替代
    let zh_xiaobiansong = ("Noto Sans CJK SC", )// 小标宋(暂无)，使用醒目的黑体作为标题替代
    let en_sans_serif = ("Linux Biolinum O", )
    let en_serif = ("Linux Libertine O", )
    let en_typewriter = ("Ubuntu Mono", )
    let en_code = ("Ubuntu Mono", )
    // Moidfy the following to change the font.
    let title-font = (..en_serif, ..zh_hei)
    let author-font = (..en_typewriter, ..zh_fangsong)
    let body-font = (..en_serif, ..zh_shusong)
    let heading-font = (..en_serif, ..zh_xiaobiansong)
    let caption-font = (..en_serif, ..zh_kai)
    let header-font = (..en_serif, ..zh_kai)
    let strong-font = (..en_serif, ..zh_hei)
    let emph-font = (..en_serif, ..zh_kai)
    let raw-font = (..en_code, ..zh_hei)

    set document(author: authors.map(author => author.name), title: title)
    set page(numbering: "1", number-align: center, header: align(left)[
        #set text(font: header-font)
        #title
    ])
    set heading(numbering: "1.1")
    set text(font: body-font, lang: "zh", region: "cn")
    set bibliography(style: "gb-7714-2015-numeric")

    show heading: it => box(width: 100%)[
        #v(0.50em)
        #set text(font: heading-font)
        #if it.numbering != none { counter(heading).display() }
        #h(0.75em)
        #it.body
    ]

    show heading.where(
        level: 1
    ): it => box(width: 100%)[
            #v(0.5em)
            #set align(center)
            #set heading(numbering: "一")
            #it
            #v(0.75em)
        ]

    // Title
    align(center)[
        #block(text(font: title-font, weight: "bold", 1.75em, title))
        #v(0.5em)
    ]

    // Display the authors list.
    for i in range(calc.ceil(authors.len() / 3)) {
    let end = calc.min((i + 1) * 3, authors.len())
    let is-last = authors.len() == end
    let slice = authors.slice(i * 3, end)
    grid(
        columns: slice.len() * (1fr,),
        gutter: 12pt,
        ..slice.map(author => align(center, {
            text(12pt, author.name, font: author-font)
            if "organization" in author [
            \ #text(author.organization, font: author-font)
        ]
            if "id" in author [
            \ #text(author.id, font: author-font)
        ]
            if "email" in author [
            \ #text(link("mailto:" + author.email), font: author-font)
        ]
        }))
    )

    if not is-last {
    v(16pt, weak: true)
}
}
    v(2em, weak: true)

    // Main body
    set enum(indent: 2em)
    set list(indent: 2em)
    set figure(gap: 0.8cm)

    // 定义空白段，解决首段缩进问题
    set par(first-line-indent: (amount: 2em, all: true))

    show figure: it => [
        #v(12pt)
        #set text(font: caption-font)
        #it
        #v(12pt)
    ]

    show table: it => [
        #set text(font: body-font)
        #it
    ]

    show strong: set text(font: strong-font)
    show emph: set text(font: emph-font)
    show ref: set text(red)
    show raw.where(block: true): block.with(
        width: 100%,
        fill: luma(240),
        inset: 10pt,
    )

    show raw.where(block: true): it => [
        #it
    ]

    show raw: set text(font: raw-font)
    show link: underline
    show link: set text(blue)
    set par(first-line-indent: 2em, justify: true)

    if abstract != none [
    #v(2pt)
    #h(2em) *摘要：* #abstract

    #if keywords!= () [
    *关键字：* #keywords.join("；")
]
    #v(2pt)
]

    body
}

#let problem-counter = counter("problem")
#let problem(body) = block(
    fill: rgb(241, 241, 255),
    inset: 8pt,
    radius: 2pt,
    width: 100%,
)[
    #problem-counter.step()
    *题目 #context problem-counter.display().* 
    #h(0.75em) 
    #body
]

#let solution(body) = {
    set enum(numbering: "(1)")
    block(
        inset: 8pt,
        width: 100%
    )[*解答.* #h(0.75em) #body]
}
