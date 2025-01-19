Config = {
    Debug = true, -- 🐛 Enable or disable debug mode.
    Target = 'qb-target', -- 🎯 Targeting system.
    FlagpoleModel = "prop_flagpole_1a", -- 🎋 Prop name for the flagpole.
    FlagpoleItem = "flagpole", -- 🎒 Item needed to place a flagpole.
    Flags = {
        US = {
            prop = "prop_flag_us", -- 🇺🇸 US flag prop.
            item = "flag_us", -- 🏳️ Item for the US flag.
        },
        UK = {
            prop = "prop_flag_uk_s", -- 🇬🇧 UK flag prop.
            item = "flag_uk", -- 🏴 Item for the UK flag.
        },
        Japan = {
            prop = "prop_flag_japan", 
            item = "flag_jp", 
        },
        France = {
            prop = "prop_flag_france", 
            item = "flag_fr", 
        },
        Canada = {
            prop = "prop_flag_canada", 
            item = "flag_ca", 
        },
        Scotland = {
            prop = "prop_flag_scotland_s", 
            item = "flag_sl", 
        },
        Russia = {
            prop = "prop_flag_russia", 
            item = "flag_rs", 
        },
        German = {
            prop = "prop_flag_german", 
            item = "flag_gm",
        },
        Ireland = {
            prop = "prop_flag_ireland", 
            item = "flag_gl",
        }
    },
    PlacementDistance = 2.5, -- 📏 Distance for flagpole interaction.
    FlagRaiseSpeed = 0.1, -- ⬆️ Speed at which flags are raised.
    FlagHeightMin = 1.2, -- 📐 Minimum flag height.
    FlagHeightMax = 6.2, -- 📐 Maximum flag height.
    ControlKeys = {
        RaiseFlag = 38, -- ⬆️ E to raise the flag.
        LowerFlag = 44, -- ⬇️ Q to lower the flag.
    },
    Blacklistedname = { -- 🚫 Blacklist for invalid blip names.
        "list",
        "of",
        "blacklisted",
        "name",
    }
}
