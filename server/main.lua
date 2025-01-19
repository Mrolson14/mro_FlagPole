---@diagnostic disable: undefined-global
local QBCore = exports['qb-core']:GetCoreObject()
local json = require("json")
local saveFilePath = "C:/zombie-server/txData/QBCoreFramework_15B72A.base/resources/[zombies]/FlagPole/flagpole_data.json"
local savedData = {}

function DebugLog(message, level)
    local Config = { Debug = true }
    if not Config.Debug or not message then return end

    local log_level = level or "INFO"
    local log_colors = {
        ERROR = "^1",
        WARNING = "^3",
        SUCCESS = "^2",
        INFO = "^4"
    }

    local color = log_colors[log_level] or "^7"
    local formattedMessage = string.format("%s[Server - %s] %s^7", color, log_level, message)
    print(formattedMessage)
end

CreateThread(function()
    while true do
        Wait(60000 * 5) 
        SaveData()
        DebugLog("Periodic auto-save completed.", "INFO")
    end
end)

function LoadSavedData()
    local file = io.open(saveFilePath, "r")
    if file then
        local content = file:read("*a")
        savedData = json.decode(content) or {}
        file:close()
        DebugLog("Flagpole data loaded successfully.", "SUCCESS")
    else
        savedData = {}
        DebugLog("No existing flagpole data found. Starting fresh.", "WARNING")
    end
end

function SaveData()
    for _, data in ipairs(savedData) do
        if data.flag and data.flag.item then
            for flagName, flagConfig in pairs(Config.Flags) do
                if flagConfig.item == data.flag.item then
                    data.flag.model = flagConfig.prop
                    break
                end
            end
        end

        if data.blip and data.blip.name then
            for _, blacklistedName in ipairs(Config.Blacklistedname) do
                if data.blip.name:lower() == blacklistedName:lower() then
                    data.blip.name = "Invalid Name" 
                    DebugLog("Blacklisted name detected. Replacing with default.", "WARNING")
                    break
                end
            end
        end

        data.model = data.model or Config.FlagpoleModel
    end

    local file, err = io.open(saveFilePath, "w+")
    if file then
        file:write(json.encode(savedData, { indent = true }))
        file:close()
        DebugLog("Flagpole data saved to file successfully.", "SUCCESS")
    else
        DebugLog("Error saving flagpole data: " .. tostring(err), "ERROR")
    end
end

RegisterNetEvent("flagpole_placement:server:SaveFlagpole", function(poleData)
    DebugLog("Saving flagpole data: " .. json.encode(poleData), "INFO")

    if not poleData.id then
        poleData.id = #savedData + 1
    end

    if poleData.flag and type(poleData.flag.model) == "number" then
        poleData.flag.model = string.format("prop_%x", poleData.flag.model)
    end

    local found = false
    for i, existingPole in ipairs(savedData) do
        if existingPole.id == poleData.id then
            savedData[i] = poleData
            found = true
            break
        end
    end

    if not found then
        table.insert(savedData, poleData)
    end

    SaveData()
    DebugLog("Flagpole data saved successfully: " .. json.encode(poleData), "SUCCESS")
end)

RegisterNetEvent("flagpole_placement:server:RemoveSavedFlagpole", function(poleId)
    for i, pole in ipairs(savedData) do
        if pole.id == poleId then
            table.remove(savedData, i)
            SaveData()
            DebugLog("Flagpole with ID " .. poleId .. " removed from saved data.", "SUCCESS")
            return
        end
    end
    DebugLog("No flagpole found with ID " .. poleId .. " to remove.", "WARNING")
end)

RegisterNetEvent("flagpole_placement:server:GetPoles", function()
    local src = source
    TriggerClientEvent("flagpole_placement:client:LoadPoles", src, savedData or {})
    DebugLog("Flagpole data sent to client.", "INFO")
end)

QBCore.Functions.CreateUseableItem(Config.FlagpoleItem, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    --print("test")
    if Player then
        DebugLog("Player " .. Player.PlayerData.citizenid .. " is attempting to use " .. Config.FlagpoleItem, "INFO")
        -- local meg = exports["qb-inventory"]:RemoveItem(source,Config.FlagpoleItem, 1)
        -- print ("test1", tostring(meg))
        -- if meg then
            -- DebugLog(Config.FlagpoleItem .. " item removed from player " .. Player.PlayerData.citizenid, "SUCCESS")
            TriggerClientEvent("flagpole_placement:client:PlaceFlagpole", source)
            -- TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items[Config.FlagpoleItem], "remove")
        -- else
        --     DebugLog("Player " .. Player.PlayerData.citizenid .. " does not have " .. Config.FlagpoleItem, "WARNING")
        --     TriggerClientEvent("QBCore:Notify", source, "You don’t have a " .. Config.FlagpoleItem .. " item!", "error")
        -- end
    else
        DebugLog("Player not found during " .. Config.FlagpoleItem .. " use attempt.", "ERROR")
    end
end)

QBCore.Functions.CreateCallback('smurf-flagpole:cb:RemoveItem', function (source, cb, flagpole, countProbably)    
    local meg = exports["qb-inventory"]:RemoveItem(source,Config.FlagpoleItem, 1)
    local Player = QBCore.Functions.GetPlayer(source)
    --print ("test1", tostring(meg))
    if meg then
        DebugLog(Config.FlagpoleItem .. " item removed from player " .. Player.PlayerData.citizenid, "SUCCESS")
        TriggerClientEvent("flagpole_placement:client:PlaceFlagpole", source)
        return cb(true)
        -- TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items[Config.FlagpoleItem], "remove") -- not sure why this is here
    end
    DebugLog("Player " .. Player.PlayerData.citizenid .. " does not have " .. Config.FlagpoleItem, "WARNING")
    --TriggerClientEvent("QBCore:Notify", source, "You don’t have a " .. Config.FlagpoleItem .. " item!", "error")
    return false -- not technically needed    
end)

RegisterNetEvent("flagpole_placement:server:RemoveFlagItem", function(flagItem)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hasItem

    if Player then
        DebugLog("Player " .. Player.PlayerData.citizenid .. " is attempting to remove flag item: " .. flagItem, "INFO")
        if Player.Functions.RemoveItem(flagItem, 1) then
            DebugLog("Flag item (" .. flagItem .. ") removed from player " .. Player.PlayerData.citizenid, "SUCCESS")
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[flagItem], "remove")
            TriggerClientEvent("QBCore:Notify", src, "Flag item successfully removed from your inventory!", "success")
        else
            DebugLog("Player " .. Player.PlayerData.citizenid .. " does not have the flag item: " .. flagItem, "WARNING")
            TriggerClientEvent("QBCore:Notify", src, "You don't have the required flag item!", "error")
        end
    else
        DebugLog("Player not found during flag removal attempt.", "ERROR")
    end
end)

RegisterNetEvent("flagpole_placement:server:RemoveFlagpole", function(coords)
    local src = source
    local found = false

    for i, pole in ipairs(savedData) do
        if math.abs(pole.coords.x - coords.x) < 0.1 and
           math.abs(pole.coords.y - coords.y) < 0.1 and
           math.abs(pole.coords.z - coords.z) < 0.1 then
            table.remove(savedData, i)
            found = true
            DebugLog("Flagpole removed from saved data: " .. json.encode(coords), "SUCCESS")
            break
        end
    end

    if not found then
        DebugLog("No matching flagpole found to remove.", "WARNING")
    end

    SaveData()
end)

RegisterNetEvent("flagpole_placement:server:ReturnFlagItem", function(flagItem)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        DebugLog("Player " .. Player.PlayerData.citizenid .. " is attempting to return flag item: " .. flagItem, "INFO")

        if Player.Functions.AddItem(flagItem, 1) then
            DebugLog("Flag item (" .. flagItem .. ") returned to player " .. Player.PlayerData.citizenid, "SUCCESS")
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[flagItem], "add")
            TriggerClientEvent("QBCore:Notify", src, "You have received your flag back!", "success")
        else
            DebugLog("Failed to return the " .. flagItem .. " item to player " .. Player.PlayerData.citizenid, "ERROR")
            TriggerClientEvent("QBCore:Notify", src, "Failed to return the flag to your inventory. Please check your inventory space!", "error")
        end
    else
        DebugLog("Player not found during flag return attempt.", "ERROR")
    end
end)

RegisterNetEvent("flagpole_placement:server:GiveFlagpoleItem", function(flagItem)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local flagpoleItem = Config.FlagpoleItem
        local returnedItems = {}

        if Player.Functions.AddItem(flagpoleItem, 1) then
            table.insert(returnedItems, flagpoleItem)
            DebugLog(flagpoleItem .. " item returned to player " .. Player.PlayerData.citizenid, "SUCCESS")
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[flagpoleItem], "add")
        else
            DebugLog("Failed to return the " .. flagpoleItem .. " item to player " .. Player.PlayerData.citizenid, "ERROR")
            TriggerClientEvent("QBCore:Notify", src, "Failed to return the " .. flagpoleItem .. " to your inventory. Please check your inventory space!", "error")
        end

        if flagItem then
            if Player.Functions.AddItem(flagItem, 1) then
                table.insert(returnedItems, flagItem)
                DebugLog(flagItem .. " item returned to player " .. Player.PlayerData.citizenid, "SUCCESS")
                TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[flagItem], "add")
            else
                DebugLog("Failed to return the " .. flagItem .. " item to player " .. Player.PlayerData.citizenid, "ERROR")
                TriggerClientEvent("QBCore:Notify", src, "Failed to return the " .. flagItem .. " to your inventory. Please check your inventory space!", "error")
            end
        end

        if #returnedItems > 0 then
            local itemNames = table.concat(returnedItems, ", ")
            TriggerClientEvent("QBCore:Notify", src, "You have received your items: " .. itemNames, "success")
        else
            DebugLog("No items were successfully returned to player " .. Player.PlayerData.citizenid, "WARNING")
        end
    else
        DebugLog("Player not found when attempting to return items.", "ERROR")
    end
end)

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        LoadSavedData()
    end
end)

exports("SaveFlagpole", function(poleData)
    TriggerEvent("flagpole_placement:server:SaveFlagpole", poleData)
end)

exports("RemoveSavedFlagpole", function(poleId)
    TriggerEvent("flagpole_placement:server:RemoveSavedFlagpole", poleId)
end)

exports("GetSavedPoles", function()
    return savedData
end)

exports("GiveFlagpoleItem", function(source, flagItem)
    TriggerEvent("flagpole_placement:server:GiveFlagpoleItem", flagItem)
end)

exports("ReturnFlagItem", function(source, flagItem)
    TriggerEvent("flagpole_placement:server:ReturnFlagItem", flagItem)
end)


