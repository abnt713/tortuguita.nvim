local lang = {}

function lang.cpp_toggle(cfg)
  return {
    'jakemason/ouroboros.nvim',
    config = function()
      vim.api.nvim_create_autocmd({ 'Filetype' }, {
        pattern = { 'c', 'cpp' },
        callback = function()
          local mapdefaults = { noremap = true }
          vim.api.nvim_buf_set_keymap(0, 'n', cfg.map.toggle_header, '<cmd>:Ouroboros<CR>', mapdefaults)
        end
      })
    end
  }
end

function lang.go_impl(cfg)
  return {
    "edolphin-ydf/goimpl.nvim",
    ft = "go",
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-lua/popup.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      require('telescope').load_extension('goimpl')
      local keymap = vim.api.nvim_set_keymap
      local mapdefaults = { noremap = true }
      keymap('n', cfg.map.show_impl, '<cmd>lua require("telescope").extensions.goimpl.goimpl({})<CR>', mapdefaults)
    end
  }
end

return lang
