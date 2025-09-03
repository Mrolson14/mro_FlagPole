# 🎌 Flagpole Script for Q## 🚀 Installation
1. 📂 Place the resource folder in your server's `resources` directory.  
2. 📝 Add `ensure <resource_name>` to your `server.cfg`.  
3. 🗄️ **Database Setup** (Optional): If using database storage (UseDatabase = true), import the `flagpole.sql` file into your database to create the required table, or the script will auto-create it on first start.
4. 🔧 Configure the script by updating the `Config` table to match your server setup.  
5. 🛠️ **Add Items**: Insert the required items into `qb-core/shared/items.lua`. Framework

## 📖 Introduction
This **Flagpole Script** lets players interact with flagpoles and flags in your QBCore-based FiveM server. Players can place, customize, and manage flagpoles with dynamic controls and persistent data stored in a MySQL database. 🏴

---

## 🌟 Features
✨ **Place Flagpoles**: Players can place flagpoles in the game world.  
🎏 **Attach Flags**: Choose from a variety of flags in your inventory.  
⬆️ **Raise and Lower Flags**: Use keys to dynamically adjust flag height.  
🗺️ **Blip Customization**: Rename and adjust the map blip for your flagpole.  
💾 **Database Persistence**: Automatically saves flagpole and flag data to MySQL database or JSON file (configurable).

---

## 🛠️ Requirements
- **Framework**: QBCore Framework.  
- **Targeting System**: Compatible with `qb-target`
- **Database** (Optional): MySQL with oxmysql (only if UseDatabase = true)
- **Dependencies**: 
  - `@oxmysql/lib/MySQL.lua` (only if using database)
  - `@ox_lib/init.lua`

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
    UseDatabase = true, -- 💾 Set to true to use MySQL database, false to use JSON file storage
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

## 💾 Storage Options

The script supports two storage methods that can be configured via the `UseDatabase` setting:

### 🗄️ **Database Storage (UseDatabase = true)**
- **Pros**: Better performance, scalability, data integrity, multi-server support
- **Cons**: Requires MySQL database setup
- **Requirements**: MySQL database with oxmysql resource
- **Auto-saves**: Data is saved immediately to database

### 📄 **JSON File Storage (UseDatabase = false)**  
- **Pros**: Simple setup, no database required, easy to backup
- **Cons**: Less performant for large amounts of data, single-server only
- **Requirements**: None (uses local file system)
- **Auto-saves**: Data is saved every 5 minutes automatically

**Recommendation**: Use database storage for production servers, JSON for development/testing.

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