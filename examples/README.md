# LaTeX Examples

In all examples below you can use `make` to build the document and `make clean`
to delete compiled artifacts.

## Example 0 - Flat project

This is the simplest structure, you have a single directory where all of your
LaTeX documents live in, and you have a single figures directory:

```
.
├── Makefile
└── main.tex
```

illustrate.nvim will create a `figures` directory the next time you attempt
to create a new figure, if a `figures` directory does not already exists.


## Example 1 - Chapters with a figures directory already in root

The example is a latex document where main content is split into chapters
and sections. Each chapter has its own directory (`chapters/chapter_name`) that
hosts all its sections. The project has a `figures` directory already in the
root (created by the user):

```
.
├── Makefile
├── chapters/
│   └── introduction/
│       ├── introduction.tex
│       └── objectives.tex
├── figures/
└── main.tex
```

illustrate.nvim will find the existence of `figures` in the root directory and
save all figures (despite where you are in the project) in there. You may
be editing `chapters/introduction/objectives.tex` (cwd is root), or you may
be editing `objectives.tex` (cwd is `chapters/introduction`), illustrate.nvim
will save the figures in the `figures` directory that already exists in the 
root directory.

## Example 2 - Chapters without a figures directory anywhere

In this example, the project does not include a `figures` directory:

```
.
├── Makefile
├── chapters/
│   └── introduction/
│       ├── introduction.tex
│       └── objectives.tex
└── main.tex
```

illustrate.nvim will attempt to create one in the root directory the next
time you try to create a new figure, anywhere in the project. For example,
you can `cd chapters/introduction` and edit `objectives.tex`. You can invoke
illustrate.nvim to create a new SVG file. The plugin should create a new `figures`
directory under the root directory and save the new figure there.

illustrate.nvim uses the `directories_to_avoid_creating_illustration_dir_in` in
the config to find which directories to avoid creating a new `figures`
directory in. By default, if a `figures` directory isn't found anywhere in the
path, it will avoid creating a new `figures` directory in `chapters` or
`sections` directories, and will attempt to create one in a parent directory.
You can add to that list any directory names you want to avoid creating a new
figures directory in in your config.

## Example 3 - Chapters with their own figures directory

In this example, the project includes a `figures` directory, but not
in the root. Each chapter has its own `figures` directory. For this example to work,
the user has to create the `figures` directories (even empty) inside each directory
of the `chapters` directory manually.

```
.
├── Makefile
├── chapters/
│   ├── introduction/
│   │   ├── figures/
│   │   ├── introduction.tex
│   │   └── objectives.tex
│   └── literature_review/
│       ├── figures/
│       └── literature_review.tex
└── main.tex
```

If you are working on file `objectives.tex` of the introduction chapter but
you current working directory is the root directory, and figures you attempt
to create using illustrate.nvim will be created inside the `figures` of the
introduction chapter.

# Markdown
