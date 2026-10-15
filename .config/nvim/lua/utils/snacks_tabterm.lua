-- Tabbed terminal panels built on top of Snacks.terminal.
-- Each position ("bottom", "right", ...) has its own independent panel: several
-- terminals share a single split, only one is visible at a time and the winbar
-- shows the list of tabs.
local M = {}

---@alias TabTermPosition "bottom"|"top"|"left"|"right"

---@type table<TabTermPosition, number>
local default_size = { bottom = 0.3, top = 0.3, left = 0.4, right = 0.4 }

---@class TabTermPanel
---@field position TabTermPosition
---@field vertical boolean
---@field size number
---@field terms snacks.win[]
---@field current? snacks.win
---@field next_id integer
---@field keys table
local Panel = {}
Panel.__index = Panel

---@type table<TabTermPosition, TabTermPanel>
local panels = {}

---@param position TabTermPosition
---@return TabTermPanel
local function get_panel(position)
	position = position or "bottom"
	if panels[position] then
		return panels[position]
	end
	local self = setmetatable({
		position = position,
		vertical = position == "left" or position == "right",
		size = default_size[position] or 0.3,
		terms = {},
		next_id = 1,
	}, Panel)

	local mode = { "n", "t" }
	self.keys = {
		tab_next = { "<A-l>", function() self:cycle(1) end, mode = mode, desc = "Next terminal tab" },
		tab_prev = { "<A-h>", function() self:cycle(-1) end, mode = mode, desc = "Previous terminal tab" },
		tab_new = { "<A-n>", function() self:new() end, mode = mode, desc = "New terminal tab" },
		tab_close = { "<A-x>", function() self:close() end, mode = mode, desc = "Close terminal tab" },
		tab_rename = { "<A-r>", function() M.rename() end, mode = mode, desc = "Rename terminal tab" },
		q = { "q", function() self:toggle() end, desc = "Hide terminal panel" },
	}
	for i = 1, 9 do
		self.keys["tab_" .. i] = { "<A-" .. i .. ">", function() self:go(i) end, mode = mode, desc = "Terminal tab " .. i }
	end

	panels[position] = self
	return self
end

function Panel:list()
	self.terms = vim.tbl_filter(function(t)
		return t:buf_valid()
	end, self.terms)
	return self.terms
end

function Panel:index_of(term)
	for i, t in ipairs(self.terms) do
		if t == term then
			return i
		end
	end
end

function Panel:render_winbar()
	local parts = {}
	for i, t in ipairs(self:list()) do
		local hl = t == self.current and "%#TabLineSel#" or "%#TabLine#"
		parts[#parts + 1] = ("%s %d: %%{getbufvar(%d, 'term_name', getbufvar(%d, 'term_title'))} "):format(hl, i, t.buf, t.buf)
	end
	return table.concat(parts, "%#TabLineFill#|") .. "%#TabLineFill#"
end

function Panel:refresh_winbar()
	if self.current and self.current:valid() then
		vim.wo[self.current.win].winbar = self:render_winbar()
	end
end

function Panel:size_opts()
	return self.vertical and { width = self.size } or { height = self.size }
end

-- Hide the visible tab, remembering the panel size
function Panel:hide_current()
	local cur = self.current
	if cur and cur:valid() then
		self.size = self.vertical and vim.api.nvim_win_get_width(cur.win) or vim.api.nvim_win_get_height(cur.win)
		cur:hide()
	end
end

---@param term snacks.win
function Panel:show(term)
	if term == self.current and term:valid() then
		return term:focus()
	end
	self:hide_current()
	self.current = term
	term.opts = vim.tbl_extend("force", term.opts, self:size_opts())
	term:show():focus()
	self:refresh_winbar()
end

function Panel:on_gone()
	vim.schedule(function()
		local was_current = self.current and not self.current:buf_valid()
		local idx = was_current and self:index_of(self.current) or nil
		local remaining = self:list()
		if was_current then
			self.current = nil
			if #remaining > 0 then
				self:show(remaining[math.min(idx or 1, #remaining)])
			end
		else
			self:refresh_winbar()
		end
	end)
end

function Panel:new()
	self:hide_current()
	local id = self.next_id
	self.next_id = self.next_id + 1
	local term = Snacks.terminal.open(nil, {
		count = id,
		-- unique env so a tab never collides with other Snacks terminal ids
		env = { SNACKS_TERM_TAB = self.position .. ":" .. id },
		win = vim.tbl_extend("force", {
			position = self.position,
			stack = false,
			keys = self.keys,
			wo = { winbar = "" },
		}, self:size_opts()),
	})
	self.terms[#self.terms + 1] = term
	self.current = term
	local on_gone = function()
		self:on_gone()
	end
	term:on("TermClose", on_gone, { buf = true })
	term:on("BufWipeout", on_gone, { buf = true })
	self:refresh_winbar()
	return term
end

function Panel:toggle()
	if self.current and self.current:valid() then
		return self:hide_current()
	end
	local all = self:list()
	if #all == 0 then
		return self:new()
	end
	self:show((self.current and self.current:buf_valid()) and self.current or all[1])
end

---@param delta integer
function Panel:cycle(delta)
	local all = self:list()
	if #all == 0 then
		return self:new()
	end
	local idx = self:index_of(self.current) or 1
	self:show(all[(idx - 1 + delta) % #all + 1])
end

---@param i integer
function Panel:go(i)
	local t = self:list()[i]
	if t then
		self:show(t)
	end
end

function Panel:close()
	if self.current and self.current:buf_valid() then
		vim.api.nvim_buf_delete(self.current.buf, { force = true })
	end
end

-- Rename a Snacks terminal (defaults to the current buffer).
-- The name is stored in `b:term_name`; an empty name restores the shell title.
---@param buf? integer
function M.rename(buf)
	buf = buf or vim.api.nvim_get_current_buf()
	if not vim.b[buf].snacks_terminal then
		return Snacks.notify.warn("Not a Snacks terminal")
	end
	local was_insert = vim.api.nvim_get_mode().mode == "t"
	vim.cmd.stopinsert()
	vim.ui.input({ prompt = "Terminal name: ", default = vim.b[buf].term_name or "" }, function(name)
		if name then
			vim.b[buf].term_name = name ~= "" and name or nil
			-- floats show a static border title instead of a winbar: update it (persists across hide/show)
			for _, term in ipairs(Snacks.terminal.list()) do
				if term.buf == buf and term.opts.position == "float" and term.opts.title then
					term:set_title(name ~= "" and name or ("Terminal " .. vim.b[buf].snacks_terminal.id), "center")
				end
			end
			vim.cmd.redrawstatus({ bang = true })
		end
		vim.schedule(function()
			if was_insert and vim.api.nvim_get_current_buf() == buf then
				vim.cmd.startinsert()
			end
		end)
	end)
end

---@param position? TabTermPosition
function M.toggle(position) return get_panel(position):toggle() end
---@param position? TabTermPosition
function M.new(position) return get_panel(position):new() end
---@param delta integer
---@param position? TabTermPosition
function M.cycle(delta, position) return get_panel(position):cycle(delta) end
---@param i integer
---@param position? TabTermPosition
function M.go(i, position) return get_panel(position):go(i) end
---@param position? TabTermPosition
function M.close(position) return get_panel(position):close() end

return M
