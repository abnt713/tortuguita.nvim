local ui = {}

function ui.colorscheme()
  return {
    "ofirgall/ofirkai.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd 'colorscheme ofirkai-darkblue'
    end
  }
end

function ui.statusline()
  return require('tortuguita.plugins.galaxyline').statusline()
end

function ui.indent_guides()
  return {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require('ibl').setup {
        indent = {
          char = '¦',
        },
        scope = {
          enabled = false,
        },
        exclude = {
          buftypes = {
            'terminal',
            'checkhealth',
            'help',
            'lspinfo',
            'packer',
            'startup',
          },
          filetypes = {
            'lazy',
            'mason',
          }
        },
      }
    end,
  }
end

function ui.gitgutter(cfg)
  return {
    "airblade/vim-gitgutter",
    config = function()
      local keymap = vim.api.nvim_set_keymap
      local mapdefaults = { noremap = true }
      keymap('n', cfg.map.prev_git_hunk, '<cmd>GitGutterPrevHunk<CR>', mapdefaults)
      keymap('n', cfg.map.next_git_hunk, '<cmd>GitGutterNextHunk<CR>', mapdefaults)
    end
  }
end

return ui
