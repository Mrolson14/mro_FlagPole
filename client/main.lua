---@diagnostic disable: undefined-global, need-check-nil, undefined-field
local QBCore = exports['qb-core']:GetCoreObject()
local placedFlagpole = nil
local attachedFlag = nil
local flagHeight = Config.FlagHeightMin
local attached = false
local flagBlip = nil 
local hasPlacedFlagpole = false 
local createdProps = {}

function DebugLog(message, level)
    if not Config.Debug or not message then return end

    local log_level = level or "INFO"
    local log_colors = {
        ERROR = "^1",
        WARNING = "^3",
        SUCCESS = "^2",
        INFO = "^4"
    }

    local color = log_colors[log_level] or "^7"
    local formattedMessage = string.format("%s[Client - %s] %s^7", color, log_level, message)
    print(formattedMessage)
end

function PlayAnimation(animDict, animName, duration)
    local playerPed = PlayerPedId()
    RequestAnimDict(animDict)

    while not HasAnimDictLoaded(animDict) do
        Wait(100)
    end

    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, duration, 1, 0, false, false, false)
    Wait(duration)
    ClearPedTasks(playerPed)
end

function AttachFlag()
    if attachedFlag then
        QBCore.Functions.Notify("A flag is already attached!", "error")
        DebugLog("Player attempted to attach another flag, but one is already attached.", "WARNING")
        return
    end

    local availableFlags = {}
    for flagKey, flagData in pairs(Config.Flags) do
        if QBCore.Functions.HasItem(flagData.item) then
            table.insert(availableFlags, {
                label = flagKey,
                model = flagData.prop,
                item = flagData.item
            })
        end
    end

    if #availableFlags == 0 then
        QBCore.Functions.Notify("You don't have any flags to attach!", "error")
        DebugLog("Player attempted to attach a flag but has none.", "WARNING")
        return
    end

    local menuOptions = {}
    for _, flag in ipairs(availableFlags) do
        table.insert(menuOptions, {
            title = flag.label,
            description = "Attach this flag to the pole",
            event = "flagpole_placement:client:SelectFlag",
            args = {
                model = flag.model,
                item = flag.item
            }
        })
    end

    lib.registerContext({
        id = 'flag_menu',
        title = 'Available Flags',
        options = menuOptions
    })

    lib.showContext('flag_menu')
end

function ShowFlagControls()
    QBCore.Functions.Notify("Use [E] to raise the flag and [Q] to lower it.", "info")
    DebugLog("Flag controls displayed to the user.", "INFO")
end

function ControlFlag()
    CreateThread(function()
        local isWithinDistance = false 
        local blipAdded = false 
        local proximityNotified = false 
        local blipName, blipIcon, blipColor = "Flag at Full Mast", 1, 3

        while attached and DoesEntityExist(placedFlagpole) and DoesEntityExist(attachedFlag.entity) do
            Wait(50) 

            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local flagpoleCoords = GetEntityCoords(placedFlagpole)
            local distance = #(playerCoords - flagpoleCoords)

            if distance <= Config.PlacementDistance then
                if not isWithinDistance then
                    isWithinDistance = true 
                    if not proximityNotified then
                        QBCore.Functions.Notify("You are close enough to control the flag.", "info")
                        proximityNotified = true
                    end
                    DebugLog("Player is within range to use controls.", "INFO")
                end

                if IsControlPressed(0, Config.ControlKeys.RaiseFlag) then
                    if flagHeight < Config.FlagHeightMax then
                        flagHeight = flagHeight + Config.FlagRaiseSpeed
                        AttachEntityToEntity(
                            attachedFlag.entity, 
                            placedFlagpole,
                            0,
                            0.0,
                            0.0,
                            flagHeight,
                            0.0,
                            0.0,
                            0.0,
                            false,
                            false,
                            true,
                            false,
                            0,
                            true
                        )
                        table.insert(createdProps, attachedFlag.entity)
                        Wait(100) 
                        DebugLog("Flag raised to height: " .. flagHeight, "INFO")
                    else
                        if not blipAdded then
                            QBCore.Functions.Notify("Flag is already at the top!", "success")
                            DebugLog("Flag reached the top.", "INFO")
                            CustomizeBlip(blipName, blipIcon, blipColor, function(name, icon, color)
                                if name then
                                    blipName, blipIcon, blipColor = name, icon, color
                                    AddFlagBlip(flagpoleCoords, blipName, blipIcon, blipColor)
                                    blipAdded = true
                                end
                            end)
                        end
                        Wait(500)
                    end
                end

                if IsControlPressed(0, Config.ControlKeys.LowerFlag) then
                    if flagHeight > Config.FlagHeightMin then
                        flagHeight = flagHeight - Config.FlagRaiseSpeed
                        AttachEntityToEntity(
                            attachedFlag.entity, 
                            placedFlagpole,
                            0,
                            0.0,
                            0.0,
                            flagHeight,
                            0.0,
                            0.0,
                            0.0,
                            false,
                            false,
                            true,
                            false,
                            0,
                            true
                        )
                        Wait(100)
                        DebugLog("Flag lowered to height: " .. flagHeight, "INFO")
                        if blipAdded then
                            RemoveFlagBlip()
                            blipAdded = false
                        end
                    else
                        QBCore.Functions.Notify("Flag is already at the bottom!", "error")
                        DebugLog("Attempted to lower the flag below the minimum height.", "WARNING")
                        Wait(500)
                    end
                end
            else
                if isWithinDistance then
                    isWithinDistance = false
                    proximityNotified = false 
                    DebugLog("Player moved out of range for flag controls.", "INFO")
                end
            end
        end

        if blipAdded then
            RemoveFlagBlip()
        end
        DebugLog("ControlFlag thread ended.", "INFO")
    end)
end

function RemoveFlag()
    if not attachedFlag then
        QBCore.Functions.Notify("There is no flag to remove!", "error")
        DebugLog("Attempted to remove a flag, but no flag was attached.", "WARNING")
        return
    end

    if flagHeight > Config.FlagHeightMin + 0.1 then
        QBCore.Functions.Notify("Lower the flag completely before removing it.", "error")
        DebugLog("Attempted to remove the flag, but it was not low enough.", "WARNING")
        return
    end

    PlayAnimation("anim@mp_snowball", "pickup_snowball", 1500)

    TriggerServerEvent("flagpole_placement:server:ReturnFlagItem", attachedFlag.item)

    DeleteEntity(attachedFlag.entity)
    attachedFlag = nil
    attached = false

    QBCore.Functions.Notify("Flag removed successfully!", "success")
    DebugLog("Flag removed successfully.", "SUCCESS")
end

function RemoveFlagpole()
    if not placedFlagpole then
        QBCore.Functions.Notify("No flagpole to remove!", "error")
        DebugLog("Attempted to remove a flagpole, but none was placed.", "WARNING")
        return
    end

    if attachedFlag then
        TriggerServerEvent("flagpole_placement:server:GiveFlagpoleItem", attachedFlag.item)
        DeleteEntity(attachedFlag.entity)
        attachedFlag = nil
    else
        TriggerServerEvent("flagpole_placement:server:GiveFlagpoleItem", nil)
    end

    PlayAnimation("anim@heists@narcotics@trash", "drop_front", 2000)

    local coords = GetEntityCoords(placedFlagpole)
    TriggerServerEvent("flagpole_placement:server:RemoveFlagpole", coords)

    DeleteEntity(placedFlagpole)
    placedFlagpole = nil
    attached = false
    hasPlacedFlagpole = false 

    QBCore.Functions.Notify("Flagpole removed successfully!", "success")
    DebugLog("Flagpole removed successfully.", "SUCCESS")
end

function ShowFlagpoleMenu()
    local options = {
        {
            title = "Attach Flag",
            description = "Attach a flag to the pole.",
            event = "flagpole_placement:client:AttachFlag",
            args = {}
        },
        {
            title = "Remove Flag",
            description = "Remove the flag from the pole.",
            event = "flagpole_placement:client:RemoveFlag",
            args = {},
            disabled = not attached
        },
        {
            title = "Rename Blip",
            description = "Rename the flag's blip.",
            event = "flagpole_placement:client:RenameBlip",
            args = {},
            disabled = not flagBlip
        },
        {
            title = "Remove Flagpole",
            description = "Remove the flagpole.",
            event = "flagpole_placement:client:RemoveFlagpole",
            args = {},
            disabled = attached
        }
    }

    lib.registerContext({
        id = 'flagpole_menu',
        title = 'Flagpole Options',
        options = options
    })

    lib.showContext('flagpole_menu')
end

function PromptForBlipName(defaultName, callback)
    local input = lib.inputDialog("Blip Name", {
        { type = "input", label = "Enter the name for the blip", default = defaultName, required = true }
    })

    if input and input[1] then
        callback(input[1]) 
    else
        callback(nil)
    end
end

function CustomizeBlip(defaultName, defaultIcon, defaultColor, callback)
    local input = lib.inputDialog("Customize Blip", {
        { type = "input", label = "Blip Name", default = defaultName, required = true },
        { type = "number", label = "Blip Icon (default: 1)", default = defaultIcon or 1, required = true },
        { type = "number", label = "Blip Color (default: 3)", default = defaultColor or 3, required = true },
        {
            type = "slider",
            label = "Blip Size",
            min = 0.3,
            max = 1.0,
            step = 0.1,
            default = 0.7
        }
    })

    if input and input[1] then
        local blipName = input[1]:lower()
        local blipIcon = tonumber(input[2]) or 1
        local blipColor = tonumber(input[3]) or 3
        local blipSize = tonumber(input[4]) or 0.7

        for _, blacklisted in ipairs(Config.Blacklistedname) do
            if blipName == blacklisted:lower() then
                QBCore.Functions.Notify("This name is blacklisted! Please choose another name.", "error")
                DebugLog("Attempted to use a blacklisted name: " .. blipName, "WARNING")
                callback(nil, nil, nil, nil)
                return
            end
        end

        local poleCoords = GetEntityCoords(placedFlagpole)
        local flagData = attachedFlag and {
            model = GetEntityModel(attachedFlag.entity),
            item = attachedFlag.item,
            height = flagHeight
        } or nil

        TriggerServerEvent("flagpole_placement:server:SaveFlagpole", {
            coords = poleCoords,
            blip = { name = blipName, icon = blipIcon, color = blipColor, size = blipSize },
            flag = flagData
        })

        callback(blipName, blipIcon, blipColor, blipSize)
    else
        callback(nil, nil, nil, nil)
    end
end

function AddFlagBlip(coords, name, icon, color)
    if flagBlip then
        RemoveBlip(flagBlip)
    end

    flagBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(flagBlip, icon or 1)
    SetBlipDisplay(flagBlip, 4)
    SetBlipScale(flagBlip, 0.7)
    SetBlipColour(flagBlip, color or 3)
    SetBlipAsShortRange(flagBlip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name or Confing.Flags)
    EndTextCommandSetBlipName(flagBlip)
end

function RemoveFlagBlip()
    if flagBlip then
        RemoveBlip(flagBlip)
        flagBlip = nil
    end
end

RegisterNetEvent("flagpole_placement:client:PlaceFlagpole", function()
    if hasPlacedFlagpole then
        QBCore.Functions.Notify("You can only place one flagpole at a time!", "error")
        DebugLog("Player attempted to place another flagpole but already has one.", "WARNING")
        return 
    end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    -- if not QBCore.Functions.HasItem(Config.FlagpoleItem) then
    --     QBCore.Functions.Notify("You don't have the required item to place a flagpole!", "error")
    --     DebugLog("Player tried to place a flagpole without the required item.", "WARNING")
    --     return
    -- end

    QBCore.Functions.TriggerCallback('smurf-flagpole:cb:RemoveItem', function(success)
        if success then
            PlayAnimation("anim@heists@money_grab@briefcase", "put_down_case", 2000)

            placedFlagpole = CreateObject(GetHashKey(Config.FlagpoleModel), coords.x, coords.y + 0.5, coords.z, true, true, true)
            PlaceObjectOnGroundProperly(placedFlagpole)
            SetEntityAsMissionEntity(placedFlagpole, true, true)
            FreezeEntityPosition(placedFlagpole, true)

            table.insert(createdProps, placedFlagpole)

            hasPlacedFlagpole = true 

            exports[Config.Target]:AddTargetEntity(placedFlagpole, {
                options = {
                    {
                        label = "Attach Flag",
                        action = function()
                            AttachFlag()
                        end,
                        icon = "fas fa-flag",
                        canInteract = function()
                            return not attached
                        end
                    },
                    {
                        label = "Remove Flag",
                        action = function()
                            TriggerEvent("flagpole_placement:client:RemoveFlag")
                        end,
                        icon = "fas fa-times",
                        canInteract = function()
                            return attached
                        end
                    },
                    {
                        label = "Remove Flagpole",
                        action = function()
                            RemoveFlagpole()
                        end,
                        icon = "fas fa-box",
                        canInteract = function()
                            return not attached
                        end
                    },
                },
                distance = Config.PlacementDistance
            })

            QBCore.Functions.Notify("Flagpole placed successfully!", "success")
            DebugLog("Flagpole placed at coordinates: " .. coords, "INFO")
        else
            QBCore.Functions.Notify("Failed to place the flagpole. Please try again!", "error")
            DebugLog("Failed to remove flagpole item from inventory.", "ERROR")
        end
    end, Config.FlagpoleItem, 1) 
end)

RegisterNetEvent("flagpole_placement:client:OpenMenu", function()
    ShowFlagpoleMenu()
end)

RegisterNetEvent("flagpole_placement:client:SelectFlag", function(data)
    local flagModel = data.model
    local flagItem = data.item

    RequestModel(flagModel)
    while not HasModelLoaded(flagModel) do
        Wait(500)
    end

    attachedFlag = {
        entity = CreateObject(flagModel, 0, 0, 0, true, true, true),
        item = flagItem
    }

    AttachEntityToEntity(
        attachedFlag.entity, 
        placedFlagpole, 
        0, 
        0.0, 
        0.0, 
        Config.FlagHeightMin, 
        0.0, 
        0.0, 
        0.0, 
        false, 
        false, 
        true, 
        false, 
        0, 
        true
    )

    TriggerServerEvent("flagpole_placement:server:RemoveFlagItem", flagItem)

    SetModelAsNoLongerNeeded(flagModel)

    attached = true
    flagHeight = Config.FlagHeightMin

    QBCore.Functions.Notify("Flag attached to the flagpole!", "success")
    DebugLog("Flag (" .. flagItem .. ") attached to the flagpole at the bottom.", "SUCCESS")
    ShowFlagControls()
    ControlFlag()
end)

RegisterNetEvent("flagpole_placement:client:RemoveFlag", RemoveFlag)
RegisterNetEvent("flagpole_placement:client:RenameBlip", function()
    if flagBlip then
        CustomizeBlip(blipName, blipIcon, blipColor, function(name, icon, color)
            if name then
                blipName, blipIcon, blipColor = name, icon, color
                AddFlagBlip(GetEntityCoords(placedFlagpole), blipName, blipIcon, blipColor)
            end
        end)
    else
        QBCore.Functions.Notify("No blip to rename!", "error")
    end
end)

RegisterNetEvent("flagpole_placement:client:LoadPoles", function(savedPoles)
    for _, pole in ipairs(savedPoles) do
        if pole.flag and type(pole.flag.model) == "string" then
            pole.flag.model = GetHashKey(pole.flag.model)
        end

        local poleHash = GetHashKey(pole.model)
        RequestModel(poleHash)
        while not HasModelLoaded(poleHash) do
            Wait(100)
        end

        local flagpole = CreateObject(poleHash, pole.coords.x, pole.coords.y, pole.coords.z, true, true, true)
        PlaceObjectOnGroundProperly(flagpole)
        FreezeEntityPosition(flagpole, true)
        table.insert(createdProps, flagpole)

        if pole.flag then
            local flagHash = pole.flag.model
            RequestModel(flagHash)
            while not HasModelLoaded(flagHash) do
                Wait(100)
            end

            local flag = CreateObject(flagHash, 0, 0, 0, true, true, true)
            AttachEntityToEntity(
                flag,
                flagpole,
                0,
                0.0,
                0.0,
                pole.flag.height or Config.FlagHeightMin,
                0.0,
                0.0,
                0.0,
                false,
                false,
                true,
                false,
                0,
                true
            )
            table.insert(createdProps, flag)
            SetModelAsNoLongerNeeded(flagHash)

            attachedFlag = {
                entity = flag,
                item = pole.flag.item
            }
            flagHeight = pole.flag.height or Config.FlagHeightMin
            attached = true
            placedFlagpole = flagpole 

            ControlFlag()
        end

        exports[Config.Target]:AddTargetEntity(flagpole, {
            options = {
                {
                    label = "Attach Flag",
                    action = function()
                        AttachFlag()
                    end,
                    icon = "fas fa-flag",
                    canInteract = function()
                        return not attached
                    end
                },
                {
                    label = "Remove Flag",
                    action = function()
                        RemoveFlag()
                    end,
                    icon = "fas fa-times",
                    canInteract = function()
                        return attached
                    end
                },
                {
                    label = "Remove Flagpole",
                    action = function()
                        RemoveFlagpole()
                    end,
                    icon = "fas fa-box",
                    canInteract = function()
                        return not attached
                    end
                },
            },
            distance = Config.PlacementDistance
        })

        DebugLog("Flagpole and interactions set up for pole ID: " .. (pole.id or "unknown"), "INFO")
    end

    DebugLog("Flagpoles and flags loaded successfully.", "SUCCESS")
end)


AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        savedData = savedData or {}

        for _, pole in ipairs(savedData) do
            if pole.flag then
                local flagModel = GetHashKey(pole.flag.model)
                local flagCoords = vector3(pole.coords.x, pole.coords.y, pole.coords.z + pole.flag.height)
                local flagEntity = GetClosestObjectOfType(flagCoords.x, flagCoords.y, flagCoords.z, 1.0, flagModel, false, false, false)
                if DoesEntityExist(flagEntity) then
                    DeleteEntity(flagEntity)
                end
            end

            local flagpoleModel = GetHashKey(Config.FlagpoleModel)
            local flagpoleCoords = vector3(pole.coords.x, pole.coords.y, pole.coords.z)
            local flagpoleEntity = GetClosestObjectOfType(flagpoleCoords.x, flagpoleCoords.y, flagpoleCoords.z, 1.0, flagpoleModel, false, false, false)
            if DoesEntityExist(flagpoleEntity) then
                DeleteEntity(flagpoleEntity)
            end
        end

        DebugLog("All flagpoles and flags removed on resource stop.", "SUCCESS")
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        local polesToSave = {}

        if placedFlagpole then
            local coords = GetEntityCoords(placedFlagpole)
            local flagData = attachedFlag and {
                model = GetEntityModel(attachedFlag.entity),
                item = attachedFlag.item,
                height = flagHeight
            } or nil
            table.insert(polesToSave, { coords = coords, flag = flagData })
        end

        TriggerServerEvent("flagpole_placement:server:SavePoles", polesToSave)
        DebugLog("Flagpoles and flags saved on resource stop.", "SUCCESS")
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        for _, prop in ipairs(createdProps) do
            if DoesEntityExist(prop) then
                DeleteEntity(prop)
            end
        end
        createdProps = {} 
        DebugLog("All props removed on resource stop.", "SUCCESS")
    end
end)

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        TriggerServerEvent("flagpole_placement:server:GetPoles")
    end
end)


exports("PlaceFlagpole", function(coords)
    local playerPed = PlayerPedId()
    PlayAnimation("anim@heists@money_grab@briefcase", "put_down_case", 2000)

    placedFlagpole = CreateObject(GetHashKey(Config.FlagpoleModel), coords.x, coords.y, coords.z, true, true, true)
    PlaceObjectOnGroundProperly(placedFlagpole)
    SetEntityAsMissionEntity(placedFlagpole, true, true)
    FreezeEntityPosition(placedFlagpole, true)
    table.insert(createdProps, placedFlagpole)
    DebugLog("Flagpole placed at coordinates: " .. json.encode(coords), "INFO")
end)

exports("AttachFlag", function()
    AttachFlag()
end)

exports("RemoveFlag", function()
    RemoveFlag()
end)

exports("RemoveFlagpole", function()
    RemoveFlagpole()
end)

exports("ControlFlag", function()
    ControlFlag()
end)

exports("GetFlagData", function()
    return {
        flagHeight = flagHeight,
        flagAttached = attached,
        flagModel = attachedFlag and attachedFlag.model or nil
    }
end)


