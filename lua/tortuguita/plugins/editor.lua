local editor = {}

function editor.project_config()
  return {
    'klen/nvim-config-local',
    config = function()
      require('config-local').setup {}
    end
  }
end

function editor.assets_manager(border)
  return {
    "williamboman/mason.nvim",
    build = ':MasonUpdate',
    config = function()
      require('mason').setup {
        ui = {
          border = border
        }
      }
    end
  }
end

function editor.commentary()
  return "tpope/vim-commentary"
end

function editor.hardmode()
  return {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    opts = {}
  }
end

function editor.netrw()
  return {
    'prichrd/netrw.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    config = function()
      require('netrw').setup({
        use_devicons = true
      })
    end
  }
end

function editor.pencil()
  return {
    "preservim/vim-pencil",
    init = function()
      vim.g["pencil#wrapModeDefault"] = "soft"
    end,
  }
end

function editor.zen()
  return {
    'folke/zen-mode.nvim',
  }
end

return editor
