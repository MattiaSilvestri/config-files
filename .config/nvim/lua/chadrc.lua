local M = {}

-- Import components
-- local components = require("heirline-components.all")
-- local status = require("heirline-components.all").component
local stbufnr = function()
	return vim.api.nvim_get_current_buf()
end

M = {
	base46 = { theme = "catppuccin", integrations = { "telescope", "blink" } },

	ui = {
		statusline = {
			enabled = true,
			theme = "minimal",
			order = {
				"mode",
				"file_path",
				"git",
				"%=",
				"lsp_msg",
				"%=",
				"diagnostics",
				"all_lsp",
				"venv",
				"cwd",
				"cursor",
			},
			modules = {
				all_lsp = function()
					local buf_clients = vim.lsp.get_clients({ bufnr = stbufnr() })
					if #buf_clients == 0 then
						return ""
					end

					local names = {}

					for _, client in pairs(buf_clients) do
						if client.name ~= "null-ls" and client.attached_buffers[stbufnr()] then
							table.insert(names, client.name)
						end
					end

					-- Check for formatters/linters from null-ls or none-ls
					local null_ls_ok, null_ls = pcall(require, "null-ls")
					if null_ls_ok then
						local sources = require("null-ls.sources").get_available(vim.bo.filetype)
						for _, source in ipairs(sources) do
							if not vim.tbl_contains(names, source.name) then
								table.insert(names, source.name)
							end
						end
					end

					if #names > 0 then
						return (vim.o.columns > 100 and "   " .. table.concat(names, ", ") .. " ") or "   "
					else
						return ""
					end
				end,

				file_path = function()
					local icon = "󰈚"
					local bufnr = stbufnr()
					local path = vim.api.nvim_buf_get_name(bufnr)
					local relpath = "Empty"

					if path ~= "" then
						relpath = vim.fn.fnamemodify(path, ":.")
						if relpath == "" then
							relpath = vim.fn.fnamemodify(path, ":t")
						end
					end

					if relpath ~= "Empty" then
						local devicons_present, devicons = pcall(require, "nvim-web-devicons")
						if devicons_present then
							local filename = vim.fn.fnamemodify(path, ":t")
							local ft_icon = devicons.get_icon(filename)
							icon = (ft_icon ~= nil and ft_icon) or icon
						end
					end

					if relpath ~= "Empty" and vim.o.columns < 120 then
						relpath = vim.fn.pathshorten(relpath)
					end

					relpath = relpath:gsub("%%", "%%%%")

					local config = require("nvconfig").ui.statusline
					local utils = require("nvchad.stl.utils")
					local sep_style = config.separator_style
					sep_style = (sep_style ~= "round" and sep_style ~= "block") and "block" or sep_style
					local sep_icons = utils.separators
					local separators = (type(sep_style) == "table" and sep_style) or sep_icons[sep_style]
					local sep_l = separators.left
					local sep_r = "%#St_sep_r#" .. separators.right .. " %#ST_EmptySpace#"

					return "%#St_file_sep#"
							.. sep_l
							.. "%#St_file_bg#"
							.. icon
							.. " "
							.. "%#St_file_txt# "
							.. relpath
							.. sep_r
				end,

				venv = function()
					local venv = vim.env.UV_VENV or vim.env.VIRTUAL_ENV
					if not venv or venv == "" then
						return ""
					end

					local function read_prompt(venv_path)
						local cfg = venv_path .. "/pyvenv.cfg"
						if vim.fn.filereadable(cfg) ~= 1 then
							return nil
						end
						for _, line in ipairs(vim.fn.readfile(cfg)) do
							local prompt = line:match("^prompt%s*=%s*(.+)$")
							if prompt and prompt ~= "" then
								prompt = prompt:gsub("^%((.*)%)$", "%1")
								prompt = prompt:gsub("^%[(.*)%]$", "%1")
								return prompt
							end
						end
						return nil
					end

					local name = vim.fn.fnamemodify(venv, ":t")
					local cfg_prompt = read_prompt(venv)
					if cfg_prompt and cfg_prompt ~= "" then
						name = cfg_prompt
					elseif name == ".venv" or name == "venv" or name == ".env" then
						name = vim.fn.fnamemodify(venv, ":h:t")
					end
					if name == "" then
						return ""
					end

					name = name:gsub("%%", "%%%%")
					name = name:gsub("^%((.*)%)$", "%1")
					name = name:gsub("^%[(.*)%]$", "%1")

					local config = require("nvconfig").ui.statusline
					local utils = require("nvchad.stl.utils")
					local sep_style = config.separator_style
					sep_style = (sep_style ~= "round" and sep_style ~= "block") and "block" or sep_style
					local sep_icons = utils.separators
					local separators = (type(sep_style) == "table" and sep_style) or sep_icons[sep_style]
					local sep_l = separators.left
					local sep_r = "%#St_sep_r#" .. separators.right .. " %#ST_EmptySpace#"

					return "%#St_cwd_sep#" .. sep_l .. "%#St_cwd_bg#" .. " " .. "%#St_cwd_txt# " .. name .. sep_r
				end,
			},
		},
		telescope = { style = "borderless" }, -- borderless / bordered
		tabufline = {
			enabled = false,
			lazyload = true,
			order = { "treeOffset", "buffers", "tabs", "btns" },
			modules = nil,
			bufwidth = 21,
		},
	},
	cmp = {
		style = "default",
		format_colors = {
			tailwind = false,
		},
	},
	nvdash = {
		load_on_startup = false,

		header = {
			"                            ",
			"     ▄▄         ▄ ▄▄▄▄▄▄▄   ",
			"   ▄▀███▄     ▄██ █████▀    ",
			"   ██▄▀███▄   ███           ",
			"   ███  ▀███▄ ███           ",
			"   ███    ▀██ ███           ",
			"   ███      ▀ ███           ",
			"   ▀██ █████▄▀█▀▄██████▄    ",
			"     ▀ ▀▀▀▀▀▀▀ ▀▀▀▀▀▀▀▀▀▀   ",
			"                            ",
			"     Powered By  eovim    ",
			"                            ",
		},

		buttons = {
			{ txt = "  Find File", keys = "Spc f f", cmd = "Telescope find_files" },
			{ txt = "  Recent Files", keys = "Spc f o", cmd = "Telescope oldfiles" },
			-- more... check nvconfig.lua file for full list of buttons
		},
	},
	lsp = { signature = false },
	colorify = {
		enabled = true,
		mode = "virtual", -- fg, bg, virtual
		virt_text = "󱓻 ",
		highlight = { hex = true, lspvars = true },
	},
}

return M
