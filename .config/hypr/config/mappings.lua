local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local menu = "dms ipc call spotlight toggle"

------------------
----  SHELL  ----
------------------
-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("dms ipc call brightness increment 5 '' "),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("dms ipc call brightness decrement 5 '' "),
	{ locked = true, repeating = true }
)
-- hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("noctalia msg brightness-up * 5%"), { locked = true, repeating = true })
-- hl.bind(
-- 	"XF86MonBrightnessDown",
-- 	hl.dsp.exec_cmd("noctalia msg brightness-down * 5%"),
-- 	{ locked = true, repeating = true }
-- )

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("dms ipc call mpris next"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("dms ipc call mpris playPause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("dms ipc call mpris previous"), { locked = true })
-- hl.bind("XF86AudioNext", hl.dsp.exec_cmd("dms ipc call mpris next"), { locked = true })

-- hl.bind("XF86AudioNext", hl.dsp.exec_cmd("noctalia msg media next"), { locked = true })
-- hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("noctalia msg media toggle"), { locked = true })
-- hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("noctalia msg media previous"), { locked = true })

-- Session
hl.bind(mainMod .. "+ X", hl.dsp.exec_cmd("hyprlock"), { locked = true })

------------------
----  WINDOWS  ----
------------------
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down", group_aware = true }))

hl.bind("CTRL + SHIFT + h", hl.dsp.window.move({ monitor = "l" }))
hl.bind("CTRL + SHIFT + l", hl.dsp.window.move({ monitor = "r" }))
hl.bind("CTRL + SHIFT + Left", hl.dsp.window.move({ monitor = "l" }))
hl.bind("CTRL + SHIFT + Right", hl.dsp.window.move({ monitor = "r" }))

hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind("ALT + TAB", hl.dsp.group.next())
hl.bind("ALT + SHIFT + TAB", hl.dsp.group.prev())

hl.bind(mainMod .. " + ALT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("CTRL + SPACE", hl.dsp.exec_cmd(menu))
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("dms ipc call powermenu toggle"))

hl.bind("ALT + SHIFT + Space", function()
	local layouts = { "scrolling", "dwindle", "master", "monocle" }
	local workspace = hl.get_active_workspace()
	local next_layout = "dwindle"

	if not workspace then
		return
	end

	for i = 1, #layouts do
		if layouts[i] == workspace.tiled_layout then
			local next_layout_idx = (i % #layouts) + 1
			next_layout = layouts[next_layout_idx]
			break
		end
	end

	hl.workspace_rule({ workspace = workspace.name, layout = next_layout })
end)

-------------------
---- HYMISSION ----
------------------

hl.plugin.hymission.gesture({
	fingers = 4,
	direction = "vertical",
	action = "toggle",
	args = "forceall",
})

hl.plugin.hymission.gesture({
	fingers = 4,
	direction = "vertical",
	action = "toggle",
	recommand = true,
})

hl.plugin.hymission.gesture({
	fingers = 4,
	direction = "vertical",
	action = "open",
	scope = "onlycurrentworkspace",
})

hl.plugin.hymission.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "scroll",
	mode = "layout",
})

-- Native alternative:
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "scroll_move" })

hl.plugin.hymission.gesture({
	fingers = 3,
	direction = "vertical",
	action = "workspace",
})

hl.bind("SUPER + S", hl.plugin.hymission.toggle)
hl.bind("SUPER + A", function()
	hl.plugin.hymission.toggle("forceall")
end)
hl.bind("SUPER + TAB", function()
	hl.plugin.hymission.toggle("onlycurrentworkspace")
end)
hl.bind("SUPER + Escape", hl.plugin.hymission.close)

-- SCROLLING --
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.layout("consume_or_expel next"))
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.layout("consume_or_expel prev"))
hl.bind(mainMod .. " + R", hl.dsp.layout("colresize +conf"))

-- HYPEREXPO
hl.bind("SUPER + O", function()
	hl.plugin.hyprexpo.expo("toggle")
end)

hl.define_submap("hyprexpo", function()
	hl.bind("h", function()
		hl.plugin.hyprexpo.kb_focus("left")
	end)
	hl.bind("l", function()
		hl.plugin.hyprexpo.kb_focus("right")
	end)
	hl.bind("k", function()
		hl.plugin.hyprexpo.kb_focus("up")
	end)
	hl.bind("j", function()
		hl.plugin.hyprexpo.kb_focus("down")
	end)
	hl.bind("return", function()
		hl.plugin.hyprexpo.kb_confirm()
	end)
	hl.bind("escape", function()
		hl.plugin.hyprexpo.expo("cancel")
	end)
end)

--- OVERVIEW
-- hl.config({
-- 	plugin = {
-- 		scrolloverview = {
-- 			gesture_distance = 300, -- how far is the "max" for the gesture
-- 			scale = 0.5, -- preferred overview scale
-- 			workspace_gap = 100,
-- 			wallpaper = 0, -- 0: global only, 1: per-workspace only, 2: both
-- 			blur = false, -- blur only the main overview wallpaper
--
-- 			shadow = {
-- 				enabled = false,
-- 				range = 50,
-- 				render_power = 3,
-- 				color = 0xee1a1a1a,
-- 			},
-- 		},
-- 	},
-- })

-- hl.bind("SUPER + o", function()
-- 	if hl.plugin and hl.plugin.scrolloverview then
-- 		hl.plugin.scrolloverview.overview("toggle")
-- 	end
-- end)
