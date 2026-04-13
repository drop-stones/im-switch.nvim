local M = {}

---Show an error notification.
---@param msg string
function M.error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "im-switch.nvim" })
end

---Show a warning notification.
---@param msg string
function M.warn(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = "im-switch.nvim" })
end

---Show an info notification.
---@param msg string
function M.info(msg)
  vim.notify(msg, vim.log.levels.INFO, { title = "im-switch.nvim" })
end

return M
