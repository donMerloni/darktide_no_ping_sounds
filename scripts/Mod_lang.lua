local mod = get_mod("NoPingSounds")
local lang = {}

local function colored(text, color)
	return string.format("{#color(%d,%d,%d,%d)}%s{#reset()}", color[2], color[3], color[4], color[1], text)
end

-- taken from @scripts/foundation/utilities/color.lua
local alpha = 200
local colors = {
	ui_red_super_light = function(a)
		return { a, 242, 122, 99 }
	end,
	ui_green_light = function(a)
		return { a, 74, 199, 60 }
	end,
	player_slot_1 = function(a)
		return { a, 226, 210, 117 }
	end,
}

lang.mod_name = {
	en = "No Ping Sounds",
}
lang.mod_description = {
	en = "Removes the ping sound",
}

lang.ping_mute_enemy = {
	en = string.format("Mute ALL %s pings", colored("enemy", colors.ui_red_super_light(alpha))),
}
lang.ping_mute_enemy_doubletag = {
	en = string.format("Mute ALL %s pings (double-tag)", colored("enemy", colors.ui_red_super_light(alpha))),
}
lang.ping_mute_enemy_doubletag_description = {
	en = "e.g. Arbitrator Dog Ping",
}

lang.ping_mute_always = {
	en = "Always",
}
lang.ping_mute_if_visible = {
	en = "if visible",
}
lang.ping_mute_never = {
	en = "Off",
}

lang.ping_mute_item = {
	en = string.format("Mute ALL %s pings", colored("item", colors.ui_green_light(alpha))),
}

lang.ping_mute_location_ping = {
	en = string.format('Mute "%s" marker', colored("Let's go here", colors.player_slot_1(alpha))),
}
lang.ping_mute_location_attention = {
	en = string.format('Mute "%s" marker', colored("Scout that area", colors.player_slot_1(alpha))),
}
lang.ping_mute_location_threat = {
	en = string.format('Mute "%s" marker', colored("Enemy over there", colors.ui_red_super_light(alpha))),
}

lang.ping_duration = {
	en = "Override ping duration",
}
lang.ping_duration_seconds = {
	en = "Seconds",
}

lang.debug = {
	en = "Debug mode",
}

lang.debug_repeat_ping = {
	en = "Repeat your last ping or marker",
}
lang.debug_repeat_ping_description = {
	en = "Use this to test your settings",
}

return lang
