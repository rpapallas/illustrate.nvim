# 🎨 Illustrate

Illustrate is a lua plugin for neovim to create and manage vector documents in
your LaTeX and Markdown files for both Inkscape and Adobe Illustrator.

With key bindings you define, you can:

* Create new `.svg` files in the current working directory and opening them in Inkscape / Adobe Illustrator.
* Create new `.ai` (Adobe Illustrator) files in the current working directory and opening them in Inkscape / Adobe Illustrator.
* Using [telescope](https://github.com/nvim-telescope/telescope.nvim) you can search through the
  available `.svg` and `.ai` documents and open them in Inkscape / Adobe Illustrator.

<!-- TODO: Include a video/gif showing the main features. --> 

## Installation

### lazy.nvim

```lua
return { 
    'rpapallas/illustrate.nvim'
    keys = function()
        local illustrate = require('illustrate')
        local illustrate_finder = require('illustrate.finder')
        return {
            {"<leader>vs", function() illustrate.create_and_open_svg() end, desc ="create new .svg file, open it in default app and insert code in document."},
            {"<leader>va", function() illustrate.create_and_open_ai() end, desc ="craete new .ai file, open it in default app and insert code in document."},
            {"<leader>vf", function() illustrate_finder.search_and_open() end, desc ="search for illustration files in current directory and open selected one in default app."},
        }
    end,
    opts = {
        -- optionally define options.
    },
}
```

The default options are:

```lua
illustration_dir = "figures", -- the directory to store new illustrations in cwd.
template_files = { -- paths to saved template files used when creating new documents.
    directory = {
        svg = "~/templates/svg",
        ai = "~/templates/ai",
    },
    default = {
    }
},
text_templates = { -- default text templates to insert into the document per file type.
    svg = {
        tex = "\\begin{figure}[htbp]\n\\centering\n\\includesvg[width=\\linewidth]{%s}\n\\caption{caption}\n\\label{fig:label}\n\\end{figure}",
        md = "![caption](%s)",
    },
    ai = {
        tex = "\\begin{figure}[htbp]\n\\centering\n\\includesvg[width=\\linewidth]{%s}\n\\caption{caption}\n\\label{fig:label}\n\\end{figure}",
        md = "![caption](%s)",
    }
},
default_app = { -- default app to use for each file type.
    svg = "inkscape", -- options: inkscape / illustrator
    ai = "inkscape", -- options: inkscape / illustrator
},
```

## Contributions, feedback and requests

Happy to accept contributions/pull requests to extend and improve this simple 
plugin. Also open to feedback and requests for new features, if you open a 
GitHub issue.

## Features

- [ ] Telescope to show preview of svg files.
- [ ] Allow opening of a figure under cursor (or while cursor within a figure environment).

## Other notes

* This plugin is inspired from [this](https://github.com/gillescastel/inkscape-figures) Python project from [Gilles Castel](https://github.com/gillescastel) and his excellent blog post [here](https://castel.dev/post/lecture-notes-2/), but extended to support Adobe Illustrator on top of Inkscape and be a native lua plugin for neovim.
* This is my first neovim plugin and the first time I write a lua program (any feedback is appreciated).

