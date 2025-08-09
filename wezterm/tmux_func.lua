-- ./tmux_func.lua
local wezterm = require("wezterm")
local act = wezterm.action

return {
	leader = { key = "a", mods = "CTRL" }, -- like tmux's Ctrl+b

	keys = {
		-- Split panes
		{ key = "|", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

		-- Move between panes
		{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
		{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
		{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
		{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },

		-- Tabs
		{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
		{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },

		-- Workspaces (like tmux sessions)
		{ key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "WORKSPACES" }) },

		-- Attach/switch to a workspace (like tmux attach -t <name>)
		{
			key = "S",
			mods = "LEADER",
			action = act.PromptInputLine({
				description = "Workspace to attach/switch:",
				action = wezterm.action_callback(function(win, pane, line)
					if line and #line > 0 then
						win:perform_action(act.SwitchToWorkspace({ name = line }), pane)
					end
				end),
			}),
		},
	},
}
