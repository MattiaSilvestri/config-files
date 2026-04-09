-- Import modules
local telescope = require("telescope.builtin")
local Snacks = require("snacks")
local telescope_utils = require("utils.telescope_utils")
local grug = require("grug-far")
local fzf = require("fzf-lua")
local neogit = require("neogit")
local vim_utils = require("utils.vim_utils")

local function get_visual_selection()
	local start_pos = vim.api.nvim_buf_get_mark(0, "<")
	local end_pos = vim.api.nvim_buf_get_mark(0, ">")
	local start_row = start_pos[1] - 1
	local start_col = start_pos[2]
	local end_row = end_pos[1] - 1
	local end_col = end_pos[2]

	if end_row < start_row or (end_row == start_row and end_col < start_col) then
		start_row, end_row = end_row, start_row
		start_col, end_col = end_col, start_col
	end

	-- nvim_buf_get_text end_col is exclusive
	end_col = end_col + 1
	local lines = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
	return table.concat(lines, "\n")
end

local function copy_selection_to_registers(text)
	vim.fn.setreg('"', text)
	if vim.fn.has("clipboard") == 1 then
		vim.fn.setreg("+", text)
		vim.fn.setreg("*", text)
	end
end

local telescope_border = {
	border = "rounded",
	width = 0.9,
	height = 0.85,
}

local sections = {
	f = { desc = "Find" },
	s = { desc = "Search" },
	p = { desc = "Packages" },
	l = { desc = "Language Tools" },
	u = { desc = "UI/UX" },
	b = { desc = "Buffers" },
	bs = { desc = "Sort Buffers" },
	d = { desc = "Debugger" },
	g = { desc = "Git" },
	S = { desc = "Session" },
	t = { desc = "Terminal" },
	x = { desc = "Quickfix/Lists" },
	n = { desc = "File Explorer" },
}

local function term_nav(dir)
	return function()
		if vim.api.nvim_win_get_config(0).zindex then
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-" .. dir .. ">", true, false, true), "n", false)
		else
			vim.cmd.wincmd(dir)
		end
	end
end

-- stylua: ignore
return {
	x = {
		["<leader>/"] = { "<Plug>(comment_toggle_linewise_visual)", remap = true, desc = "Toggle comment" },
	},
	n = {
		-- Pickers --
		["<leader>f"] = { function() vim.tbl_get(sections, "f") end, desc = sections.f.desc, },
		["<leader>s"] = { function() vim.tbl_get(sections, "s") end, desc = sections.s.desc, },
		-- ["<leader>ff"] = { function() telescope.find_files() end, desc = "Find files", },
		["<leader>fc"] = { function() telescope.find_files { cwd = vim.fn.stdpath("config") } end, desc = "Find config files", },
		-- ["<leader>sg"] = { function() telescope.live_grep() end, desc = "Live grep", },
		-- ["<leader>ss"] = { function() telescope.current_buffer_fuzzy_find() end, desc = "Telescope fuzzy find", },
		-- ["<leader>fb"] = { function() telescope.buffers() end, desc = "Telescope find buffer", },
		-- ["<leader>sr"] = { function() telescope.resume() end, desc = "Telescope resume", },
		["<leader>ss"] = { function() Snacks.picker.lines() end, desc = "Picker fuzzy find", },
		["<leader>sg"] = { function() Snacks.picker.grep() end, desc = "Picker live grep", },
		["<leader>sf"] = { function() Snacks.picker.grep({ cwd = vim.fn.input("Folder: ", "", "dir") }) end, desc = "Picker search word in folder", },
		["<leader>se"] = { function() Snacks.picker.grep({ args = { "-g", "*." .. vim.fn.input("Filetype: ") } }) end, desc = "Picker search word in filetype", },
		["<leader>fb"] = { function() Snacks.picker.buffers() end, desc = "Picker find buffer", },
		["<leader>sr"] = { function() Snacks.picker.resume() end, desc = "Picker resume", },
		["<leader>s/"] = { function() Snacks.picker.search_history() end, desc = "Picker search history", },
		["<leader>ff"] = { function() Snacks.picker.smart() end, desc = "Find files", },
		["<leader>fh"] = { function() Snacks.picker.highlights() end, desc = "Picker highlights", },
		["<leader>sc"] = { function() Snacks.picker.cliphist() end, desc = "Picker cliphist", },
		["<leader>sl"] = { function() Snacks.picker.lazy() end, desc = "Picker Lazy", },
		["<leader>sn"] = { function() Snacks.picker.notifications() end, desc = "Picker notifications", },
		["<leader>fp"] = { function() Snacks.picker.pickers() end, desc = "Picker find pickers", },
		["<leader>fR"] = { function() Snacks.picker.recent() end, desc = "Picker find recent files", },
		["<leader>su"] = { function() Snacks.picker.undo() end, desc = "Picker search undo", },
		["<leader>sq"] = { function() Snacks.picker.qflist() end, desc = "Picker search quickfix", },
		["<leader>sw"] = { function() Snacks.picker.grep_word() end, desc = "Picker search word", },
		["<leader>fg"] = { function() fzf.live_grep_glob() end, desc = "Live grep glob", },
		["<leader>fs"] = { function() require('telescope').extensions.luasnip.luasnip {} end, desc = "Find snippets", },
		-- ["<leader>fg"] = { function() require("telescope").extensions.live_grep_args.live_grep_args() end, desc = "Telescope live grep args", },
		["<leader><leader>"] = { "<cmd>Telescope cmdline<cr>", desc = "Telescope cmdline", },
		["<leader>fr"] = {
			function()
				grug.toggle_instance({
					instanceName = "far",
					staticTitle = "Find and Replace",
					windowCreationCommand =
					"botright split",
					transient = true
				})
			end,
			desc = "Find and replace",
		},

		-- Buffers and tabs --
		["<leader>b"] = { function() vim.tbl_get(sections, "b") end, desc = sections.b.desc, },
		["<leader>bb"] = { "<Cmd>BufferLinePick<CR>", desc = "Pick buffer", },
		["<leader>bd"] = { "<Cmd>BufferLinePickClose<CR>", desc = "Pick to close buffer", },
		["<leader>bL"] = { "<Cmd>BufferLineMoveNext<CR>", desc = "Move buffer right", },
		["<leader>bH"] = { "<Cmd>BufferLineMovePrev<CR>", desc = "Move buffer left", },
		["<leader>bo"] = { "<Cmd>BufferLineSortByDirectory<CR>", desc = "Order buffers by dir", },
		["L"] = { "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer", },
		["H"] = { "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer", },
		["]o"] = { function() vim.cmd.tabnext() end, desc = "Next tab", },
		["[o"] = { function() vim.cmd.tabprevious() end, desc = "Previous tab", },
		["<leader>c"] = { function() Snacks.bufdelete.delete() end, desc = "Close buffer", },

		-- Editor --
		["<leader>/"] = {
			function()
				return vim.v.count == 0
						and '<Plug>(comment_toggle_linewise_current)'
						or '<Plug>(comment_toggle_linewise_count)'
			end,
			desc = "Toggle comment line",
			remap = true,
			expr = true
		},
		["zR"] = { function() require('ufo').openAllFolds() end, desc = "Open all folds", },
		["zM"] = { function() require('ufo').closeAllFolds() end, desc = "Close all folds", },

		-- File explorer --
		["<leader>n"] = { function() vim.tbl_get(sections, "n") end, desc = sections.n.desc, },
		["<leader>yy"] = { "<cmd>Yazi toggle<cr>", desc = "Toggle yazi", },
		["<leader>yz"] = { "<cmd>Yazi<cr>", desc = "Toggle yazi at current file", },
		-- ["<leader>E"] = { function() Snacks.explorer.open() end, desc = "Snacks Explorer", },
		["<leader>o"] = { "<Cmd>Neotree focus left<CR>", desc = "Focus neotree", },
		["<leader>E"] = { "<Cmd>Neotree focus filesystem float toggle<CR>", desc = "Toggle neotree float", },
		["<leader>e"] = { "<Cmd>Neotree focus filesystem left toggle<CR>", desc = "Focus neotree", },
		["<leader>nb"] = { "<Cmd>Neotree focus buffers left toggle<CR>", desc = "Focus buffers list", },
		["<leader>ng"] = { "<Cmd>Neotree focus git_status left toggle<CR>", desc = "Focus git status", },

		-- Git --
		["<Leader>g"] = { function() vim.tbl_get(sections, "g") end, desc = sections.g.desc, },
		["<leader>gg"] = { function() Snacks.lazygit.open() end, desc = "LazyGit", },
		["<leader>gn"] = { function() neogit.open({ kind = "floating" }) end, desc = "Neogit", },
		["<leader>gd"] = { "<Cmd>CodeDiff history %<CR>", desc = "CodeDiff current file history", },
		["<leader>gq"] = { "<Cmd>DiffviewClose<CR>", desc = "DiffView close", },

		-- Lists --
		["<leader>x"] = { function() vim.tbl_get(sections, "x") end, desc = sections.x.desc, },
		["<leader>xq"] = { "<Cmd>copen<CR>", desc = "Quickfix List" },
		["<leader>xl"] = { "<Cmd>lopen<CR>", desc = "Location List" },
		["]q"] = { vim.cmd.cnext, desc = "Next quickfix" },
		["[q"] = { vim.cmd.cprev, desc = "Previous quickfix" },
		["]Q"] = { vim.cmd.clast, desc = "End quickfix" },
		["[Q"] = { vim.cmd.cfirst, desc = "Beginning quickfix" },

		["]l"] = { vim.cmd.lnext, desc = "Next loclist" },
		["[l"] = { vim.cmd.lprev, desc = "Previous loclist" },
		["]L"] = { vim.cmd.llast, desc = "End loclist" },
		["[L"] = { vim.cmd.lfirst, desc = "Beginning loclist" },

		-- LSP --
		["<Leader>l"] = { function() vim.tbl_get(sections, "l") end, desc = sections.l.desc, },
		["<leader>lR"] = { function() Snacks.picker.lsp_references() end, desc = "See references", },
		["<leader>ls"] = { function() Snacks.picker.lsp_symbols() end, desc = "Search symbols in buffer", },
		["<leader>lS"] = { function() Snacks.picker.lsp_workspace_symbols() end, desc = "Search symbols in workspace", },
		["<leader>lt"] = { function() Snacks.picker.treesitter() end, desc = "View treesitter symbols", },
		["<leader>lr"] = { function() vim.lsp.buf.rename() end, desc = "Rename symbol", },
		["gd"] = { function() telescope.lsp_definitions() end, desc = "Go to definition", },
		["gD"] = { function() telescope_utils.open_definition_in_window() end, desc = "Go to definition", },
		["K"] = { function() vim.lsp.buf.hover() end, desc = "Hover symbol", },

		-- AI --
		["<leader>lc"] = { function() require("codex").toggle() end, desc = "Codex toggle", },


		-- Packages --
		["<leader>p"] = { function() vim.tbl_get(sections, "p") end, desc = sections.p.desc, },
		["<leader>pi"] = { function() require("lazy").install() end, desc = "Plugins Install", },
		["<leader>ps"] = { function() require("lazy").home() end, desc = "Plugins Status", },
		["<leader>pS"] = { function() require("lazy").sync() end, desc = "Plugins Sync", },
		["<leader>pu"] = { function() require("lazy").check() end, desc = "Plugins Check Updates", },
		["<leader>pU"] = { function() require("lazy").update() end, desc = "Plugins Update", },

		-- Window management --
		["<C-H>"] = { "<C-w>h", desc = "Move to left split" },
		["<C-J>"] = { "<C-w>j", desc = "Move to below split" },
		["<C-K>"] = { "<C-w>k", desc = "Move to above split" },
		["<C-L>"] = { "<C-w>l", desc = "Move to right split" },
		["<C-Up>"] = { "<Cmd>resize -2<CR>", desc = "Resize split up" },
		["<C-Down>"] = { "<Cmd>resize +2<CR>", desc = "Resize split down" },
		["<C-Left>"] = { "<Cmd>vertical resize -2<CR>", desc = "Resize split left" },
		["<C-Right>"] = { "<Cmd>vertical resize +2<CR>", desc = "Resize split right" },
		["<leader>z"] = { "<Cmd>Maximize<CR>", desc = "Toggle maximizie current window" },

		-- Session managment --
		["<leader>S"] = { function() vim.tbl_get(sections, "S") end, desc = sections.S.desc, },
		["<leader>Sf"] = { function() require("nvim-possession").list() end, desc = "📌 list sessions", },
		["<leader>Sn"] = { function() require("nvim-possession").new() end, desc = "📌 create new session", },
		["<leader>Ss"] = { function() require("nvim-possession").update() end, desc = "📌 update current session", },
		["<leader>Sd"] = { function() require("nvim-possession").delete() end, desc = "📌 delete selected session", },

		-- Terminal --
		["<leader>t"] = { function() vim.tbl_get(sections, "t") end, desc = sections.t.desc, },
		["tf"] = { '<Cmd>execute v:count . "ToggleTerm direction=float"<CR>', desc = "Toggle terminal float" },
		["th"] = { '<Cmd>execute v:count . "ToggleTerm direction=horizontal"<CR>', desc = "Toggle terminal horizontal" },
		["tv"] = { '<Cmd>execute v:count . "ToggleTerm direction=vertical"<CR>', desc = "Toggle terminal vertical" },
		["<leader>ts"] = { "<Cmd>TermSelect<CR>", desc = "Select terminal" },

		-- Surround --
		["<leader>ys"] = { "<Plug>(nvim-surround-normal)", desc = "Surround normal" },
		["<leader>ya$"] = { "<Plug>(nvim-surround-normal_cur)", desc = "Surround normal cur" },
		["<leader>yS"] = { "<Plug>(nvim-surround-normal_line)", desc = "Surround normal line" },
		["<leader>SS"] = { "<Plug>(nvim-surround-normal_cur_line)", desc = "Surround normal cur line" },
		["<leader>yds"] = { "<Plug>(nvim-surround-delete)", desc = "Surround delete" },
		["<leader>ycs"] = { "<Plug>(nvim-surround-change)", desc = "Surround change" },
		["<leader>ycS"] = { "<Plug>(nvim-surround-change_line)", desc = "Surround change line" },

		-- General --
		["gl"] = { function() vim.diagnostic.open_float(nil, { scope = "line" }) end, desc = "Hover diagnostics" },
		["U"] = { "<cmd>redo<cr>", desc = "Redo" },
		["<leader>st"] = { "<cmd>put =strftime('%c')<cr>kJ", desc = "Insert current date and time" },
		["<leader>sd"] = { "<cmd>cd %:h<cr>", desc = "Move workdir to current file" },
		["<leader>a"] = { "<cmd>Trouble diagnostics toggle<cr>", desc = "Toggle Trouble" },
		["-"] = { "^", desc = "Move to first non-blank character of the line" },
		["~"] = { "Vyp", desc = "Yank and pase to next line" },
		["<leader>."] = { "<cmd>noh<cr>", desc = "noh" },
	},

	v = {
		["p"] = { '"0p', desc = "Normal paste" },
		["P"] = { '"*p', desc = "Normal paste from clipboard" },
		["<"] = { "<gv", desc = "Persistend indent left" },
		[">"] = { ">gv", desc = "Persistend indent right" },
		["<leader>fr"] = {
			function()
				grug.toggle_instance({
					instanceName = "far",
					staticTitle = "Find and Replace",
					visualSelectionUsage = 'operate-within-range',
					windowCreationCommand = "botright split",
					transient = true
				})
			end,
			desc = "Find and replace in current selection",
		},
		["<leader>ff"] = {
			function()
				local text = vim_utils.get_current_selection()
				copy_selection_to_registers(text)
				Snacks.picker.smart({ pattern = text })
			end,
			desc = "Find files (selection)",
		},
		["<leader>sl"] = {
			function()
				local text = vim_utils.get_current_selection()
				copy_selection_to_registers(text)
				Snacks.picker.lines({ pattern = text })
			end,
			desc = "Picker lines (selection)",
		},
		["<leader>ss"] = { function() fzf.blines() end, desc = "Visual selection or word" },
		--- Git ---
		["<leader>gl"] = { "<Cmd>'<,'>DiffviewFileHistory<CR>", desc = "DiffView current line history", },

		--- AI ---
		["<leader>lc"] = { function() require("codex").actions.send_selection() end, desc = "Codex send selection", },

		-- Surround --
		["S"] = { "<Plug>(nvim-surround-visual)", desc = "Surround visual" },
		["gS"] = { "<Plug>(nvim-surround-visual)", desc = "Surround visual_line" },
	},

	t = {
		-- Improved Terminal Navigation
		["<C-H>"] = { term_nav "h", desc = "Terminal left window navigation" },
		["<C-J>"] = { term_nav "j", desc = "Terminal down window navigation" },
		["<C-K>"] = { term_nav "k", desc = "Terminal up window navigation" },
		["<C-L>"] = { term_nav "l", desc = "Terminal right window navigation" },
	},
}
