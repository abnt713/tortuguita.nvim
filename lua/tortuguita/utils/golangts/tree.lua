local M = {}

local function format_subtest(testcase, test_tree)
  local parent
  if testcase.parent then
    for _, curr in pairs(test_tree) do
      if curr.name == testcase.parent then
        parent = curr
        break
      end
    end
    return string.format("%s/%s", format_subtest(parent, test_tree), testcase.name)
  else
    return testcase.name
  end
end

M.get_closest_to_cursor = function(test_tree, cursor_row)
  local result
  for _, curr in pairs(test_tree) do
    if not result then
      result = curr
    else
      local node_row1, _, _, _ = curr.node:range()
      local result_row1, _, _, _ = result.node:range()
      if node_row1 <= cursor_row and node_row1 > result_row1 then
        result = curr
      end
    end
  end
  if result then
    return format_subtest(result, test_tree)
  end
  return nil
end


M.find_tree = function(stop_row)
  local ft = vim.api.nvim_buf_get_option(0, "filetype")
  local parser = vim.treesitter.get_parser(0)
  local root = (parser:parse()[1]):root()

  local table_tree = {}
  table_tree = require('tortuguita.utils.golangts.root').get_root_test(ft, root, stop_row, table_tree)
  table_tree = require('tortuguita.utils.golangts.subtest').get_subtests(ft, root, stop_row, table_tree)
  table_tree = require('tortuguita.utils.golangts.table_root').get_table_root(ft, root, stop_row, table_tree)
  table_tree = require('tortuguita.utils.golangts.table_subtest').get_table_subtests(ft, root, stop_row, table_tree)

  return table_tree
end

M.sort_tree = function(test_tree)
  return require('tortuguita.utils.golangts.sort').sort_tree(test_tree)
end

M.get_closest_test = function()
  local stop_row = vim.api.nvim_win_get_cursor(0)[1]
  local test_tree = M.find_tree(stop_row)
  test_tree = M.sort_tree(test_tree)
  return M.get_closest_to_cursor(test_tree, stop_row - 1)
end

return M
