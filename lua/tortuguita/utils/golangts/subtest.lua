local M = {}

local subtests_query = [[
(call_expression
  function: (selector_expression
    operand: (identifier)
    field: (field_identifier) @run)
  arguments: (argument_list
    (interpreted_string_literal) @testname
    [
     (func_literal)
     (identifier)
    ])
  (#eq? @run "Run")) @parent
]]

local function get_subtests(ft, root, stop_row, test_tree)
  local subtest_query = vim.treesitter.query.parse(ft, subtests_query)
  assert(subtest_query, "could not parse test query")
  for _, match, _ in subtest_query:iter_matches(root, 0, 0, stop_row) do
    local test_match = {}
    for id, node in pairs(match) do
      local capture = subtest_query.captures[id]
      if capture == "testname" then
        local name = vim.treesitter.get_node_text(node, 0)
        test_match.name = string.gsub(string.gsub(name, " ", "_"), '"', "")
      end
      if capture == "parent" then
        test_match.node = node
      end
    end
    table.insert(test_tree, test_match)
  end

  return test_tree
end

M.get_subtests = get_subtests

return M
