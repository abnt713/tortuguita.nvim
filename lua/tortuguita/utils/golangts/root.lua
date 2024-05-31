local M = {}

local tests_query = [[
(function_declaration
  name: (identifier) @testname
  parameters: (parameter_list
    . (parameter_declaration
      type: (pointer_type) @type) .)
  (#match? @type "*testing.(T|M)")
  (#match? @testname "^Test.+$")) @parent
]]

local function get_root_test(ft, root, stop_row, test_tree)
  assert(ft == "go", "can only find test in go files, not " .. ft)

  local test_query = vim.treesitter.query.parse(ft, tests_query)
  assert(test_query, "could not parse test query")
  for _, match, _ in test_query:iter_matches(root, 0, 0, stop_row) do
    local test_match = {}
    for id, node in pairs(match) do
      local capture = test_query.captures[id]
      if capture == "testname" then
        local name = vim.treesitter.get_node_text(node, 0)
        test_match.name = name
      end
      if capture == "parent" then
        test_match.node = node
      end
    end
    table.insert(test_tree, test_match)
  end

  return test_tree
end

M.get_root_test = get_root_test

return M
