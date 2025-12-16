local M = {}

local function in_kitty()
  return vim.env.KITTY_WINDOW_ID ~= nil
end

local function kitty(args)
  vim.fn.jobstart(vim.list_extend({ "kitty", "@", "--to", "unix:/tmp/kitty" }, args), {
    detach = true,
  })
end

function M.zero()
  if not in_kitty() then return end
  kitty({ "set-spacing", "padding=0", "margin=0" })
  kitty({ "set-spacing", "padding-h=0", "padding-v=0", "margin-h=0", "margin-v=0" })
  kitty({ "set-window-border-width", "0" })
end

function M.restore()
  if not in_kitty() then return end
  kitty({ "set-spacing", "padding=0", "margin=0" })
  kitty({ "set-window-border-width", "0" })
end

return M

