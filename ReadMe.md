# 🎌 Flagpole Script for QBCore Framework

## 📖 Introduction
This **Flagpole Script** lets players interact with flagpoles and flags in your QBCore-based FiveM server. Players can place, customize, and manage flagpoles with dynamic controls and persistent data. 🏴

---

## 🌟 Features
✨ **Place Flagpoles**: Players can place flagpoles in the game world.  
🎏 **Attach Flags**: Choose from a variety of flags in your inventory.  
⬆️ **Raise and Lower Flags**: Use keys to dynamically adjust flag height.  
🗺️ **Blip Customization**: Rename and adjust the map blip for your flagpole.  
💾 **Data Persistence**: Automatically saves flagpole and flag data to the database.

---

## 🛠️ Requirements
- **Framework**: QBCore Framework.  
- **Targeting System**: Compatible with `qb-target`

---

## 🚀 Installation
1. 📂 Place the resource folder in your server’s `resources` directory.  
2. 📝 Add `ensure <resource_name>` to your `server.cfg`.  
3. 🔧 Configure the script by updating the `Config` table to match your server setup.  
4. 🛠️ **Add Items**: Insert the required items into `qb-core/shared/items.lua`.  

### Add the Following Items:
```lua
-- Flagpole item
["flagpole"] = {
    name = "flagpole",
    label = "Flagpole",
    weight = 1000,
    type = "item",
    image = "flagpole.png", -- Ensure the image exists in your inventory images folder
    unique = false,
    useable = false,
    shouldClose = true,
    description = "A pole to hold your flags high!"
},

-- US Flag item
["flag_us"] = {
    name = "flag_us",
    label = "US Flag",
    weight = 500,
    type = "item",
    image = "flag_us.png", -- Ensure the image exists in your inventory images folder
    unique = false,
    useable = false,
    shouldClose = true,
    description = "Wave the stars and stripes proudly!"
},

-- UK Flag item
["flag_uk"] = {
    name = "flag_uk",
    label = "UK Flag",
    weight = 500,
    type = "item",
    image = "flag_uk.png", -- Ensure the image exists in your inventory images folder
    unique = false,
    useable = false,
    shouldClose = true,
    description = "Raise the Union Jack!"
}
```

5. 🎨 Add appropriate item icons to your inventory image directory.  
6. ✅ Restart your server and test the script functionality! 🚩

---

## ⚙️ Configuration
Customize the script in the `Config` section:

```lua
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
        }
    },
    PlacementDistance = 2.5, -- 📏 Distance for flagpole interaction.
    FlagRaiseSpeed = 0.1, -- ⬆️ Speed at which flags are raised.
    FlagHeightMin = 1.2, -- 📐 Minimum flag height.
    FlagHeightMax = 6.7, -- 📐 Maximum flag height.
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
```
---

## 🎮 Controls
- **[E]**: Raise the flag.  
- **[Q]**: Lower the flag.  
- **Proximity Required**: Players must be near the flagpole to interact.

---

## 🖼️ Example Blip Customization
```lua
function CustomizeBlip(defaultName, defaultIcon, defaultColor, callback)
    local input = lib.inputDialog("Customize Blip", {
        { type = "input", label = "Blip Name", default = defaultName, required = true },
        { type = "number", label = "Blip Icon (default: 1)", default = defaultIcon or 1 },
        { type = "number", label = "Blip Color (default: 3)", default = defaultColor or 3 },
    })
    -- Save the customizations to the server here!
end
```
---