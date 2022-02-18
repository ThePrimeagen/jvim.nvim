local parsers = require("nvim-treesitter.parsers")

local M = {}

local function project(row, col)
	return row * 100000 + col
end

local function project_start(node)
	local row, col = node:range()
	return project(row, col)
end

local function project_end(node)
	local _, _, row, col = node:range()
	return project(row, col)
end

local function contains(a, b)
	if project_start(a) > project_start(b) then
		return false
	end

	if project_end(a) < project_end(b) then
		return false
	end

	return true
end

local function get_bufnr(bufnr)
	return bufnr or vim.api.nvim_get_current_buf()
end

local function valid_buffer()
	local ft = vim.bo[get_bufnr()].ft
	return ft == "json"
end

local function getpos()
	return vim.fn.line(".") - 1, vim.fn.col(".") - 1
end

local function get_root(bufnr)
	local parser = parsers.get_parser(bufnr, "json")
	if not parser then
		error("No treesitter parser found. Install one using :TSInstall <language>")
	end
	return parser:parse()[1]:root()
end

local function get_parent(bufnr, count)
	if not count or count < 1 then
		count = 1
	end

	local row, col = getpos()
	local root = get_root(bufnr)
	local current_node = root:named_descendant_for_range(row, col, row, col)
	if not current_node then
		return
	end

	local current_count = 0
	while current_node:parent() ~= nil and current_node:parent():type() ~= "document" do
		current_node = current_node:parent()

		if current_node:type() == "pair" then
			current_count = current_count + 1
			if current_count == count then
				break
			end
		end
	end

	return current_node
end

local function get_first_child(bufnr)
	local current_node = get_parent(bufnr, 1)
	local query = vim.treesitter.parse_query("json", "(pair) @pair")

	local lowest = nil
	local lowest_diff = nil
	for _, node, _ in query:iter_captures(current_node, bufnr, 0, -1) do
		if current_node:id() ~= node:id() and (lowest == nil or contains(current_node, lowest)) then
			if lowest == nil then
				lowest = node
				lowest_diff = math.abs(project_start(current_node) - project_start(lowest))
			else
				local diff = math.abs(project_start(current_node) - project_start(lowest))
				if diff < lowest_diff then
					lowest = node
					lowest_diff = diff
				end
			end
		end
	end

	return lowest
end

local function move(node)
	local new_row, new_col = node:range()
	vim.api.nvim_win_set_cursor(0, { new_row + 1, new_col })
end

function M.to_immediate()
	if not valid_buffer() then
		return
	end
	move(get_parent(get_bufnr(), 1))
end

function M.to_parent()
	if not valid_buffer() then
		return
	end
	move(get_parent(get_bufnr(), 2))
end

function M.next_sibling()
	if not valid_buffer() then
		return
	end
	local pair = get_parent(get_bufnr(), 1)
	local next = pair:next_named_sibling()

	if next then
		move(next)
	else
		move(pair)
	end
end

function M.prev_sibling()
	if not valid_buffer() then
		return
	end
	local pair = get_parent(get_bufnr(), 1)
	local prev = pair:prev_named_sibling()

	if prev then
		move(prev)
	else
		move(pair)
	end
end

function M.descend()
	if not valid_buffer() then
		return
	end
	local first_child = get_first_child()
	if first_child then
		move(first_child)
	end
end

return M
