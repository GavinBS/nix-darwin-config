# macOS Nix Configuration

Personal macOS configuration managed with:

* Nix Flakes
* nix-darwin
* Home Manager

## Features

* macOS system configuration with nix-darwin
* Home Manager configuration for the macOS user environment
* Machine-specific settings stored in `.personal.nix`
* Modular Neovim, Zsh, Git, and shell configuration
* Lightweight fzf-based project manager for Zsh
* Apple Silicon (`aarch64-darwin`) support

## License

The configuration files in this repository are available under the
[MIT License](LICENSE).

## Repository Structure

```text
.
├── flake.nix
├── .personal.nix.example
│
├── darwin/
│   ├── configuration.nix
│   ├── modules/
│   └── pkgs/
│
└── home/
│   ├── default.nix
│   ├── ghostty/
│   ├── modules/
│   ├── nvim/
│   ├── pm/
│   └── zsh/
```

## Personal configuration

Create the ignored local configuration from the template:

```bash
cp .personal.nix.example .personal.nix
```

Then set your machine and Git identity values in `.personal.nix`:

```nix
{
  username = "yourname";

  darwinHost = "MacBook";

  gitName = "Your Name";
  gitEmail = "you@example.com";
}
```

### Optional local Ghostty background

Machine-local assets belong under the ignored `.local/` directory so they are
never published with the repository. To use a private Ghostty background, save
the image locally and create `.local/ghostty/config.ghostty`:

```text
background-image = ~/.config/nix/.local/ghostty/backgrounds/background.png
background-image-opacity = 0.10
background-image-position = center
background-image-fit = cover
background-image-repeat = false
```

The main Ghostty configuration loads this optional file when it exists. Files
under `.local/` are ignored by Git and must not be force-added.

### Ghostty keyboard shortcuts

Keyboard shortcuts are defined in the `# Keybinds` section of
`home/ghostty/config.ghostty`:

| Shortcut | Action |
| --- | --- |
| `Ctrl+Shift+C` | Copy to the clipboard |
| `Ctrl+Shift+V` | Paste from the clipboard |
| `Ctrl+Shift+R` | Reload the Ghostty configuration |
| `Ctrl+Shift+N` | Open a new window |
| `Ctrl+Shift+T` | Open a new tab |
| `Ctrl+Shift+W` | Close the current terminal surface |
| `Ctrl+Shift+Enter` | Create a split on the right |
| `Ctrl+Shift+\` | Create a split below |

Use `keybind = shortcut=action` to define a shortcut. Join modifier keys and
the key with `+`, for example:

```text
keybind = ctrl+shift+t=new_tab
keybind = ctrl+shift+enter=new_split:right
keybind = ctrl+shift+backslash=new_split:down
```

After editing the configuration, press `Ctrl+Shift+R` to reload it. If you
change the reload shortcut itself, restart Ghostty to apply the change.

## macOS

Apply the macOS configuration:

```bash
sudo darwin-rebuild switch --flake "path:$HOME/.config/nix#<darwinHost>"
```

## Updating

Update flake inputs:

```bash
nix flake update
```

Homebrew packages are not automatically upgraded during a normal rebuild.
However, `homebrew.onActivation.cleanup = "zap"` removes Homebrew formulae and
casks that are not declared by this configuration, together with files covered
by Homebrew's cask `zap` rules. Review local Homebrew installations before
applying the configuration.

Apply changes:

```bash
sudo darwin-rebuild switch --flake "path:$HOME/.config/nix#<darwinHost>"
```

## Project Manager

`pm` is a lightweight fzf-based project manager implemented as a Zsh
function. Projects are explicitly added rather than discovered by scanning a
directory, and they do not need to be Git repositories.

```text
pm [query]        Select and enter a project
pm add [path]     Add the current or specified directory
pm remove         Remove a project from the list
pm list           List projects
pm clean          Remove paths that no longer exist
pm edit           Edit the project list with $EDITOR
pm help           Show help
```

Examples:

```zsh
cd "$HOME/repo/example-project"
pm add

pm add "$HOME/repo/demo-app"
pm add "$HOME/.config/example-config"
pm demo
```

Selecting a project changes the working directory of the current shell. Press
`Esc` to cancel without changing directories. Missing directories are omitted
from the selector until they are removed with `pm clean`.

The reusable function is stored in `home/pm/pm.zsh` and loaded by Home Manager.
The private project list is created and maintained at runtime:

```text
${XDG_STATE_HOME:-$HOME/.local/state}/pm/projects
```

This state file contains local absolute paths. It is outside this repository,
is not managed by Nix or Home Manager, and must not be added to the public Git
repository. Project data stays on the local machine by default.

## Neovim

Neovim is managed by Home Manager as a lightweight editor setup. Plugins and
language servers come from nixpkgs, so no separate plugin manager or Mason
installation is required.

The configuration uses:

* `mini.nvim` for file search, live grep, statusline, pairs, comments, and
  surround operations
* `nvim-tree` for the tree-style file browser
* Neovim's built-in LSP client

Supported language servers:

| Language | Server |
| --- | --- |
| Nix | `nixd` |
| Python | `pyright` |
| Lua | `lua-language-server` |
| Shell | `bash-language-server` |
| JavaScript and TypeScript | `typescript-language-server` |

### Key bindings

The leader key is `Space`.

| Key | Action |
| --- | --- |
| `Space e` | Toggle the file tree |
| `Space o` | Locate the current file in the file tree |
| `Space f f` | Find files |
| `Space f g` | Search text in the project |
| `Space f b` | Find open buffers |
| `Space f h` | Search Neovim help |
| `Space w` | Save the current file |
| `Space b d` | Close the current buffer |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Show documentation |
| `Space r n` | Rename symbol |
| `Space c a` | Show code actions |
| `Space d` | Show diagnostics at the cursor |
| `[d` / `]d` | Go to the previous or next diagnostic |
| `Ctrl-x Ctrl-o` | Request LSP completion |

The Home Manager module is in `home/modules/nvim.nix`, and the Lua
configuration is in `home/nvim/init.lua`. Apply changes with the same
`darwin-rebuild switch` command shown above.

## Useful Commands

Show available configurations:

```bash
nix flake show --all-systems "path:$HOME/.config/nix"
```

Check the repository:

```bash
nix flake check "path:$HOME/.config/nix"
```

Format all Nix files:

```bash
nix fmt
```

Check Git status:

```bash
git status
```

## Notes

This repository separates:

* System configuration (`darwin`)
* User configuration (`home`)
* Local personal information (`.personal.nix`, ignored by Git)

`.personal.nix.example` is the committed template. Always prefix the Flake path
with `path:` so Nix can load the ignored local configuration. For example, use
`--flake "path:$HOME/.config/nix#<darwinHost>"`, not `--flake ~/.config/nix`.

Nix must be installed before applying this configuration. This repository keeps
`nix.enable = false`, so nix-darwin does not install or manage Nix itself.

Neovim configuration is copied into the Nix store, so run
`darwin-rebuild switch` after editing it. Ghostty configuration is linked
directly from this repository; restart or reload Ghostty after editing it.
