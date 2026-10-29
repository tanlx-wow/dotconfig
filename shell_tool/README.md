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
swift ~/.config/shell_tool/tilt_window_arg.swift left
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
| `reset` | | Resize to 40% of usable screen width and 50% of usable screen height, then center. WezTerm uses its native reset instead; see below. |
| `center` | | Resize to 40% of usable screen width and 50% of usable screen height, then center. |

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
```

### Layout and animation

- Each window stays on the screen containing the largest part of its current frame.
- Tiled and maximized layouts use 16-point outer margins; half-screen layouts also leave a 16-point middle gap.
- Front-window changes animate over 0.32 seconds. With macOS **Reduce Motion** enabled, changes apply immediately.
- Applications can enforce their own minimum sizes, so the final size may differ from the requested layout.

### WezTerm reset

When WezTerm is frontmost, `reset` sends **Control + Option + R**, waits for its native size reset, and centers the resulting window without resizing it again. This requires the repository's WezTerm shortcut for `ResetFontAndWindowSize`.

`center` uses the standard 40%-width, 50%-height layout even in WezTerm.

## All-window commands

```bash
# Move every eligible window to the left half of its own screen.
swift tilt_window_arg.swift all-half

# Maximize every eligible window on its own screen.
swift tilt_window_arg.swift all-max
```

These commands apply immediately, without animation. They target windows belonging to non-hidden, regular applications with a bundle identifier.

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

## Alfred integration

The repository's Alfred window-management workflow calls this script with the corresponding command. For example:

```bash
swift ~/.config/shell_tool/tilt_window_arg.swift all-max
```
