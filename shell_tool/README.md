# Shell tools

Scripts are grouped by purpose:

| Folder | Contents |
| --- | --- |
| `window/` | Swift window manager, build script, and [command documentation](window/README.md). |
| `bin/` | Locally compiled executables (ignored by Git). |
| `macos/` | App IDs, per-app appearance, and workspace detection. |
| `notes/` | Note symlink updates and filesystem watcher. |
| `filesystem/` | Symlink inventory and reconstruction. |
| `git/` | Notebook branch cloning. |
| `linux/` | VS Code CLI updater. |

## Build the window tool

```bash
bash ~/.config/shell_tool/window/build.sh
```

Then run it directly from Alfred or a terminal:

```bash
"$HOME/.config/shell_tool/bin/window-tool" left
```

Rebuild after editing `window/tilt_window_arg.swift`. Window animations take 0.15 seconds.
