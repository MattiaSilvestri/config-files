--- @type LazySpec
return {
	{
		"Exafunction/codeium.vim",
		enabled = false,
		event = "BufEnter",
		config = function()
			-- Change '<C-g>' here to any keycode you like.
			vim.keymap.set("i", "<C-l>", function()
				return vim.fn["codeium#Accept"]()
			end, { expr = true })
		end,
	},
	{
		"Exafunction/windsurf.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("codeium").setup({
				-- Optionally disable cmp source if using virtual text only
				enable_cmp_source = false,
				enable_chat = true,
				virtual_text = {
					enabled = true,

					-- These are the defaults

					-- Set to true if you never want completions to be shown automatically.
					manual = false,
					-- A mapping of filetype to true or false, to enable virtual text.
					filetypes = {},
					-- Whether to enable virtual text of not for filetypes not specifically listed above.
					default_filetype_enabled = true,
					-- How long to wait (in ms) before requesting completions after typing stops.
					idle_delay = 75,
					-- Priority of the virtual text. This usually ensures that the completions appear on top of
					-- other plugins that also add virtual text, such as LSP inlay hints, but can be modified if
					-- desired.
					virtual_text_priority = 65535,
					-- Set to false to disable all key bindings for managing completions.
					map_keys = true,
					-- The key to press when hitting the accept keybinding but no completion is showing.
					-- Defaults to \t normally or <c-n> when a popup is showing.
					accept_fallback = nil,
					-- Key bindings for managing completions in virtual text mode.
					key_bindings = {
						-- Accept the current completion.
						accept = "<C-l>",
						-- Accept the next word.
						accept_word = false,
						-- Accept the next line.
						accept_line = false,
						-- Clear the virtual text.
						clear = false,
						-- Cycle to the next completion.
						next = "<M-]>",
						-- Cycle to the previous completion.
						prev = "<M-[>",
					},
				},
			})
		end,
	},
	{ "rhart92/codex.nvim" },
	{
		"nickjvandyke/opencode.nvim",
		version = "*", -- Latest stable release
		dependencies = {
			{
				-- `snacks.nvim` integration is recommended, but optional
				---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
				"folke/snacks.nvim",
				optional = true,
				opts = {
					input = {}, -- Enhances `ask()`
					picker = { -- Enhances `select()`
						actions = {
							opencode_send = function(...)
								return require("opencode").snacks_picker_send(...)
							end,
						},
						win = {
							input = {
								keys = {
									["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
								},
							},
						},
					},
				},
			},
		},
		config = function()
			---@type opencode.Opts
			vim.g.opencode_opts = {
				-- Your configuration, if any; goto definition on the type or field for details
			}

			vim.o.autoread = true -- Required for `opts.events.reload`
		end,
	},
	{
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		config = true,
		-- `cmd` lets lazy.nvim create command stubs that load the plugin on first use,
		-- so `:ClaudeCode` and friends work on a fresh start. Without it, a keys-only
		-- spec defers loading until a <leader>a* mapping is pressed and the commands
		-- would not exist yet.
		cmd = {
			"ClaudeCode",
			"ClaudeCodeFocus",
			"ClaudeCodeSelectModel",
			"ClaudeCodeAdd",
			"ClaudeCodeSend",
			"ClaudeCodeTreeAdd",
			"ClaudeCodeStatus",
			"ClaudeCodeStart",
			"ClaudeCodeStop",
			"ClaudeCodeOpen",
			"ClaudeCodeClose",
			"ClaudeCodeDiffAccept",
			"ClaudeCodeDiffDeny",
			"ClaudeCodeCloseAllDiffs",
		},
		keys = {
			{ "<leader>a", nil, desc = "AI/Claude Code" },
			{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
			{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
			{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
			{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
			{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
			{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
			{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
			{
				"<leader>as",
				"<cmd>ClaudeCodeTreeAdd<cr>",
				desc = "Add file",
				ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
			},
			-- Diff management
			{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
			{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
		},
	},
}
