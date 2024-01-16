local lsp = {}

function lsp.engine(cfg)
  return {
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

      local keymap = vim.api.nvim_set_keymap
      local mapdefaults = { noremap = true }

      -- Mappings
      keymap('n', cfg.map.code_action, '<cmd>lua vim.lsp.buf.code_action()<CR>', mapdefaults)
      keymap('n', cfg.map.hover_symbol, '<cmd>lua vim.lsp.buf.hover()<CR>', mapdefaults)
      keymap('n', cfg.map.goto_declaration, '<cmd>lua vim.lsp.buf.declaration()<CR>', mapdefaults)
      keymap('n', cfg.map.rename, '<cmd>lua vim.lsp.buf.rename()<CR>', mapdefaults)
      keymap('n', cfg.map.goto_definition, '<cmd>lua vim.lsp.buf.definition()<CR>', mapdefaults)
      keymap('n', cfg.map.signature_help, '<cmd>lua vim.lsp.buf.signature_help()<CR>', mapdefaults)
      keymap('n', cfg.map.references, '<cmd>lua vim.lsp.buf.references()<CR>', mapdefaults)
      keymap('n', cfg.map.goto_implementation, '<cmd>lua vim.lsp.buf.implementation()<CR>', mapdefaults)
      keymap('n', cfg.map.show_symbol_diagnostic, '<cmd>lua vim.diagnostic.open_float(nil, {focus=false})<CR>',
        mapdefaults)
      keymap('n', cfg.map.next_diagnostic, '<cmd>lua vim.diagnostic.goto_next()<CR>', mapdefaults)
      keymap('n', cfg.map.prev_diagnostic, '<cmd>lua vim.diagnostic.goto_prev()<CR>', mapdefaults)
    end
  }
end

function lsp.trouble(cfg)
  return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local keymap = vim.api.nvim_set_keymap
      local mapdefaults = { noremap = true }

      keymap('n', cfg.map.trouble_project, '<cmd>TroubleToggle workspace_diagnostics<CR>', mapdefaults)
      keymap('n', cfg.map.trouble_document, '<cmd>TroubleToggle document_diagnostics<CR>', mapdefaults)
    end
  }
end

return lsp
