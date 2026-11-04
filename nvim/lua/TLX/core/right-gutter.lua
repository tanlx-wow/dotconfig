local M = {}

-- One blank split column plus its separator reserves two screen columns.
-- The scrollbar is positioned over the blank column, outside the text window.
M.scrollbar_placement = { relative = "window", anchor = "NE", col = 2 }

local gutters = {}
local enabled = true
local pending = false
local updating = false
local gutter_buf

local function eligible(win)
  if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_config(win).relative ~= "" then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  -- Keep the scrollbar outside the text even after :set nowrap.
  return vim.bo[buf].buftype == ""
end

local function close_gutter(owner)
  local gutter = gutters[owner]
  gutters[owner] = nil
  if gutter and vim.api.nvim_win_is_valid(gutter) then
    vim.api.nvim_win_close(gutter, true)
  end
end

local function get_buffer()
  if not gutter_buf or not vim.api.nvim_buf_is_valid(gutter_buf) then
    gutter_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[gutter_buf].filetype = "right_gutter"
    vim.bo[gutter_buf].bufhidden = "hide"
    vim.bo[gutter_buf].modifiable = false
  end
  return gutter_buf
end

local function create_gutter(owner)
  local gutter = vim.api.nvim_open_win(get_buffer(), false, {
    split = "right",
    win = owner,
    width = 1,
    noautocmd = true,
  })
  gutters[owner] = gutter
  local wo = vim.wo[gutter]
  wo.number = false
  wo.relativenumber = false
  wo.signcolumn = "no"
  wo.foldcolumn = "0"
  wo.statuscolumn = ""
  wo.winbar = ""
  wo.statusline = " "
  wo.cursorline = false
  wo.cursorcolumn = false
  wo.colorcolumn = ""
  wo.wrap = false
  wo.winfixwidth = true
  wo.winfixbuf = true
  wo.fillchars = "eob: "
  wo.winhighlight = "Normal:Normal,NormalNC:Normal,EndOfBuffer:Normal,WinSeparator:Normal"
  return gutter
end

local function reconcile()
  if updating then
    return
  end
  updating = true
  local ok, err = pcall(function()
    for owner in pairs(gutters) do
      if not enabled or not eligible(owner) then
        close_gutter(owner)
      end
    end
    if not enabled then
      return
    end
    -- Only touch the visible tab; other tabs are refreshed on TabEnter.
    for _, owner in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if eligible(owner) then
        local gutter = gutters[owner]
        if not gutter or not vim.api.nvim_win_is_valid(gutter) then
          gutters[owner] = nil
          -- A text column, a separator, and a gutter must all fit.
          if vim.api.nvim_win_get_width(owner) >= 3 then
            gutter = create_gutter(owner)
          else
            gutter = nil
          end
        end
        if gutter then
          local pos = vim.api.nvim_win_get_position(owner)
          local gutter_pos = vim.api.nvim_win_get_position(gutter)
          if gutter_pos[1] ~= pos[1]
            or gutter_pos[2] ~= pos[2] + vim.api.nvim_win_get_width(owner) + 1
            or vim.api.nvim_win_get_height(gutter) ~= vim.api.nvim_win_get_height(owner) then
            vim.fn.win_splitmove(gutter, owner, { vertical = true, rightbelow = true })
          end
          if vim.api.nvim_win_get_width(gutter) ~= 1 then
            vim.api.nvim_win_set_width(gutter, 1)
          end
        end
      end
    end
  end)
  updating = false
  if not ok then
    vim.notify("Right gutter: " .. tostring(err), vim.log.levels.WARN)
  end
end

local function schedule_refresh()
  if pending or updating then
    return
  end
  pending = true
  vim.schedule(function()
    pending = false
    reconcile()
  end)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("RightGutter", { clear = true })
  vim.api.nvim_create_autocmd({ "BufWinEnter", "WinNew", "WinClosed", "TabEnter", "WinResized", "VimResized" }, {
    group = group,
    callback = schedule_refresh,
  })
  vim.api.nvim_create_autocmd("OptionSet", {
    group = group,
    pattern = { "wrap", "buftype" },
    callback = schedule_refresh,
  })
  vim.api.nvim_create_autocmd("WinEnter", {
    group = group,
    callback = function()
      local current = vim.api.nvim_get_current_win()
      for owner, gutter in pairs(gutters) do
        if current == gutter and vim.api.nvim_win_is_valid(owner) then
          vim.api.nvim_set_current_win(owner)
          break
        end
      end
    end,
  })
  -- Do not leave the blank split behind when :q closes its editing window.
  vim.api.nvim_create_autocmd("QuitPre", {
    group = group,
    callback = function()
      updating = true
      close_gutter(vim.api.nvim_get_current_win())
      updating = false
    end,
  })
  vim.api.nvim_create_user_command("RightGutterToggle", function()
    enabled = not enabled
    reconcile()
    local scrollbar = package.loaded["scrollbar"]
    if scrollbar then
      if enabled then
        scrollbar.show()
      else
        -- Its placement is outside the text window; hide it without a gutter.
        scrollbar.hide()
      end
    end
  end, { desc = "Toggle the reserved right-hand scrollbar gutter", force = true })
  schedule_refresh()
end

return M
