local opt = vim.opt -- for conciseness

-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- line wrapping
opt.wrap = false -- disable line wrapping

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = true -- highlight the current cursor line

-- appearance

-- turn on termguicolors for nightfly colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

-- reload files changed outside of Neovim, such as edits made by opencode
opt.autoread = true
local autoread_group = vim.api.nvim_create_augroup("AutoReadExternalChanges", { clear = true })
local function check_external_changes()
  -- Avoid interrupting typing, command entry, or an active dialog.
  local mode = vim.api.nvim_get_mode().mode
  if mode ~= "n" and mode ~= "t" then
    return
  end

  local checked_buffers = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if not checked_buffers[buf]
      and vim.bo[buf].buftype == ""
      and not vim.bo[buf].modified
      and vim.api.nvim_buf_get_name(buf) ~= "" then
      checked_buffers[buf] = true
      vim.cmd("checktime " .. buf)
    end
  end
end

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "InsertLeave", "TermClose", "TermLeave" }, {
  group = autoread_group,
  callback = check_external_changes,
})

-- Focus events are not reliable across tmux panes or separate terminal windows.
local autoread_timer = vim.uv.new_timer()
autoread_timer:start(1000, 1000, vim.schedule_wrap(check_external_changes))
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = autoread_group,
  once = true,
  callback = function()
    autoread_timer:stop()
    autoread_timer:close()
  end,
})

-- Solid block in normal/visual/cmd, bar in insert, NO blinking anywhere
vim.opt.guicursor = table.concat({
	"n-v-c-sm:block",
	"i-ci-ve:ver25",
	"r-cr-o:hor20",
	"a:blinkwait0-blinkon0-blinkoff0", -- <- no blink
}, ",")
