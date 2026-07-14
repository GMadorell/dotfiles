-- Yank current line (or visual selection) as LLM context: path:line(s), enclosing
-- function/class via treesitter, and the code in a language-tagged fence.

local M = {}

-- Path to the current buffer, relative to the git root when inside a repo,
-- otherwise relative to Neovim's cwd.
local function relative_path(bufnr)
	local abs_path = vim.api.nvim_buf_get_name(bufnr)
	local git_root = vim.fs.root(bufnr, ".git")
	if git_root then
		return vim.fs.relpath(git_root, abs_path) or vim.fn.fnamemodify(abs_path, ":.")
	end
	return vim.fn.fnamemodify(abs_path, ":.")
end

local ts_container_types = {
	function_declaration = true,
	function_definition = true,
	function_item = true,
	method_definition = true,
	method_declaration = true,
	class_declaration = true,
	class_definition = true,
	struct_item = true,
	impl_item = true,
	["function"] = true, -- lua
}

-- Walks treesitter ancestors of the node at `lnum` collecting names of
-- enclosing functions/classes, e.g. "MyClass > my_method".
local function ts_breadcrumb(bufnr, lnum)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if not ok or not parser then
		return nil
	end

	local ok_tree, trees = pcall(parser.parse, parser)
	if not ok_tree or not trees or not trees[1] then
		return nil
	end

	local node = trees[1]:root():named_descendant_for_range(lnum - 1, 0, lnum - 1, 0)
	local names = {}

	while node do
		if ts_container_types[node:type()] then
			local name_field = node:field("name")
			local name_node = name_field and name_field[1]
			if name_node then
				table.insert(names, 1, vim.treesitter.get_node_text(name_node, bufnr))
			end
		end
		node = node:parent()
	end

	if #names == 0 then
		return nil
	end
	return table.concat(names, " > ")
end

function M.yank()
	local bufnr = vim.api.nvim_get_current_buf()
	local mode = vim.fn.mode()
	local start_line, end_line

	if mode == "v" or mode == "V" then
		start_line, end_line = vim.fn.line("v"), vim.fn.line(".")
		if start_line > end_line then
			start_line, end_line = end_line, start_line
		end
	else
		start_line = vim.fn.line(".")
		end_line = start_line
	end

	local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
	local path = relative_path(bufnr)
	local location = (start_line == end_line) and (path .. ":" .. start_line)
		or (path .. ":" .. start_line .. "-" .. end_line)

	local breadcrumb = ts_breadcrumb(bufnr, start_line)
	if breadcrumb then
		location = location .. " (" .. breadcrumb .. ")"
	end

	local lang = vim.bo[bufnr].filetype
	local result = location .. "\n```" .. lang .. "\n" .. table.concat(lines, "\n") .. "\n```"

	vim.fn.setreg("+", result)
	vim.notify("Copied " .. location)
end

return M
