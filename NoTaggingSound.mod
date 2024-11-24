return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`NoTaggingSound` encountered an error loading the Darktide Mod Framework.")

		new_mod("NoTaggingSound", {
			mod_script       = "NoTaggingSound/scripts/mods/NoTaggingSound/NoTaggingSound",
			mod_data         = "NoTaggingSound/scripts/mods/NoTaggingSound/NoTaggingSound_data",
			mod_localization = "NoTaggingSound/scripts/mods/NoTaggingSound/NoTaggingSound_localization",
		})
	end,
	packages = {},
}
