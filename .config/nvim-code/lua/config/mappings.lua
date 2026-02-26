return {
	x = {
		["<leader>/"] = { "<Plug>(comment_toggle_linewise_visual)", remap = true, desc = "Toggle comment" },
	},
	n = {
		-- Pane navigation --
		["<C-H>"] = { "<C-w>h", desc = "Move to left split" },
		["<C-J>"] = { "<C-w>j", desc = "Move to below split" },
		["<C-K>"] = { "<C-w>k", desc = "Move to above split" },
		["<C-L>"] = { "<C-w>l", desc = "Move to right split" },
		["<C-Up>"] = { "<Cmd>resize -2<CR>", desc = "Resize split up" },
		["<C-Down>"] = { "<Cmd>resize +2<CR>", desc = "Resize split down" },
		["<C-Left>"] = { "<Cmd>vertical resize -2<CR>", desc = "Resize split left" },
		["<C-Right>"] = { "<Cmd>vertical resize +2<CR>", desc = "Resize split right" },
	},
}
