# Dotfiles

Personal dotfiles and system configurations managed with **GNU Stow**, tailored for **BlendOS / Arch Linux**, featuring **Hyprland**, **Neovim**, and **Noctalia** dynamic theming.

---

## 🖥️ Desktop & Tools Stack

| Category | Tool | Description |
| :--- | :--- | :--- |
| **Window Manager** | [Hyprland](https://hyprland.org/) | Dynamic tiling Wayland compositor (`hypridle`, `hyprlock`, `hyprpaper`, `pyprland`, `hyprshot`) |
| **Status Bar** | [Waybar](https://github.com/Alexays/Waybar) | Highly customizable Wayland bar with media, battery & volume scripts |
| **Application Launcher** | [Wofi](https://hg.sr.ht/~scoopta/wofi) / Rofi | Wayland application launcher and menu |
| **Terminals** | [Kitty](https://sw.kovidgoyal.net/kitty/) / [Ghostty](https://ghostty.org/) / Alacritty | Fast, GPU-accelerated terminal emulators |
| **Shells & Prompt** | [Zsh](https://www.zsh.org/) / Bash + [Starship](https://starship.rs/) | Fast shell setup with zoxide, fzf, cliphist, eza, and bat |
| **Editor** | [Neovim](https://neovim.io/) / [Zed](https://zed.dev/) / VS Code | LazyVim-powered Neovim with custom plugins, autocompletion & LSP |
| **Multiplexer** | [Tmux](https://github.com/tmux/tmux) | Terminal multiplexer with TPM (Tmux Plugin Manager) |
| **File Manager** | [Yazi](https://github.com/sxyazi/yazi) | Blazing fast terminal file manager |
| **Theming** | Noctalia | Dynamic theme switching across Kitty, Hyprland, Waybar & Neovim |
| **System Track** | [BlendOS](https://blendos.co/) / NixOS | Declarative system packages and environment configuration |

---

##  Repository Structure

```text
.
├── backgrounds/         # Curated wallpaper collection
├── bash/                # Bashrc, starship config, helper scripts & packages
├── bat/                 # Bat syntax highlighter themes
├── blendos/             # BlendOS declarative system configuration (system.yaml)
├── ghostty/             # Ghostty terminal configuration & themes
├── hypr/                # Hyprland compositor, hyprlock, hypridle, keybindings
├── hyprshot/            # Hyprshot screenshot utility settings
├── kitty/               # Kitty configuration & color themes (Noctalia, Rose-Pine, Nord)
├── nixos/               # NixOS flake, system & home configurations
├── nvim/                # Neovim (LazyVim) IDE configuration
├── scripts/             # System utilities (sync_projects, dockerctl, cleanup, etc.)
├── tmux/                # Tmux config (.tmux.conf) and TPM setup
├── waybar/              # Waybar layouts, CSS styling, and helper scripts
├── wofi/                # Wofi application launcher styling
├── yazi/                # Yazi file manager configuration, keymaps & flavor themes
├── zed/                 # Zed editor settings
├── zsh/                 # Zsh configuration and Starship prompt setup
├── .stowrc              # GNU Stow target & ignore rules
├── install.sh           # Automated installation script
└── config.yaml          # Global environment settings
```

---

##  Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/ShaharyarShakir/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Automatic Setup (Recommended)
Run the automated installation script to install dependencies, link configurations via GNU Stow, and setup devbox:

```bash
chmod +x install.sh
./install.sh
```

### 3. Manual Stow Symlinking
If you prefer to manage symlinks manually with [GNU Stow](https://www.gnu.org/software/stow/):

```bash
# Symlink all configurations to ~/.config (configured via .stowrc)
stow --adopt .

# Or link specific configurations individually
stow -t ~/.config nvim kitty hypr waybar yazi ghostty tmux
```

---

##  System Declarations

- **BlendOS**: Apply declarative system and AUR packages defined in `blendos/system.yaml`:
  ```bash
  sudo blendos-track sync blendos/system.yaml
  ```
- **NixOS**: Rebuild system flake configuration from `nixos/`:
  ```bash
  sudo nixos-rebuild switch --flake ~/dotfiles/nixos/#default
  ```

---

##  Handy Utility Scripts

Located in the `scripts/` directory:

- **`scripts/tmux-project.sh`**: Interactive project session manager for Tmux.
- **`scripts/sync_projects.sh`**: Project sync and backup utility.
- **`scripts/dockerctl`**: Docker container management helper.
- **`scripts/cleanup.sh`**: System package and cache cleanup utility.
- **`scripts/cleanup_modules.sh`**: Clean up dangling `node_modules` across development directories.

---

##  Themes & Customization

The configuration integrates dynamic theming with **Noctalia** and supports multiple built-in color schemes:
- **Noctalia**: Dynamically adapts Kitty, Waybar, and Hyprland styling.
- **Rose Pine & Tokyo Night**: Integrated into Ghostty, Kitty, Bat, and Neovim.
- **Starship**: Synchronized prompts for both `bash` and `zsh`.
