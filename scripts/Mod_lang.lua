local mod = get_mod("NoPingSounds")
local lang = {}

lang.mod_name = {
	en = "No Ping Sounds",
}
lang.mod_description = {
	en = "Removes the ping sound",
}

lang.ping_mute_enemy = {
	en = "Mute ALL enemy pings",
}

lang.ping_mute_enemy_in_front = {
	en = "only if in view",
}
lang.ping_mute_enemy_in_front_description = {
	en = "This will only mute pings that happen WITHIN your view",
}

lang.ping_mute_enemy_doubletag = {
	en = "Mute ALL enemy pings (double-tag)",
}
lang.ping_mute_enemy_doubletag_description = {
	en = "e.g. Arbitrator Dog Ping",
}

lang.ping_mute_enemy_doubletag_in_front = lang.ping_mute_enemy_in_front
lang.ping_mute_enemy_doubletag_in_front_description = lang.ping_mute_enemy_in_front_description

lang.ping_mute_item = {
	en = "Mute ALL item pings",
}

lang.ping_mute_location_ping = {
	en = 'Mute "Let\'s go here" marker',
}
lang.ping_mute_location_attention = {
	en = 'Mute "Scout that area" marker',
}
lang.ping_mute_location_threat = {
	en = 'Mute "Enemy over there" marker',
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
	en = "Repeat your last enemy/item/location ping",
}
lang.debug_repeat_ping_description = {
	en = "This way you can test the settings",
}

return lang
