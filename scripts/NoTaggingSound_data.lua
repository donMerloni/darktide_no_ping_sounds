local mod = get_mod("NoTaggingSound")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
        widgets = {
            {
                setting_id = "ping_mute_all",
                type = "checkbox",
                default_value = true,
                sub_widgets = {
                    {
                        setting_id = "ping_unmute_all_behind",
                        type = "checkbox",
                        default_value = true
                    }
                }
            }
        }
    }	
}
