--- @type LazySpec
return {
	"rebelot/heirline.nvim",
	dependencies = { "Zeioth/heirline-components.nvim" },
	opts = function(_, opts)
		-- Setup components
		local components = require("heirline-components.all")
		local status = require("heirline-components.all").component
		components.init.subscribe_to_events()

		local conditions = require("heirline.conditions")
		local utils = require("heirline.utils")
		local catppuccin = require("catppuccin.palettes").get_palette("mocha")
		local colors = {
			status_bg = catppuccin.mantle,
			bright_bg = utils.get_highlight("Folded").bg,
			bright_fg = utils.get_highlight("Folded").fg,
			red = utils.get_highlight("DiagnosticError").fg,
			dark_red = utils.get_highlight("DiffDelete").bg,
			green = utils.get_highlight("String").fg,
			blue = utils.get_highlight("Function").fg,
			gray = utils.get_highlight("NonText").fg,
			orange = utils.get_highlight("Constant").fg,
			purple = utils.get_highlight("Statement").fg,
			cyan = utils.get_highlight("Special").fg,
			diag_warn = utils.get_highlight("DiagnosticWarn").fg,
			diag_error = utils.get_highlight("DiagnosticError").fg,
			diag_hint = utils.get_highlight("DiagnosticHint").fg,
			diag_info = utils.get_highlight("DiagnosticInfo").fg,
			git_del = utils.get_highlight("diffDeleted").fg,
			git_add = utils.get_highlight("diffAdded").fg,
			git_change = utils.get_highlight("diffChanged").fg,
		}
		local ViMode = {
			-- get vim current mode, this information will be required by the provider
			-- and the highlight functions, so we compute it only once per component
			-- evaluation and store it as a component attribute
			init = function(self)
				self.mode = vim.fn.mode(1) -- :h mode()
			end,
			-- Now we define some dictionaries to map the output of mode() to the
			-- corresponding string and color. We can put these into `static` to compute
			-- them at initialisation time.
			static = {
				mode_names = { -- change the strings if you like it vvvvverbose!
					n = "N",
					no = "N?",
					nov = "N?",
					noV = "N?",
					["no\22"] = "N?",
					niI = "Ni",
					niR = "Nr",
					niV = "Nv",
					nt = "Nt",
					v = "V",
					vs = "Vs",
					V = "V_",
					Vs = "Vs",
					["\22"] = "^V",
					["\22s"] = "^V",
					s = "S",
					S = "S_",
					["\19"] = "^S",
					i = "I",
					ic = "Ic",
					ix = "Ix",
					R = "R",
					Rc = "Rc",
					Rx = "Rx",
					Rv = "Rv",
					Rvc = "Rv",
					Rvx = "Rv",
					c = "C",
					cv = "Ex",
					r = "...",
					rm = "M",
					["r?"] = "?",
					["!"] = "!",
					t = "T",
				},
				mode_colors = {
					n = "red",
					i = "green",
					v = "cyan",
					V = "cyan",
					["\22"] = "cyan",
					c = "orange",
					s = "purple",
					S = "purple",
					["\19"] = "purple",
					R = "orange",
					r = "orange",
					["!"] = "red",
					t = "red",
				},
			},
			-- We can now access the value of mode() that, by now, would have been
			-- computed by `init()` and use it to index our strings dictionary.
			-- note how `static` fields become just regular attributes once the
			-- component is instantiated.
			-- To be extra meticulous, we can also add some vim statusline syntax to
			-- control the padding and make sure our string is always at least 2
			-- characters long. Plus a nice Icon.
			provider = function(self)
				return " %2(" .. self.mode_names[self.mode] .. "%)"
			end,
			-- Same goes for the highlight. Now the foreground will change according to the current mode.
			hl = function(self)
				local mode = self.mode:sub(1, 1) -- get only the first mode character
				return { fg = self.mode_colors[mode], bold = true }
			end,
			-- Re-evaluate the component only on ModeChanged event!
			-- Also allows the statusline to be re-evaluated when entering operator-pending mode
			update = {
				"ModeChanged",
				pattern = "*:*",
				callback = vim.schedule_wrap(function()
					vim.cmd("redrawstatus")
				end),
			},
		}
		local FileNameBlock = {
			-- let's first set up some attributes needed by this component and its children
			init = function(self)
				self.filename = vim.api.nvim_buf_get_name(0)
			end,
		}
		-- We can now define some children separately and add them later

		local FileIcon = {
			provider = function()
				return "  "
			end,
			hl = function(self)
				return { fg = "fg" }
			end,
		}

		local FileName = {
			provider = function(self)
				-- first, trim the pattern relative to the current directory. For other
				-- options, see :h filename-modifers
				local filename = vim.fn.fnamemodify(self.filename, ":.")
				if filename == "" then
					return "[No Name]"
				end
				-- now, if the filename would occupy more than 1/4th of the available
				-- space, we trim the file path to its initials
				-- See Flexible Components section below for dynamic truncation
				if not conditions.width_percent_below(#filename, 0.25) then
					filename = vim.fn.pathshorten(filename)
				end
				return filename
			end,
			hl = { fg = "fg" },
		}

		local FileFlags = {
			{
				condition = function()
					return vim.bo.modified
				end,
				provider = "",
				hl = { fg = "#a6e3a1" },
			},
			{
				condition = function()
					return not vim.bo.modifiable or vim.bo.readonly
				end,
				provider = "",
				hl = { fg = "orange" },
			},
		}

		local FileNameModifer = {
			hl = function()
				if vim.bo.modified then
					-- use `force` because we need to override the child's hl foreground
					return { fg = "#eba0ac", bold = false, force = true }
				end
			end,
		}

		FileNameBlock = utils.insert(
			FileNameBlock,
			FileIcon,
			utils.insert(FileNameModifer, FileName), -- a new table where FileName is a child of FileNameModifier
			FileFlags,
			{ provider = "%<" } -- this means that the statusline is cut here when there's not enough space
		)

		local FileType = {
			provider = function()
				return string.upper(vim.bo.filetype)
			end,
			hl = { fg = utils.get_highlight("Type").fg, bold = true },
		}

		local FileSize = {
			provider = function()
				-- stackoverflow, compute human readable file size
				local suffix = { "b", "k", "M", "G", "T", "P", "E" }
				local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
				fsize = (fsize < 0 and 0) or fsize
				if fsize < 1024 then
					return fsize .. suffix[1]
				end
				local i = math.floor((math.log(fsize) / math.log(1024)))
				return string.format("%.2g%s", fsize / math.pow(1024, i), suffix[i + 1])
			end,
		}

		local FileLastModified = {
			-- did you know? Vim is full of functions!
			provider = function()
				local ftime = vim.fn.getftime(vim.api.nvim_buf_get_name(0))
				return (ftime > 0) and os.date("%c", ftime)
			end,
		}

		local Ruler = {
			-- %l = current line number
			-- %L = number of lines in the buffer
			-- %c = column number
			-- %P = percentage through file of displayed window
			provider = "%7(%l/%3L%):%2c %P",
		}

		local ScrollBar = {
			static = {
				sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
				-- Another variant, because the more choice the better.
				-- sbar = { "🭶", "🭷", "🭸", "🭹", "🭺", "🭻" },
			},
			provider = function(self)
				local curr_line = vim.api.nvim_win_get_cursor(0)[1]
				local lines = vim.api.nvim_buf_line_count(0)
				local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
				return string.rep(self.sbar[i], 2)
			end,
			hl = { fg = colors.blue, bg = colors.bright_bg },
		}

		local LSPActive = {
			condition = conditions.lsp_attached,
			update = { "LspAttach", "LspDetach" },

			-- You can keep it simple,
			-- provider = " [LSP]",

			-- Or complicate things a bit and get the servers names
			provider = function()
				local names = {}
				for i, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
					table.insert(names, server.name)
				end
				return " [" .. table.concat(names, " ") .. "]"
			end,
			hl = { fg = "green", bold = true },
		}

		-- local Diagnostics = {
		--
		-- 	condition = conditions.has_diagnostics,
		--
		-- 	static = {
		-- 		error_icon = vim.fn.sign_getdefined("DiagnosticSignError")[1].text,
		-- 		warn_icon = vim.fn.sign_getdefined("DiagnosticSignWarn")[1].text,
		-- 		info_icon = vim.fn.sign_getdefined("DiagnosticSignInfo")[1].text,
		-- 		hint_icon = vim.fn.sign_getdefined("DiagnosticSignHint")[1].text,
		-- 	},
		--
		-- 	init = function(self)
		-- 		self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
		-- 		self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
		-- 		self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
		-- 		self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
		-- 	end,
		--
		-- 	update = { "DiagnosticChanged", "BufEnter" },
		--
		-- 	{
		-- 		provider = " ",
		-- 	},
		-- 	{
		-- 		provider = function(self)
		-- 			-- 0 is just another output, we can decide to print it or not!
		-- 			return self.errors > 0 and (self.error_icon .. self.errors .. " ")
		-- 		end,
		-- 		hl = { fg = colors.diag_error },
		-- 	},
		-- 	{
		-- 		provider = function(self)
		-- 			return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
		-- 		end,
		-- 		hl = { fg = colors.diag_warn },
		-- 	},
		-- 	{
		-- 		provider = function(self)
		-- 			return self.info > 0 and (self.info_icon .. self.info .. " ")
		-- 		end,
		-- 		hl = { fg = colors.diag_info },
		-- 	},
		-- 	{
		-- 		provider = function(self)
		-- 			return self.hints > 0 and (self.hint_icon .. self.hints)
		-- 		end,
		-- 		hl = { fg = colors.diag_hint },
		-- 	},
		-- 	{
		-- 		provider = "  ",
		-- 	},
		-- }

		local Align = { provider = "%=" }
		local Space = { provider = " " }

		opts.winbar = {
			status.breadcrumbs(),
		}

		opts.statusline = { -- statusline
			colors = colors,
			hl = { fg = "fg", bg = colors.status_bg },
			status.mode(),
			status.git_branch(),
			status.file_info(),
			status.git_diff(),
			status.diagnostics(),
			FileNameBlock,
			status.fill(),
			status.cmd_info(),
			Align,
			-- Navic,
			-- DAPMessages,
			status.virtual_env(),
			status.lsp(),
			-- LSPMessages,
			status.treesitter(),
			-- UltTest,
			Space,
			Ruler,
			Space,
			ScrollBar,
			status.mode({ surround = { separator = "right" } }),
		}
	end,
}
