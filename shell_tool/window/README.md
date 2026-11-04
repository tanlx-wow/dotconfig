# Window Management Script

`tilt_window_arg.swift` manages macOS windows from the command line. It combines front-window tiling, resizing all eligible windows, and hiding other apps.

## Requirements

- macOS with Swift available (for example, through Xcode Command Line Tools).
- Accessibility permission for the terminal or launcher running resize commands. If prompted, enable it in **System Settings → Privacy & Security → Accessibility**.

## Usage

From this directory:

```bash
swift tilt_window_arg.swift <command>
```

From anywhere, if this directory is linked to `~/.config/shell_tool`:

```bash
swift ~/.config/shell_tool/window/tilt_window_arg.swift left
```

Omitting the command runs `reset`. Commands are case-insensitive. Unknown commands or extra arguments print usage and exit with an error.

## Front-window commands

These commands affect only the focused window of the frontmost application.

| Command | Aliases | Action |
| --- | --- | --- |
| `left` | | Fill the left half of the usable screen. |
| `right` | | Fill the right half of the usable screen. |
| `up` | `top` | Fill the top half of the usable screen. |
| `bottom` | `down` | Fill the bottom half of the usable screen. |
| `max` | `maximize` | Fill the usable screen with margins; does not enter macOS full-screen mode. |
| `plus` | | Increase width and height by 20%, capped to the usable screen, and center the window. |
| `reset` | | Resize to 40% of usable screen width and 50% of usable screen height, then center. WezTerm restores its configured terminal grid instead; see below. |
| `center` | | Center on the current screen without changing the window size. |

Examples:

```bash
# Tile the focused window to the left half.
swift tilt_window_arg.swift left

# Tile it to the top half.
swift tilt_window_arg.swift top

# Maximize it with margins.
swift tilt_window_arg.swift max

# Grow it by 20% and center it.
swift tilt_window_arg.swift plus

# Restore the default size and center it.
swift tilt_window_arg.swift reset

# Center the focused window without resizing it.
swift tilt_window_arg.swift center
```

### Layout and animation

- Each window stays on the screen containing the largest part of its current frame.
- Tiled and maximized layouts use 16-point outer margins; half-screen layouts also leave a 16-point middle gap.
- Front-window changes animate over 0.15 seconds. With macOS **Reduce Motion** enabled, changes apply immediately.
- Applications can enforce their own minimum sizes, so the final size may differ from the requested layout.

### WezTerm reset

Press **Option + R** to reset through Alfred's global shortcut, which runs `window-tool reset`. Keep this Alfred hotkey enabled for WezTerm (do not exclude it under **Related Apps**). WezTerm only binds **Command + Control + Option + R**, which also works manually.

When WezTerm is frontmost, `reset` waits for the original hotkey to be released (up to two seconds), then sends **Command + Control + Option + R** directly to the WezTerm process using an isolated event source and a 20 ms key press. If focus changes while waiting, it cancels. The repository's WezTerm callback measures the current cells and padding, then calls the compiled window tool to animate resizing and centering together. It restores `initial_cols` × `initial_rows` (currently **120 × 42**) without changing the current font size. There is no native resize before the animation.

Build the executable after changing the Swift source, and reload the WezTerm configuration after changing the callback. The pixel-to-window conversion assumes this repository's borderless, hidden-tab-bar configuration. Split panes share the restored overall tab grid; individual panes are not each resized to 120 × 42. macOS may constrain a grid that is too large for the screen at the current font size.

The generated shortcut includes both the generic Option flag and the left-Option device flag (`0x20`). WezTerm's macOS input handler requires a side-specific Option flag; the generic flag alone is not recognized as Alt.

`center` only moves the window, including in WezTerm; it does not reset the grid or font.

## All-window commands

```bash
# Move every eligible window to the left half of its own screen.
swift tilt_window_arg.swift all-half

# Maximize every eligible window on its own screen.
swift tilt_window_arg.swift all-max
```

These commands animate all eligible windows together on a shared 0.15-second timeline, using the same easing as front-window commands. With macOS **Reduce Motion** enabled, changes apply immediately. Accessibility calls still update each window in turn within each frame, so many windows or slow applications can reduce smoothness and extend the total time. They target windows belonging to non-hidden, regular applications with a bundle identifier.

Both commands skip these applications:

- Finder
- System Settings
- Cisco Secure Client
- Microsoft Teams (`com.microsoft.teams2`)
- TeamViewer

`all-half` additionally skips Microsoft Outlook, EndNote, and minimized windows. `all-max` retains the original maximize-all behavior and does not explicitly skip minimized windows.

## Hide other apps

```bash
swift tilt_window_arg.swift hide-others
```

This keeps the frontmost application and uses on-screen window sampling to decide which other apps to preserve. It samples every 50 points, checking windows from front to back. Other apps are kept when their windows expose sampled areas and are not considered stacked behind the frontmost window.

A window is considered stacked when its overlap with the first standard window covers more than half of that front window's area. This heuristic helps preserve side-by-side layouts while hiding overlapping background apps.

Hiding applies to whole applications, not individual windows. This command does not require the script's Accessibility permission check.

## Help

```bash
swift tilt_window_arg.swift --help
```

`-h` and `help` also display usage.

## Compile and use with Alfred

Build the optimized executable once (and rebuild after changing the Swift source):

```bash
bash ~/.config/shell_tool/window/build.sh
```

The executable is saved to `shell_tool/bin/window-tool`, which is ignored by Git.
The repository's Alfred workflow runs it directly, avoiding Swift compilation on each trigger:

```bash
"$HOME/.config/shell_tool/bin/window-tool" all-max
```
