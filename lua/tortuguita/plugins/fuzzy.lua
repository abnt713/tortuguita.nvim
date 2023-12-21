local fuzzy = {}

function fuzzy.base(cfg)
  return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-file-browser.nvim'
    },
    config = function()
      require('telescope').setup {
        extensions = {
          file_browser = {
            path = "%:p:h",
            cwd_to_path = true
          }
        }
      }

      local keymap = vim.api.nvim_set_keymap
      local mapdefaults = { noremap = true }

      keymap('n', cfg.map['files'], "<cmd>Telescope find_files<CR>", mapdefaults)
      keymap('n', cfg.map['grep'], "<cmd>Telescope live_grep<CR>", mapdefaults)
      keymap('n', cfg.map['buffers'], "<cmd>Telescope buffers<CR>", mapdefaults)
    end
  }
end

function fuzzy.file_explorer(cfg)
  return {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require('telescope').load_extension 'file_browser'
      local keymap = vim.api.nvim_set_keymap
      local mapdefaults = { noremap = true }
      keymap('n', cfg.map['file_browser'], "<cmd>Telescope file_browser<CR>", mapdefaults)
    end
  }
end

return fuzzy
