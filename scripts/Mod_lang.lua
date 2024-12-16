local mod = get_mod("NoPingSounds")
local Breeds = require("scripts/settings/breed/breeds")
local Pickups = require("scripts/settings/pickup/pickups")

local function rgba(r, g, b, a)
	return { r, g, b, a * 255 }
end
local function rgb(r, g, b)
	return rgba(r, g, b, 1)
end

local stuff = {}

local colors = {
	chaos_beast_of_nurgle = rgb(216, 142, 14), -- Beast of Nurgle
	chaos_daemonhost = rgb(178, 211, 91), -- Daemonhost
	chaos_hound_mutator = rgb(139, 69, 19), -- Pox Hound
	chaos_hound = rgb(114, 110, 56), -- Pox Hound
	chaos_ogryn_bulwark = rgb(91, 125, 171), -- Bulwark
	chaos_ogryn_executor = rgb(188, 192, 191), -- Crusher
	chaos_ogryn_gunner = rgb(209, 198, 203), -- Reaper
	chaos_plague_ogryn = rgb(174, 179, 97), -- Plague Ogryn
	chaos_poxwalker_bomber = rgb(235, 38, 38), -- Poxburster
	chaos_spawn = rgb(115, 56, 95), -- Chaos Spawn
	cultist_berzerker = rgb(63, 168, 57), -- Dreg Rager
	cultist_captain = rgb(207, 193, 135), -- Admonition Champion
	cultist_flamer = rgb(63, 168, 57), -- Dreg Tox Flamer
	cultist_grenadier = rgb(63, 168, 57), -- Dreg Tox Bomber
	cultist_gunner = rgb(207, 193, 135), -- Dreg Gunner
	cultist_mutant = rgb(63, 168, 57), -- Mutant
	cultist_mutant_mutator = rgb(27, 133, 21), -- Mutant
	cultist_shocktrooper = rgb(63, 168, 57), -- Dreg Shotgunner
	renegade_berzerker = rgb(173, 43, 3), -- Scab Rager
	renegade_captain = rgb(173, 43, 3), -- Scab Captain
	renegade_executor = rgb(173, 43, 3), -- Scab Mauler
	renegade_flamer = rgb(252, 94, 45), -- Scab Flamer
	renegade_grenadier = rgb(252, 94, 45), -- Scab Bomber
	renegade_gunner = rgb(173, 43, 3), -- Scab Gunner
	renegade_netgunner = rgb(235, 38, 38), -- Scab Trapper
	renegade_shocktrooper = rgb(173, 43, 3), -- Scab Shotgunner
	renegade_sniper = rgb(235, 38, 38), -- Scab Sniper
	renegade_twin_captain = rgb(90, 30, 40), -- Rodin Karnak
	renegade_twin_captain_two = rgb(100, 40, 50), -- Rinda Karnak
}

local language = Managers.localization:language()
for _, v in pairs(Breeds) do
	if v.smart_tag_target_type then
		local r, g, b, a = unpack(colors[v.name])
		stuff["ping_mute_enemy_" .. v.name] = {
			[language] = string.format(
				"{#color(%d,%d,%d,%d)}%s{#reset()} %s",
				r,
				g,
				b,
				a,
				Localize(v.display_name),
				Localize("loc_setting_voice_chat_presets_mic_muted")
			),
		}
	end
end

stuff.mod_name = {
	en = "NoPingSounds",
}
stuff.mod_description = {
	en = "Removes the ping sound",
}

stuff.ping_mute_enemy = {
	en = "Mute ALL enemy pings",
}

stuff.ping_mute_in_front = {
	en = "only if in view",
}
stuff.ping_mute_in_front_description = {
	en = "This will only mute pings that happen WITHIN your view",
}

stuff.ping_mute_item = {
	en = "Mute ALL item pings",
}

stuff.ping_mute_location_ping = {
	en = 'Mute "Let\'s go here" marker',
}
stuff.ping_mute_location_attention = {
	en = 'Mute "Scout that area" marker',
}
stuff.ping_mute_location_threat = {
	en = 'Mute "Enemy over there" marker',
}

stuff.ping_duration = {
	en = "Override ping duration",
}
stuff.ping_duration_seconds = {
	en = "Seconds",
}

stuff.debug = {
	en = "Debug mode",
}

stuff.debug_repeat_ping = {
	en = "Repeat your last enemy/item/location ping",
}
stuff.debug_repeat_ping_description = {
	en = "This way you can test the settings",
}

return stuff
