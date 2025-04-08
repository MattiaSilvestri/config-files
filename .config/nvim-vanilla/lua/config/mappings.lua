-- Import modules
local telescope = require("telescope.builtin")
local Snacks = require("snacks")

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
}

return {
	n = {
		-- Telescope --
		["<leader>ff"] = {
			function()
				telescope.find_files()
			end,
			desc = "Find files",
		},
		["<leader>sg"] = {
			function()
				telescope.live_grep()
			end,
			desc = "Live grep",
		},
		["<leader>ss"] = {
			function()
				telescope.current_buffer_fuzzy_find()
			end,
			desc = "Telescope fuzzy find",
		},

		-- Snacks --
		["<leader>e"] = {
			function()
				Snacks.explorer.open()
			end,
			desc = "Snacks Explorer",
		},
		-- Buffers and tabs --
		["<Leader>b"] = {
			function()
				vim.tbl_get(sections, "b")
			end,
			desc = sections.b.desc,
		},
		["]o"] = {
			function()
				vim.cmd.tabnext()
			end,
			desc = "Next tab",
		},
		["[o"] = {
			function()
				vim.cmd.tabprevious()
			end,
			desc = "Previous tab",
		},

		-- Git --
		["<Leader>g"] = {
			function()
				vim.tbl_get(sections, "g")
			end,
			desc = sections.g.desc,
		},
		["<leader>gg"] = {
			function()
				Snacks.lazygit.open()
			end,
			desc = "LazyGit",
		},

		-- Pane navigation --
		["<C-H>"] = { "<C-w>h", desc = "Move to left split" },
		["<C-J>"] = { "<C-w>j", desc = "Move to below split" },
		["<C-K>"] = { "<C-w>k", desc = "Move to above split" },
		["<C-L>"] = { "<C-w>l", desc = "Move to right split" },
		["<C-Up>"] = { "<Cmd>resize -2<CR>", desc = "Resize split up" },
		["<C-Down>"] = { "<Cmd>resize +2<CR>", desc = "Resize split down" },
		["<C-Left>"] = { "<Cmd>vertical resize -2<CR>", desc = "Resize split left" },
		["<C-Right>"] = { "<Cmd>vertical resize +2<CR>", desc = "Resize split right" },

		-- Packages --
		["<Leader>p"] = {
			function()
				vim.tbl_get(sections, "p")
			end,
			desc = sections.p.desc,
		},
		["<Leader>pi"] = {
			function()
				require("lazy").install()
			end,
			desc = "Plugins Install",
		},
		["<Leader>ps"] = {
			function()
				require("lazy").home()
			end,
			desc = "Plugins Status",
		},
		["<Leader>pS"] = {
			function()
				require("lazy").sync()
			end,
			desc = "Plugins Sync",
		},
		["<Leader>pu"] = {
			function()
				require("lazy").check()
			end,
			desc = "Plugins Check Updates",
		},
		["<Leader>pU"] = {
			function()
				require("lazy").update()
			end,
			desc = "Plugins Update",
		},

		-- Terminal --
		["<Leader>t"] = {
			function()
				vim.tbl_get(sections, "t")
			end,
			desc = sections.t.desc,
		},
		["tf"] = { '<Cmd>execute v:count . "ToggleTerm direction=float"<CR>', desc = "Toggle terminal float" },
		["th"] = { '<Cmd>execute v:count . "ToggleTerm direction=horizontal"<CR>', desc = "Toggle terminal horizontal" },
		["tv"] = { '<Cmd>execute v:count . "ToggleTerm direction=vertical"<CR>', desc = "Toggle terminal vertical" },
		["<leader>ts"] = { "<Cmd>TermSelect<CR>", desc = "Select terminal" },

		["U"] = { "<cmd>redo<cr>", desc = "Redo" },
		["<leader>st"] = { "<cmd>put =strftime('%c')<cr>kJ", desc = "Insert current date and time" },
		["<leader>sd"] = { "<cmd>cd %:h<cr>", desc = "Move workdir to current file" },
		["<leader>a"] = { "<cmd>Trouble diagnostics toggle<cr>", desc = "Toggle Trouble" },
		["-"] = { "^", desc = "Move to first non-blank character of the line" },
		["~"] = { "Vyp", desc = "Yank and pase to next line" },
	},
}
