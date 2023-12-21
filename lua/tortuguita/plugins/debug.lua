local debug = {}

function debug.dap(cfg)
  return {
    "mfussenegger/nvim-dap",
    dependencies = {
      'williamboman/mason.nvim',
      'jayp0521/mason-nvim-dap.nvim'
    },
    config = function()
      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = 'ConfigLocalFinished',
        callback = function()
          local dap = require('dap')
          dap.configurations.go = debug.go_adapter()
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

      local keymap = vim.api.nvim_set_keymap
      local mapdefaults = { noremap = true }
      keymap("n", cfg.map.continue, "<cmd>lua require('dap').continue()<CR>", mapdefaults)
      keymap("n", cfg.map.open_repl, "<cmd>lua require('dap').repl.toggle()<CR>", mapdefaults)
      keymap("n", cfg.map.breakpoint, "<cmd>lua require('dap').toggle_breakpoint()<CR>", mapdefaults)
      keymap("n", cfg.map.conditional_breakpoint,
        "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", mapdefaults)
      keymap("n", cfg.map.list_breakpoints, "<cmd>lua require('dap').list_breakpoints(true)<CR>", mapdefaults)
      keymap('n', cfg.map.hover_widget, "<cmd>lua require('dap.ui.widgets').hover()<CR>", mapdefaults)
    end
  }
end

function debug.go_adapter()
  local gotags_flag = '-tags=' .. vim.g.gotags
  return {
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
end

return debug
