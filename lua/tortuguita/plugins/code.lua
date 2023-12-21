local code = {}

local ReviveIndex = 0

function code.treesitter()
  return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'go',
          'markdown',
          'python',
          'lua',
          'c',
          'cpp',
        },
        highlight = {
          enable = true,
          is_supported = function()
            local longline = vim.fn.strwidth(vim.fn.getline('.')) > 300
            if longline then
              return false
            end
            local longfile = vim.fn.getfsize(vim.fn.expand('%')) > 1024 * 1024
            if longfile then
              return false
            end
            return true
          end
        }
      }
    end,
  }
end

function code.autocomplete()
  return {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/vim-vsnip"
    },
    config = function()
      vim.o.completeopt = 'menu,menuone,noselect'
      local cmp = require('cmp')
      cmp.setup {
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered()
        },
        mapping = {
          ['<CR>'] = cmp.mapping.confirm { select = true },
          ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if (cmp.visible()) then
              cmp.select_next_item()
              return
            end
            fallback()
          end, { 'i', 's' }
          ),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible then
              cmp.select_prev_item()
              return
            end
            fallback()
          end, { 'i', 's' }),
        },
        sources = cmp.config.sources {
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'vsnip' }
        }, {
        { name = 'buffer' }
      }
      }
    end,
  }
end

function code.linter(cfg)
  return {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = {
      'williamboman/mason.nvim',
      'jay-babu/mason-null-ls.nvim'
    },
    config = function()
      local null_ls = require('null-ls')

      local keymap = vim.api.nvim_set_keymap
      local mapdefaults = { noremap = true }
      keymap('n', cfg.map.toggle_revive, "<cmd>lua require('null-ls').toggle({name = 'revive'})<CR>", mapdefaults)

      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = 'ConfigLocalFinished',
        callback = function()
          require('null-ls').setup {
            sources = {
              null_ls.builtins.diagnostics.revive,
              null_ls.builtins.formatting.goimports,
              null_ls.builtins.formatting.gofumpt,
            }
          }

          vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = { "*.go" },
            callback = function()
              local srcs = require('null-ls.sources').get_all()

              if (ReviveIndex ~= 0) then
                srcs[ReviveIndex].generator._failed = false
                return
              end

              for i, source in pairs(srcs) do
                if (source.name == "revive") then
                  ReviveIndex = i
                  source.generator._failed = false
                  return
                end
              end
            end
          })
          require('mason-null-ls').setup { automatic_installation = true }
        end
      })
    end
  }
end

return code
