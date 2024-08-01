return {
  'ggandor/leap.nvim',
  name = 'leap',
  config = function()
    local leap = require('leap')
    -- leap.add_default_mappings()
    leap.opts.case_sensitive = true
  end,
}
