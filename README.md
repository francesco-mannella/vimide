# VimIDE

A lightweight Python IDE built on Vim and tmux. VimIDE turns Vim into a multi-panel development environment with integrated IPython, AI assistance, LaTeX support, and a terminal console — all inside a persistent tmux session.

---

## Overview

VimIDE is a Vim plugin plus a launcher script (`vide`) that sets up a full development environment:

- **Vim** runs in the top pane of a tmux window called `code`, with a three-panel layout: tag browser, editor, file explorer.
- **IPython** runs in the bottom pane (`console`), linked to the editor via vim-slime.
- Code cells, selections, or full scripts can be sent from the editor to IPython with single keystrokes.

---

## Layout

```
--------------------------------------------------------------------
|                |                      |                          |
|    Tagbar      |      Editor          |      File Explorer       |
|                |                      |                          |
--------------------------------------------------------------------
```

The Tagbar and file explorer panels collapse when not focused and expand on entry, keeping the editor at maximum width during editing.

---

## tmux Configuration

VimIDE ships a `scripts/tmux.conf` installed to `~/.tmux.conf`. It sets:

- **Terminal**: `screen-256color` with true-color overrides for xterm-compatible terminals.
- **Prefix key**: `Ctrl-a` (replaces the default `Ctrl-b`).
- **Message display time**: 0 ms (messages dismissed immediately).

---

## The `vide` Launcher

`vide` manages named tmux sessions containing the IDE. It is installed to `~/bin/vide`.

```
vide -n NAME        Start or reattach a session named NAME
vide -q NAME        Terminate the session named NAME
vide -l             List all active vide sessions
vide -d DIR         Set the working directory (default: current directory)
vide -h             Show help
```

On first launch, `vide`:
1. Creates a detached tmux session with a single window `code`, split into two panes: top (Vim, 75%) and bottom (console, 25%).
2. Starts Vim in the top pane, calls `RunPyIDE()` to set up the three-panel IDE layout, and configures vim-slime to target the bottom pane.
3. Attaches to the session with focus on the top pane.

```
tmux session: vide_NAME
└── window: code
    ├── pane 0 (top, 75%) ─────────────────────────────────────
    │   ┌─────────────┬───────────────────┬───────────────────┐
    │   │   Tagbar    │      Editor       │   File Explorer   │
    │   │             │                   │                   │
    │   └─────────────┴───────────────────┴───────────────────┘
    └── pane 1 (bottom, 25%) ──────────────────────────────────
        ┌───────────────────────────────────────────────────────┐
        │                      console                          │
        └───────────────────────────────────────────────────────┘
```

---

## IDE Shortcuts (Normal Mode)

These are provided by the `vimide` plugin (`plugin/vimide.vim`):

| Key   | Action |
|-------|--------|
| `,cp` | Open or reset the IDE layout (Tagbar + Editor + File Explorer) |
| `,cf` | Find all occurrences of the word under cursor; display results in the editor |
| `,cg` | Jump to the file and line of the occurrence under cursor (use inside find list) |
| `,cr` | Write back any edits made in the find list to their source files |
| `,cu` | Refresh the file explorer |
| `,f`  | Open the file path under cursor in the editor window |

---

## Python Features

Provided by `after/ftplugin/python.vim` via vim-slime and vim-ipython-cell.

### IPython integration

| Key         | Action |
|-------------|--------|
| `\ss`       | Start IPython (Qt backend) in the bottom pane |
| `\as`       | Start IPython (Agg backend, non-interactive) |
| `\hh`       | Send current line to IPython (normal mode) |
| `\hh`       | Send selection to IPython (visual mode) |
| `\aa`       | Send current line to IPython and advance cursor |
| `\aa`       | Send selection to IPython and advance cursor (visual mode) |
| `\rr`       | Run the entire script (`%run`) |
| `\RR`       | Run the entire script and report execution time |
| `\cc`       | Execute the current cell |
| `\vv`       | Execute the current cell verbosely, then jump to next cell |
| `\ll`       | Clear console, execute current cell, jump to next cell |
| `\LL`       | Clear the IPython console |
| `\xx`       | Close all Matplotlib figure windows |
| `\dd`       | Start the debugger (`%run -d`) on the current script |
| `\qq`       | Exit debug mode or IPython |
| `\QQ`       | Restart IPython |
| `[c`        | Jump to previous cell header (`# %%`) |
| `]c`        | Jump to next cell header (`# %%`) |
| `F9`        | Insert a new cell header above |
| `F10`       | Insert a new cell header below |

Cells are delimited by `# %%` or `#%%` markers (Jupyter-style percent format).

### Linting and fixing (ALE)

| Key     | Action |
|---------|--------|
| `Ctrl-k` | Jump to previous lint error |
| `Ctrl-j` | Jump to next lint error |
| `Ctrl-f` | Auto-fix the file (black, isort, autoimport) |
| `Ctrl-h` | Show hover documentation |
| `Ctrl-x` | Close the ALE preview window |

Linters: `pylsp` (flake8 backend) and `jedils`. Fixers: `black` (line length 90), `isort`, `autoimport`.

### Jupyter notebook support

Python files are treated as Jupytext percent-format notebooks. Saving a `.py` file updates the paired `.ipynb` automatically.

---

## LaTeX Features

Provided by `after/ftplugin/tex.vim` via vimtex.

- Compiler: `latexmk` with bibtex, synctex, and shell-escape.
- PDF viewer: Okular with forward/inverse search via synctex.
- Spell checking enabled (en_us), with a custom word list at `spell/dict.utf-8.add`.
- `§` reformats indentation of selected LaTeX comment blocks.
- ALE is disabled for tex files to avoid interference with vimtex.

---

## AI Integration

Provided by vim-ai with a custom roles file at `~/.config/ai/roles.ini`.

Available roles:

| Role | Model | Purpose |
|------|-------|---------|
| `default` | `meta-llama/llama-3.3-70b-instruct:free` | General assistant (free tier) |
| `gemini` | `google/gemini-3-flash-preview` | Google Gemini Flash |
| `gpt` | `openai/gpt-4o` | OpenAI GPT-4o |
| `gpt5` | `gpt-5.4` | OpenAI GPT-5 |
| `claude` | `anthropic/claude-3.5-sonnet` | Anthropic Claude 3.5 Sonnet |
| `opus` | `anthropic/claude-opus-4.6` | Anthropic Claude Opus 4.6 |
| `refine` | Rewrite and improve text for clarity and flow |
| `translate` | Translate text to English |
| `professional` | Rewrite text in a professional, expert tone |
| `simplify` | Simplify language, avoid jargon |
| `clarity` | Make text direct and unambiguous |
| `code` | Code expert: improve and format code |
| `refactor` | Refactor code for clarity and maintainability |
| `optimize` | Optimize code for speed and memory |
| `comment` | Add comments and docstrings |
| `enhance-docstring` | Rewrite docstrings in Google format |
| `enhance-comments` | Add and improve inline comments and docstrings |
| `reformat-comments` | Reformat comments to fit within 79 characters |

All roles route through [OpenRouter](https://openrouter.ai). A single token file is required:

```
~/.config/ai/openrouter.token
```

To provision it:

1. Create an account at [openrouter.ai](https://openrouter.ai) and generate an API key.
2. Write the key to the expected path:

```bash
mkdir -p ~/.config/ai
echo "sk-or-..." > ~/.config/ai/openrouter.token
chmod 600 ~/.config/ai/openrouter.token
```

The token file is plain text containing only the API key. It is never stored in this repository.

---

## General Editor Features

### Commenting

Works across file types (Python, Bash, C/C++, TeX, Vim, etc.).

| Key  | Action |
|------|--------|
| `zc` | Comment selected lines |
| `zv` | Uncomment selected lines |

### Git grep

| Key        | Action |
|------------|--------|
| `\g`       | Git grep for the word under cursor |
| `\t`       | Return to previous location after a grep jump |
| `:GG`      | Git grep (arbitrary pattern) |
| `:GGw`     | Git grep whole-word |
| `:GGi`     | Git grep case-insensitive |

### Clipboard

| Key  | Action |
|------|--------|
| `ay` | Yank selection to system clipboard (xclip) |
| `ap` | Paste from system clipboard |

### Markdown

| Key    | Action |
|--------|--------|
| `\mm`  | Add HTML anchor tags to headings in the selected range |

Live markdown preview with MathJax support via vim-instant-markdown.

### Other

- `Bdi` command: close all hidden (non-visible) buffers.
- Indent guides: alternating dark background stripes every 4 spaces.
- Mark visualization: visible marks in the sign column (vim-signature).
- Directory diff: `:DirDiff` via vim-dirdiff.
- Auto-save on focus lost.
- Line numbers always on.
- Smart case-insensitive search.

---

## Installed Plugins

| Plugin | Purpose |
|--------|---------|
| vim-vinegar | Enhanced netrw file explorer |
| vimtex | LaTeX editing and compilation |
| jedi-vim | Python autocompletion |
| ale | Asynchronous linting and fixing |
| tagbar | Tag/symbol browser |
| jupytext.vim | Jupyter notebook / percent-format sync |
| vim-dirdiff | Directory diff tool |
| vim-ipynb | Jupyter notebook support |
| vim-slime | Send code to a terminal multiplexer pane |
| vim-ipython-cell | Cell-based IPython execution |
| vim-signature | Visual mark management |
| vim-sh-heredoc-highlighting | Heredoc syntax highlighting in shell files |
| vim-ai | AI text and code assistance |
| vim-ai-provider-google | Google provider for vim-ai |
| vim-sh | Improved shell script syntax |
| traces.vim | Live preview of substitution commands |
| vim-instant-markdown | Live Markdown preview in browser |
| loremipsum | Lorem ipsum text generator |
| vim-indent-guides | Visual indentation guides |
| vim-markdown-toc | Table of contents generator for Markdown |
| gitgrep.vim | Git grep integration |

---

## Installation

```bash
./install.sh
```

The installer:
- Installs vim-plug if absent.
- Copies `scripts/vimrc` to `~/.vimrc`.
- Copies `scripts/tmux.conf` to `~/.tmux.conf`.
- Installs and updates all Vim plugins.
- Copies `scripts/roles.ini` to `~/.config/ai/roles.ini`.
- Copies `scripts/CLAUDE.md` to `~/.claude/CLAUDE.md`.
- Installs Python tools: `ipynb-py-convert`, `notedown` (via uv).
- Installs system packages: `tmux`, `universal-ctags`.
- Copies `scripts/vide` to `~/bin/vide` and adds `~/bin` to `PATH`.
- Adds a `vim --servername vim` alias to `.bashrc`.
- Adds SSH auth and DISPLAY tracking fix for tmux sessions.

---

## Repository Structure

```
.
├── after/ftplugin/
│   ├── python.vim       # Python-specific settings and keymaps
│   └── tex.vim          # LaTeX-specific settings
├── colors/              # Color schemes
├── doc/                 # Vim help documentation
├── plugin/
│   └── vimide.vim       # Core IDE plugin
├── scripts/             # Files installed to the system
│   ├── vimrc            # Vim configuration
│   ├── tmux.conf        # tmux configuration
│   ├── roles.ini        # vim-ai role definitions
│   ├── CLAUDE.md        # Claude Code project instructions
│   └── vide             # IDE launcher script
├── spell/               # Custom spell-check word list
└── install.sh           # Installer
```
