-- Ensure correct path to the split-monitor-workspaces lua files
package.path = package.path .. ";/home/mattia/.config/hypr/plugins/split-monitor-workspaces/lua/?.lua"

local M = {}

-- Load split-monitor-workspaces with error handling
local smw = require("split-monitor-workspaces")
-- Setup split-monitor-workspaces with configuration
smw.setup({
	workspace_count = 10, -- Create 10 persistent workspaces on each monitor
	enable_wrapping = true, -- Allow wrapping when cycling workspaces
	enable_persistent_workspaces = true, -- Keep workspaces alive even when empty
	enable_notifications = true, -- Show notifications on init and remap
	keep_focused = true, -- Keep the currently focused workspace when config is reloaded
})

M.smw = smw

return M
