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
		opts = {
			-- Server Configuration
			port_range = { min = 10000, max = 65535 },
			auto_start = true,
			log_level = "info", -- "trace", "debug", "info", "warn", "error"
			terminal_cmd = nil, -- Custom terminal command (default: "claude")
			-- For local installations: "~/.claude/local/claude"
			-- For native binary: use output from 'which claude'

			-- Send/Focus Behavior
			-- When true, successful sends focus the in-editor Claude terminal if already
			-- connected. NOTE: this only works for in-editor providers (snacks/native);
			-- it has no effect with provider = "none"/"external" (Claude runs outside
			-- Neovim). For those, hook the `User ClaudeCodeSendComplete` event (see Events).
			focus_after_send = false,

			-- Selection Tracking
			track_selection = true,
			visual_demotion_delay_ms = 50,

			-- Terminal Configuration
			terminal = {
				split_side = "right", -- "left" or "right"
				split_width_percentage = 0.30,
				-- Optional: shrink (or widen) the terminal while a diff is open. Defaults to
				-- split_width_percentage when unset, preserving today's behavior.
				diff_split_width_percentage = nil, -- e.g. 0.20 to give diffs more room
				provider = "auto", -- "auto", "snacks", "native", "external", "none", or custom provider table
				auto_close = true,
				-- Auto-enter insert/terminal mode whenever the Claude terminal window gains
				-- focus. Set to false to stay in Normal mode and preserve your scroll position
				-- when switching back to the terminal (e.g. via <C-w>l); press `i` to type.
				-- Note: false also opens the terminal in Normal mode (it gates start-insert too).
				auto_insert = true,
				snacks_win_opts = {}, -- Opts to pass to `Snacks.terminal.open()` - see Floating Window section below
				-- Work around a Neovim core bug (< 0.12.2) that fragments large pastes into
				-- the terminal, making Cmd+V appear to truncate ([#161]). true | false | "auto"
				-- ("auto", the default, enables it only on affected Neovim versions).
				fix_streamed_paste = "auto",

				-- Provider-specific options
				provider_opts = {
					-- Command for external terminal provider. Can be:
					-- 1. String with %s placeholder: "alacritty -e %s" (backward compatible)
					-- 2. String with two %s placeholders: "alacritty --working-directory %s -e %s" (cwd, command)
					-- 3. Function returning command: function(cmd, env) return "alacritty -e " .. cmd end
					external_terminal_cmd = nil,
				},
			},

			-- Diff Integration
			diff_opts = {
				layout = "horizontal", -- "vertical" (default), "horizontal", or "unified"
				-- "unified": VS Code-style unified diff in a single buffer with deleted
				--   (red/strikethrough) and added (green) lines interleaved. Requires
				--   Neovim >= 0.9.0. Highlight groups are customizable: ClaudeCodeInlineDiffAdd,
				--   ClaudeCodeInlineDiffDelete, ClaudeCodeInlineDiffAddSign, ClaudeCodeInlineDiffDeleteSign.
				open_in_new_tab = false,
				keep_terminal_focus = false, -- If true, moves focus back to terminal after diff opens
				hide_terminal_in_new_tab = false,
				auto_resize_terminal = true, -- Let the plugin manage the terminal width across the diff lifecycle; set false to own it via the User autocmds below
				-- on_new_file_reject = "keep_empty", -- "keep_empty" or "close_window"

				-- Legacy aliases (still supported):
				-- vertical_split = true,
				-- open_in_current_tab = true,
			},
		},
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
