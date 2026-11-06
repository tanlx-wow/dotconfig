# OpenCode configuration

- `opencode.json`: providers, plugins, and permissions.
- `cli.json`: editable OpenCode V2 terminal UI preferences.

OpenCode reads UI preferences from `~/.config/opencode/cli.json` (or
`$XDG_CONFIG_HOME/opencode/cli.json` when set). If that directory is already
linked to this repository's `opencode/` directory, editing `cli.json` here is
enough. Otherwise, link or copy this file into the active configuration
directory after checking for an existing file; preserve any existing settings.

Valid changes reload automatically. You can also press **Ctrl+P → Open settings**.
Keep this file as JSON without comments; its schema provides editor completion.

## Common preferences

| Setting | Choices |
| --- | --- |
| `theme.name` | Built-in or custom theme name; currently `tokyonight` |
| `theme.mode` | `system`, `dark`, `light` |
| `tabs.mode` | `auto`, `on`, `off` |
| `tabs.scope` | `cwd` (per directory), `global` |
| `tabs.layout` | `horizontal`, `vertical` |
| `tabs.indicators` | `status`, `numbers` |
| `session.sidebar` | `auto`, `hide` |
| `session.thinking` | `show`, `hide` |
| `session.markdown` | `rendered`, `source` |
| `session.new_location` | `launch`, `inherit` |
| `prompt.paste` | `compact`, `full` |
| `diffs.view` | `auto`, `split`, `unified` |
| `terminal.copy` | `select`, `manual` |

`animations`, `mouse`, `scroll.acceleration`, `session.scrollbar`,
`session.tps`, `attention.notifications`, and `attention.sound` accept `true`
or `false`. Permission prompts remain enabled via `session.permissions`.

Full reference: <https://opencode.ai/v2/docs/cli/config>
