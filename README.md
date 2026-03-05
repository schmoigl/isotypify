# Isotypify

Create isotype visualizations in your browser — no coding required — or embed them in your own Observable notebooks.

Inspired by [Otto and Marie Neurath's ISOTYPE system](https://en.wikipedia.org/wiki/Isotype_(picture_language)), built with [Quarto](https://quarto.org/), [D3.js](https://d3js.org/), and [Observable JS](https://observablehq.com/).

[![Isotypify Your Data](img/screenshot.png)](https://schmoigl.github.io/isotypify/)

**Live:** [schmoigl.github.io/isotypify](https://schmoigl.github.io/isotypify/) · [Observable Notebook](https://observablehq.com/@schmoigl/isotypify-your-data)

## Web editor

Open [schmoigl.github.io/isotypify](https://schmoigl.github.io/isotypify/) in your browser. Configure rows, colors, glyph shapes, and figure counts with the interactive controls, then download the result as a PNG — no installation needed.

A data-driven demo using Austrian time-use survey data is available at [/demo](https://schmoigl.github.io/isotypify/demo.html).

## Observable / code usage

Import `makeIsoline` from the [Observable notebook](https://observablehq.com/@schmoigl/isotypify-your-data) to use it in your own notebooks:

```javascript
import {makeIsoline} from "@schmoigl/isotypify-your-data"

makeIsoline({
  persPerLineValue: 20,
  data: [
    {
      key: "Women",
      value: 0.75,
      shapes: "abcdefg",
      fillHighlight: "#D62300",
      fillNormal: "#F5EBDC"
    }
  ]
})
```

## Local development

```bash
git clone https://github.com/schmoigl/isotypify.git
cd isotypify
quarto preview
```

## Technologies

- **[Quarto](https://quarto.org/)** — publishing system with Observable JS integration
- **[D3.js](https://d3js.org/)** — data handling and layout
- **[Isotype Font](https://www.dafont.com/isotype.font)** — 234+ pictographic glyphs by Ric Stephens
- **[Jost](https://fonts.google.com/specimen/Jost)** — headings and body text

---

**Maintained by:** [@schmoigl](https://github.com/schmoigl) | **Organization:** [WIFO](https://www.wifo.ac.at/)
