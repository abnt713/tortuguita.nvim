local M = {}

local table_root_query = [[
(function_declaration
  name: (identifier) @rootname
  parameters: (parameter_list
    . (parameter_declaration
      type: (pointer_type) @type) .)
  body: (block
	  (short_var_declaration
      right: (expression_list
        (composite_literal
          body: (literal_value
            (literal_element
              (literal_value
                . (keyed_element
                  (literal_element
                    (interpreted_string_literal) @testname @parent
                  )
                )
              )
            )
          )
        )
      )
    )
  )
  (#match? @type "*testing.(T|M)")
  (#match? @rootname "^Test.+$"))
]]

local function get_table_root(ft, root, stop_row, test_tree)
  local subtest_query = vim.treesitter.query.parse(ft, table_root_query)
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

M.get_table_root = get_table_root

return M
