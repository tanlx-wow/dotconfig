local M = {}

function M.setup(capabilities)
  local marksman_cmd = vim.fn.exepath("marksman")
  if marksman_cmd == "" then
    return
  end

  local marksman_capabilities = vim.deepcopy(capabilities)
  if marksman_capabilities.workspace then
    marksman_capabilities.workspace.configuration = false
    if marksman_capabilities.workspace.didChangeConfiguration then
      marksman_capabilities.workspace.didChangeConfiguration.dynamicRegistration = false
    end
  end

  vim.lsp.config("marksman", {
    capabilities = marksman_capabilities,
    cmd = { marksman_cmd, "server" },
    filetypes = { "markdown" },
    root_markers = { ".marksman.toml", ".git" },
    root_dir = function(bufnr, on_dir)
      local path = vim.api.nvim_buf_get_name(bufnr)
      local root = vim.fs.root(path, { ".marksman.toml", ".git" })
      on_dir(root or vim.fs.dirname(path))
    end,
  })
  vim.lsp.enable("marksman")
end

return M
