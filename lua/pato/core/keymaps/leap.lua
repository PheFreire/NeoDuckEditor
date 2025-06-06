-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Leap)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set("n", "<leader>sw", function()
    local target_windows = require('leap.util').get_enterable_windows()
    local targets = {}
    for _, win in ipairs(target_windows) do
      local wininfo = vim.fn.getwininfo(win)[1]
      local pos = { wininfo.topline, 1 }  -- customize the position of the label here
      table.insert(targets, { pos = pos, wininfo = wininfo })
    end

    require('leap').leap {
      target_windows = target_windows, targets = targets,
      action = function (t) vim.api.nvim_set_current_win(t.wininfo.winid) end
    }
  end, { noremap = false, silent = true }
)
