local M = {}

local function is_farther(dest, source)
  local dest_row, _, _, _ = dest:range()
  local source_row, _, _, _ = source:range()

  return dest_row < source_row
end

local function is_parent(dest, source)
  if not (dest and source) then
    return false
  end
  if dest == source then
    return false
  end

  local current = source
  while current ~= nil do
    if current == dest then
      return true
    end

    current = current:parent()
  end

  return false
end


M.sort_tree = function(test_tree)
  table.sort(test_tree, function(a, b)
    return is_parent(a.node, b.node)
  end)
  table.sort(test_tree, function(a, b)
    return is_farther(a.node, b.node)
  end)

  for _, parent in ipairs(test_tree) do
    for _, child in ipairs(test_tree) do
      if is_parent(parent.node, child.node) then
        child.parent = parent.name
      end
    end
  end

  return test_tree
end

return M
