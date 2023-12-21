local utils = {}

---Maps the file reference function to a keymap.
---@param keys string
function utils.map_file_reference(keys)
  vim.api.nvim_set_keymap('n', keys, '', {
    noremap = true,
    callback = utils.file_reference,
  })
end

---Retrieves the current file and line reference.
function utils.file_reference()
  local fileref = vim.fn.expand('%') .. ':' .. vim.fn.line('.')
  vim.fn.setreg('+', fileref)
  print(fileref, 'copied to clipboard')
end

return utils
