local editor = {}

--- Loads default options used by the editor and it's plugins.
function editor.default_opts()
  vim.g.gotags = ''
  vim.g.dapleader = '\\'
end

--- Configures numbers and lines for the editor.
function editor.numbers_and_lines()
  vim.wo.relativenumber = true
  vim.wo.number = true
  vim.wo.signcolumn = 'yes'
  vim.wo.cursorline = true
  vim.opt.colorcolumn = '80'

  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    desc = 'Set text wrapping for text files',
    pattern = { '*.md', '*.txt' },
    callback = function()
      vim.cmd 'setlocal textwidth=80'
    end
  })
end

--- Handles indentation related settings.
function editor.indentation()
  local indent_size = 4
  vim.bo.shiftwidth = indent_size
  vim.bo.smartindent = true
  vim.bo.tabstop = indent_size
  vim.bo.softtabstop = indent_size
end

--- Map <C-c> to esc for better usage.
function editor.map_cc_to_esc()
  vim.api.nvim_set_keymap('i', '<C-c>', '<ESC>', { noremap = true })
end

return editor
