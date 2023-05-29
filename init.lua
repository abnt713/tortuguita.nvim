-- Default settings
vim.g.gotags = ''
vim.g.dapleader = '\\'

-- Basic options
vim.g.mapleader = " "

vim.wo.relativenumber = true
vim.wo.number = true
vim.wo.signcolumn = 'yes'
vim.wo.cursorline = true
vim.opt.colorcolumn = '80'

local indent_size = 4
vim.bo.shiftwidth = indent_size
vim.bo.smartindent = true
vim.bo.tabstop = indent_size
vim.bo.softtabstop = indent_size

vim.cmd 'au BufRead,BufNewFile *.md,*.txt setlocal textwidth=80'

-- Mapping helpers
local keymap = vim.api.nvim_set_keymap
local mapdefaults = { noremap = true }
keymap('i', '<C-c>', '<ESC>', mapdefaults)

-- Index used to fix revive weird disable on error.
ReviveIndex = 0


-- File Reference function, very useful
File_reference = function()
  local fileref = vim.fn.expand('%') .. ':' .. vim.fn.line('.')
  vim.fn.setreg('+', fileref)
  print(fileref, 'copied to clipboard')
end
keymap('n', '<Leader>fr', '<cmd>lua File_reference()<CR>', mapdefaults)

-- Installing Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setting up plugins
local plugins = {
  -- Theme
  {
    "Shatur/neovim-ayu",
    lazy = false,
    priority = 1000,
    config = function()
      require('ayu').colorscheme()
    end,
  },

  -- Safe local configuration loading
  {
    'klen/nvim-config-local',
    config = function()
      require('config-local').setup {}
    end
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require('lualine').setup({
        theme = 'ayu_dark'
      })
    end,
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
  },

  -- Mason
  {
    "williamboman/mason.nvim",
    build = ':MasonUpdate',
    config = function()
      require('mason').setup {
        ui = {
          border = 'rounded'
        }
      }
    end
  },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-file-browser.nvim'
    },
    config = function()
      require('telescope').setup {
        extensions = {
          file_browser = {}
        }
      }

      require('telescope').load_extension 'file_browser'

      keymap('n', '<Leader>ff', "<cmd>Telescope find_files<CR>", mapdefaults)
      keymap('n', '<Leader>ft', "<cmd>Telescope file_browser<CR>", mapdefaults)
      keymap('n', '<Leader>fg', "<cmd>Telescope live_grep<CR>", mapdefaults)
      keymap('n', '<Leader>fb', "<cmd>Telescope buffers<CR>", mapdefaults)
    end
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'go',
          'php',
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
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim'
    },
    config = function()
      local border = 'rounded'
      local handlers = {
        ["textDocument/hover"] = vim.lsp.with(
          vim.lsp.handlers.hover, { border = border }
        ),
        ["textDocument/signatureHelp"] = vim.lsp.with(
          vim.lsp.handlers.signature_help, { border = border }
        ),
      }
      local cmpcaps = require('cmp_nvim_lsp').default_capabilities()
      local with_cmpcaps = function(settings)
        settings["capabilities"] = cmpcaps
        settings["handlers"] = handlers
        return settings
      end

      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = 'ConfigLocalFinished',
        callback = function()
          require('mason-lspconfig').setup { automatic_installation = true }
          -- List of servers
          ---- CPP
          require('lspconfig').ccls.setup(with_cmpcaps({}))
          ---- PHP
          require('lspconfig').intelephense.setup(with_cmpcaps({}))
          ---- Lua
          require('lspconfig').lua_ls.setup(with_cmpcaps({
            settings = {
              Lua = {
                diagnostics = {
                  globals = { 'vim' }
                }
              }
            }
          }))
          ---- Go
          local gotags_flag = '-tags=' .. vim.g.gotags
          require('lspconfig').gopls.setup(with_cmpcaps({
            settings = {
              gopls = {
                buildFlags = { gotags_flag },
                env = {
                  GOFLAGS = gotags_flag
                },
                analyses = {
                  unusedparams = true
                }
              }
            }
          }))
          -- JS / TS
          vim.g.markdown_fenced_languages = {
            "ts=typescript"
          }
          require('lspconfig').denols.setup(with_cmpcaps({}))

          -- Reloading the buffer to attach the client
          -- Yeah, kinda hacky but I really wanna use specific configs.
          if (vim.fn.expand('%') ~= '') then
            vim.cmd ':edit'
          end

          return true
        end
      })

      -- Autoformat on save
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '',
        command = 'silent! lua vim.lsp.buf.format()'
      })

      -- Mappings
      keymap('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', mapdefaults)
      keymap('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', mapdefaults)
      keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', mapdefaults)
      keymap('n', 'gm', '<cmd>lua vim.lsp.buf.rename()<CR>', mapdefaults)
      keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', mapdefaults)
      keymap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', mapdefaults)
      keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', mapdefaults)
      keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', mapdefaults)
      keymap('n', 'gl', '<cmd>lua vim.diagnostic.open_float(nil, {focus=false})<CR>', mapdefaults)
      keymap('n', 'gn', '<cmd>lua vim.diagnostic.goto_next()<CR>', mapdefaults)
      keymap('n', 'gp', '<cmd>lua vim.diagnostic.goto_prev()<CR>', mapdefaults)
    end
  },

  -- CPP Toggle
  {
    'jakemason/ouroboros.nvim',
    config = function()
      vim.api.nvim_create_autocmd({ 'Filetype' }, {
        pattern = { 'c', 'cpp' },
        callback = function()
          vim.api.nvim_buf_set_keymap(0, 'n', 'gt', '<cmd>:Ouroboros<CR>', mapdefaults)
        end
      })
    end
  },

  -- Autocomplete
  {
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
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      'williamboman/mason.nvim',
      'jayp0521/mason-nvim-dap.nvim'
    },
    config = function()
      local dapkey = function(combo)
        return vim.g.dapleader .. combo
      end

      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = 'ConfigLocalFinished',
        callback = function()
          local dap = require('dap')
          local gotags_flag = '-tags=' .. vim.g.gotags
          dap.configurations.go = {
            {
              type = 'delve',
              name = "Debug",
              request = "launch",
              program = "${file}",
              buildFlags = gotags_flag,
            },
            {
              type = 'delve',
              name = "Debug Package",
              request = "launch",
              program = "${fileDirname}",
              buildFlags = gotags_flag,
            },
            {
              type = 'delve',
              name = "Attach",
              mode = "local",
              request = "attach",
              processId = require("dap.utils").pick_process,
              buildFlags = gotags_flag,
            },
            {
              type = 'delve',
              name = "Debug test",
              request = "launch",
              mode = "test",
              program = "${file}",
              buildFlags = gotags_flag,
            },
            {
              type = 'delve',
              name = "Debug test (go.mod)",
              request = "launch",
              mode = "test",
              program = "./${relativeFileDirname}",
              buildFlags = gotags_flag,
            },
          }
          dap.adapters.delve = {
            type = "server",
            port = "${port}",
            executable = {
              command = "dlv",
              args = { "dap", "-l", "127.0.0.1:${port}" },
            },
            options = {
              initialize_timeout_sec = 20,
            },
          }

          require("mason-nvim-dap").setup()
          return true
        end
      })

      keymap("n", dapkey("c"), "<cmd>lua require('dap').continue()<CR>", mapdefaults)
      keymap("n", dapkey("r"), "<cmd>lua require('dap').repl.toggle()<CR>", mapdefaults)
      keymap("n", dapkey("b"), "<cmd>lua require('dap').toggle_breakpoint()<CR>", mapdefaults)
      keymap("n", dapkey("l"), "<cmd>lua require('dap').list_breakpoints(true)<CR>", mapdefaults)
      keymap("n", dapkey("<s-b>"), "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
        mapdefaults)
      keymap('n', dapkey("h"), "<cmd>lua require('dap.ui.widgets').hover()<CR>", mapdefaults)
    end
  },

  -- Indentline
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require('indent_blankline').setup {
        char = '¦',
        buftype_exclude = {
          'terminal',
          'checkhealth',
          'help',
          'lspinfo',
          'packer',
          'startup',
        },
        filetype_exclude = {
          'lazy',
          'mason',
        }
      }
    end,
  },

  -- Linting
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = {
      'williamboman/mason.nvim',
      'jay-babu/mason-null-ls.nvim'
    },
    config = function()
      local null_ls = require('null-ls')

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
  },

  -- Utilities
  "tpope/vim-commentary",
  {
    "tpope/vim-fugitive",
    config = function()
      keymap('n', '<Leader>gs', '<cmd>:Git<CR>', mapdefaults)
      keymap('n', '<Leader>gc', '<cmd>:Git commit<CR>', mapdefaults)
      keymap('n', '<Leader>gb', '<cmd>:Git blame<CR>', mapdefaults)
    end
  },
  {
    "airblade/vim-gitgutter",
    config = function()
      keymap('n', '<Leader>gp', '<cmd>GitGutterPrevHunk<CR>', mapdefaults)
      keymap('n', '<Leader>gn', '<cmd>GitGutterNextHunk<CR>', mapdefaults)
    end
  },
  {
    "chrisbra/colorizer",
    cmd = "ColorToggle",
    init = function()
      keymap('n', '<Leader>cc', '<cmd>ColorToggle<CR>', mapdefaults)
    end
  },
}

require("lazy").setup(plugins, { ui = { border = 'rounded' } })
