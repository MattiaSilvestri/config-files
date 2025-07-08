--- @type LazySpec
local actions = require("telescope.actions")
-- local lga_actions = require("telescope-live-grep-args.actions")

return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"jonarrien/telescope-cmdline.nvim",
			"nvim-telescope/telescope-live-grep-args.nvim",
		},
		opts = {
			defaults = {
				-- border = true,
				-- layout_strategy = "cursor",
				-- layout_config = {
				-- 	horizontal = {
				-- 		height = 0.8,
				-- 		width = 0.8,
				-- 		preview_width = 0.5,
				-- 	},
				-- 	vertical = {
				-- 		height = 0.99,
				-- 		width = 0.99,
				-- 		preview_height = 0.5,
				-- 	},
				-- 	cursor = {
				-- 		height = 0.8,
				-- 		width = 0.8,
				-- 		preview_height = 0.5,
				-- 		preview_width = 0.5,
				-- 	},
				-- },
				mappings = {
					i = {
						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
					},
				},
			},
			extensions = {
				cmdline = {
					picker = {
						layout_config = {
							width = 120,
							height = 25,
						},
					},
					-- Adjust your mappings
					mappings = {
						complete = "<Tab>",
						run_selection = "<C-CR>",
						run_input = "<CR>",
					},
					-- Triggers any shell command using overseer.nvim (`:!`)
					overseer = {
						enabled = true,
					},
				},
			},
		},
		config = function(_, opts)
			require("telescope").setup(opts)
			require("telescope").load_extension("cmdline")
			require("telescope").load_extension("live_grep_args")

			local lga_actions = require("telescope-live-grep-args.actions")

			-- Now override or patch mappings inside the extension
			require("telescope").extensions.live_grep_args = {
				auto_quoting = true, -- enable/disable auto-quoting
				-- define mappings, e.g.
				mappings = {     -- extend mappings
					i = {
						["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt(),
						["<C-i>"] = require("telescope-live-grep-args.actions").quote_prompt({
							postfix = " --iglob ",
						}),
						-- freeze the current list and start a fuzzy search in the frozen list
						["<C-space>"] = require("telescope-live-grep-args.actions").to_fuzzy_refine,
					},
				},
				-- ... also accepts theme settings, for example:
				-- theme = "dropdown", -- use dropdown theme
				-- theme = { }, -- use own theme spec
				-- layout_config = { mirror=true }, -- mirror preview pane
			}
		end,
	},
}
