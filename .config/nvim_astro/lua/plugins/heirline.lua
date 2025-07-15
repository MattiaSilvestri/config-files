--- @type LazySpec
return {
  "rebelot/heirline.nvim",
  dependencies = {
    { -- configure AstroUI to include a new UI icon
      "AstroNvim/astroui",
      ---@type AstroUIOpts
      opts = {
        icons = {
          Clock = "", -- add icon for clock
        },
      },
    },
  },
  opts = function(_, opts)
    local status = require "astroui.status"
    local conditions = require "heirline.conditions"
    local utils = require "heirline.utils"
    local FileNameBlock = {
      -- let's first set up some attributes needed by this component and its children
      init = function(self) self.filename = vim.api.nvim_buf_get_name(0) end,
    }
    -- We can now define some children separately and add them later

    local FileIcon = {
      provider = function() return "  " end,
      hl = function(self) return { fg = "fg" } end,
    }

    local FileName = {
      provider = function(self)
        -- first, trim the pattern relative to the current directory. For other
        -- options, see :h filename-modifers
        local filename = vim.fn.fnamemodify(self.filename, ":.")
        if filename == "" then return "[No Name]" end
        -- now, if the filename would occupy more than 1/4th of the available
        -- space, we trim the file path to its initials
        -- See Flexible Components section below for dynamic truncation
        if not conditions.width_percent_below(#filename, 0.25) then filename = vim.fn.pathshorten(filename) end
        return filename
      end,
      hl = { fg = "fg" },
    }

    local FileFlags = {
      {
        condition = function() return vim.bo.modified end,
        provider = "",
        hl = { fg = "#a6e3a1" },
      },
      {
        condition = function() return not vim.bo.modifiable or vim.bo.readonly end,
        provider = "",
        hl = { fg = "orange" },
      },
    }

    -- Now, let's say that we want the filename color to change if the buffer is
    -- modified. Of course, we could do that directly using the FileName.hl field,
    -- but we'll see how easy it is to alter existing components using a "modifier"
    -- component

    local FileNameModifer = {
      hl = function()
        if vim.bo.modified then
          -- use `force` because we need to override the child's hl foreground
          return { fg = "#eba0ac", bold = false, force = true }
        end
      end,
    }
    opts.statusline = { -- statusline
      hl = { fg = "fg", bg = "bg" },
      status.component.mode(),
      status.component.git_branch(),
      status.component.file_info(),
      status.component.git_diff(),
      status.component.diagnostics(),
      -- status.component.builder {
      --   provider = function()
      --     local icon = " "
      --     local cwd = vim.fn.getcwd(0)
      --     cwd = vim.fn.fnamemodify(cwd, ":~")
      --     if not conditions.width_percent_below(#cwd, 0.25) then cwd = vim.fn.pathshorten(cwd) end
      --     local trail = cwd:sub(-1) == "/" and "" or "/"
      --     return icon .. cwd .. trail
      --   end,
      --   hl = { fg = "fg", bold = false },
      -- },
      status.component.builder {
        utils.insert(
          FileNameBlock,
          FileIcon,
          utils.insert(FileNameModifer, FileName), -- a new table where FileName is a child of FileNameModifier
          FileFlags,
          { provider = "%<" } -- this means that the statusline is cut here when there's not enough space
        ),
      },
      status.component.fill(),
      status.component.cmd_info(),
      status.component.fill(),
      status.component.lsp(),
      status.component.virtual_env(),
      status.component.treesitter(),
      status.component.nav(),
      status.component.mode { surround = { separator = "right" } },
    }
  end,
}
