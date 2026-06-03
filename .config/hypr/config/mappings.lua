local mainMod = "SUPER" -- Sets "Windows" key as main modifier

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

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("dms ipc call mpris next"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("dms ipc call mpris playPause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("dms ipc call mpris previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("dms ipc call mpris next"), { locked = true })

-- Session
hl.bind(mainMod .. "+ X", hl.dsp.exec_cmd("dms ipc call lock lock"), { locked = true })

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
