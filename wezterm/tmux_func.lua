-- ./tmux_func.lua
local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- tmux-like leader
M.leader = { key = "b", mods = "CTRL" }

-- internal: command that renders a tiny status line in a pane
local function status_cmd()
	return [[bash -lc '
    ws=$(wezterm cli list --workspaces 2>/dev/null | sed -n "s/^\* //p")
    user=$USER
    host=$(hostname -s)
    while true; do
      printf "\033[2J\033[H"   # clear + home
      # segments (ANSI bg/fg)
      printf "\033[48;2;91;208;255m\033[30m  workspace \033[0m"
      printf "\033[48;2;123;228;149m\033[30m  %s \033[0m" "$ws"
      printf "\033[48;2;106;160;255m\033[30m  %s@%s \033[0m" "$user" "$host"
      printf "\033[48;2;255;209;102m\033[30m  $(date +%H:%M:%S) \033[0m"
      printf "\033[48;2;162;119;255m\033[30m  $(date +%d-%b-%y) \033[0m\n"
      sleep 1
    done
  ']]
end

-- toggle a thin bottom pane that shows the status line
function M.toggle_status_pane(window)
	local tab = window:active_tab()

	-- if a pane titled [status] exists, close it
	for _, p in ipairs(tab:panes()) do
		if p:get_title() == "[status]" then
			window:perform_action(act.ActivatePane({ id = p:pane_id() }), p)
			window:perform_action(act.CloseCurrentPane({ confirm = false }), p)
			return
		end
	end

	-- otherwise create it
	local new_pane = tab:split({
		direction = "Down",
		size = 0.08, -- ~8% height; tweak as you like
		command = { args = { "bash", "-lc", status_cmd() } },
	})
	window:perform_action(act.SetPaneTitle({ title = "[status]" }), new_pane)
	window:perform_action(act.ActivatePaneDirection("Up"), new_pane)
end

-- keybindings (tmux-like)
M.keys = {
	-- splits
	{ key = "|", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- pane navigation
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

	-- tabs
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },

	-- workspaces
	{ key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "WORKSPACES" }) },

	-- attach/switch to workspace (tmux attach -t <name>)
	{
		key = "S",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Workspace to attach/switch:",
			action = wezterm.action_callback(function(win, pane, line)
				if line and #line > 0 then
					win:perform_action(act.SwitchToWorkspace({ name = line }), pane)
					win:toast_notification("WezTerm", "Workspace: " .. line, nil, 2000)
				end
			end),
		}),
	},

	-- TOGGLE status bar (bottom pane)
	{
		key = "b",
		mods = "LEADER",
		action = wezterm.action_callback(function(win, pane)
			M.toggle_status_pane(win)
		end),
	},
}

return M
