-- Import modules
local telescope = require("telescope.builtin")
local Snacks = require("snacks")
local telescope_utils = require("utils.telescope_utils")

local sections = {
	f = { desc = "Find" },
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
		-- Telescope --
		["<leader>f"] = { function() vim.tbl_get(sections, "f") end, desc = sections.f.desc, },
		["<leader>ff"] = { function() telescope.find_files() end, desc = "Find files", },
		["<leader>fc"] = { function() telescope.find_files { cwd = vim.fn.stdpath("config") } end, desc = "Find config files", },
		["<leader>sg"] = { function() telescope.live_grep() end, desc = "Live grep", },
		["<leader>ss"] = { function() telescope.current_buffer_fuzzy_find() end, desc = "Telescope fuzzy find", },
		["<leader>fb"] = { function() telescope.buffers() end, desc = "Telescope find buffer", },
		["<leader><leader>"] = { "<cmd>Telescope cmdline<cr>", desc = "Telescope find buffer", },

		-- Buffers and tabs --
		["<leader>b"] = { function() vim.tbl_get(sections, "b") end, desc = sections.b.desc, },
		["<leader>bb"] = { "<Cmd>BufferLinePick<CR>", desc = "Pick buffer", },
		["<leader>bd"] = { "<Cmd>BufferLinePickClose<CR>", desc = "Pick to close buffer", },
		["<leader>bL"] = { "<Cmd>BufferLineMoveNext<CR>", desc = "Move buffer right", },
		["<leader>bH"] = { "<Cmd>BufferLineMovePrev<CR>", desc = "Move buffer left", },
		["L"] = { function() vim.cmd.bnext() end, desc = "Next buffer", },
		["H"] = { function() vim.cmd.bprev() end, desc = "Previous buffer", },
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

		-- File explorer --
		["<leader>n"] = { function() vim.tbl_get(sections, "n") end, desc = sections.n.desc, },
		["<leader>yy"] = { "<cmd>Yazi toggle<cr>", desc = "Toggle yazi", },
		["<leader>yz"] = { "<cmd>Yazi<cr>", desc = "Toggle yazi at current file", },
		-- ["<leader>E"] = { function() Snacks.explorer.open() end, desc = "Snacks Explorer", },
		["<leader>o"] = { "<Cmd>Neotree focus left<CR>", desc = "Focus neotree", },
		["<leader>E"] = { "<Cmd>Neotree focus float toggle<CR>", desc = "Toggle neotree float", },
		["<leader>e"] = { "<Cmd>Neotree focus filesystem left toggle<CR>", desc = "Focus neotree", },
		["<leader>nb"] = { "<Cmd>Neotree focus buffers left toggle<CR>", desc = "Focus buffers list", },
		["<leader>ng"] = { "<Cmd>Neotree focus git_status left toggle<CR>", desc = "Focus git status", },

		-- Git --
		["<Leader>g"] = { function() vim.tbl_get(sections, "g") end, desc = sections.g.desc, },
		["<leader>gg"] = { function() Snacks.lazygit.open() end, desc = "LazyGit", },

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
		["<leader>lR"] = { function() telescope.lsp_references() end, desc = "See references", },
		["<leader>ls"] = { function() Snacks.picker.lsp_symbols() end, desc = "Search symbols in buffer", },
		["<leader>lS"] = { function() Snacks.picker.lsp_workspace_symbols() end, desc = "Search symbols in workspace", },
		["<leader>lr"] = { function() vim.lsp.buf.rename() end, desc = "Rename symbol", },
		["gd"] = { function() telescope.lsp_definitions() end, desc = "Go to definition", },
		["gD"] = { function() telescope_utils.open_definition_in_window() end, desc = "Go to definition", },
		["K"] = { function() vim.lsp.buf.hover() end, desc = "Hover symbol", },


		-- Packages --
		["<leader>p"] = { function() vim.tbl_get(sections, "p") end, desc = sections.p.desc, },
		["<leader>pi"] = { function() require("lazy").install() end, desc = "Plugins Install", },
		["<leader>ps"] = { function() require("lazy").home() end, desc = "Plugins Status", },
		["<leader>pS"] = { function() require("lazy").sync() end, desc = "Plugins Sync", },
		["<leader>pu"] = { function() require("lazy").check() end, desc = "Plugins Check Updates", },
		["<leader>pU"] = { function() require("lazy").update() end, desc = "Plugins Update", },

		-- Pane navigation --
		["<C-H>"] = { "<C-w>h", desc = "Move to left split" },
		["<C-J>"] = { "<C-w>j", desc = "Move to below split" },
		["<C-K>"] = { "<C-w>k", desc = "Move to above split" },
		["<C-L>"] = { "<C-w>l", desc = "Move to right split" },
		["<C-Up>"] = { "<Cmd>resize -2<CR>", desc = "Resize split up" },
		["<C-Down>"] = { "<Cmd>resize +2<CR>", desc = "Resize split down" },
		["<C-Left>"] = { "<Cmd>vertical resize -2<CR>", desc = "Resize split left" },
		["<C-Right>"] = { "<Cmd>vertical resize +2<CR>", desc = "Resize split right" },

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

		-- General --
		["gl"] = { function() vim.diagnostic.open_float(nil, { scope = "line" }) end, desc = "Hover diagnostics" },
		["U"] = { "<cmd>redo<cr>", desc = "Redo" },
		["<leader>st"] = { "<cmd>put =strftime('%c')<cr>kJ", desc = "Insert current date and time" },
		["<leader>sd"] = { "<cmd>cd %:h<cr>", desc = "Move workdir to current file" },
		["<leader>a"] = { "<cmd>Trouble diagnostics toggle<cr>", desc = "Toggle Trouble" },
		["-"] = { "^", desc = "Move to first non-blank character of the line" },
		["~"] = { "Vyp", desc = "Yank and pase to next line" },
	},

	v = {
		["p"] = { '"0p', desc = "Normal paste" },
		["P"] = { '"*p', desc = "Normal paste from clipboard" },
		["<"] = { "<gv", desc = "Persistend indent left" },
		[">"] = { ">gv", desc = "Persistend indent right" },
	},

	t = {
		-- Improved Terminal Navigation
		["<C-H>"] = { term_nav "h", desc = "Terminal left window navigation" },
		["<C-J>"] = { term_nav "j", desc = "Terminal down window navigation" },
		["<C-K>"] = { term_nav "k", desc = "Terminal up window navigation" },
		["<C-L>"] = { term_nav "l", desc = "Terminal right window navigation" },
	},
}
