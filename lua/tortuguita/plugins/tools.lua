local tools = {}

function tools.git(cfg)
  return {
    "tpope/vim-fugitive",
    config = function()
      local keymap = vim.api.nvim_set_keymap
      local mapdefaults = { noremap = true }
      keymap('n', cfg.map.panel, '<cmd>:Git<CR>', mapdefaults)
      keymap('n', cfg.map.commit, '<cmd>:Git commit<CR>', mapdefaults)
      keymap('n', cfg.map.blame, '<cmd>:Git blame<CR>', mapdefaults)
    end
  }
end

function tools.colorizer(cfg)
  return {
    "chrisbra/colorizer",
    cmd = "ColorToggle",
    init = function()
      local keymap = vim.api.nvim_set_keymap
      local mapdefaults = { noremap = true }
      keymap('n', cfg.map.colorize, '<cmd>ColorToggle<CR>', mapdefaults)
    end
  }
end

function tools.md_preview(cfg)
  return {
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup({
        app = cfg.app
      })
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  }
end

return tools
