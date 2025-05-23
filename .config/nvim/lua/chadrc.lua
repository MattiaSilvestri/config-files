local M = {}

-- Import components
-- local components = require("heirline-components.all")
-- local status = require("heirline-components.all").component
local stbufnr = function()
	return vim.api.nvim_get_current_buf()
end

M = {
	base46 = { theme = "catppuccin" },

	ui = {
		statusline = {
			enabled = true,
			theme = "minimal",
			order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "all_lsp", "cwd", "cursor" },
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
					local path = vim.api.nvim_buf_get_name(stbufnr())

					-- Get relative path from current working dir
					local relpath = (path == "" and "Empty") or vim.fn.fnamemodify(path, ":~:.")

					if relpath ~= "Empty" then
						local devicons_present, devicons = pcall(require, "nvim-web-devicons")
						if devicons_present then
							local filename = vim.fn.fnamemodify(path, ":t")
							local ft_icon = devicons.get_icon(filename)
							icon = (ft_icon ~= nil and ft_icon) or icon
						end
					end

					return { icon, relpath }
				end,

				filetype = function()
					local ft = vim.bo.filetype or ""
					if ft == "" then
						return "No Filetype"
					end

					local icon = "" -- default generic file icon
					local devicons_present, devicons = pcall(require, "nvim-web-devicons")
					if devicons_present then
						local filename = vim.api.nvim_buf_get_name(0)
						local _, ext = filename:match("(.+)%.(.+)$")
						local ft_icon = devicons.get_icon(filename, ext, { default = true })
						icon = ft_icon or icon
					end

					return icon .. " " .. ft
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
