-- Check if player has job before spawning vehicle
RegisterNetEvent('qbx-jobname:server:SpawnVehicle', function(model, coords)
    local src = source
    print('Event triggered by:', src)
    print('Model:', model)
    print('Coords:', coords.x, coords.y, coords.z, coords.w)
    
    if QBX.PlayerData.job.name ~= 'tabac' then 
        TriggerClientEvent('QBX:Notify', src, 'You are not authorized to use this!', 'error')
        return 
    end

    local netId, veh = exports.qbx:SpawnVehicle({
        model = model,
        spawnSource = coords,
        warp = GetPlayerPed(src)
    })

    if netId and veh then
        print('Vehicle spawned with netId:', netId)
        local plate = 'TABAC' .. math.random(1000, 9999)
        SetVehicleNumberPlateText(veh, plate)
        
        -- Give keys to the player
        exports.qbx_vehiclekeys:GiveKeys(src, veh)
        
        TriggerClientEvent('qbx-jobname:client:SpawnVehicle', src, netId)
    else
        print('Failed to spawn vehicle')
    end
end)

-- Log vehicle returns (optional)
RegisterNetEvent('qbx-jobname:server:ReturnVehicle', function()
    local src = source
    
    if QBX.PlayerData.job.name ~= 'tabac' then return end
    
    print("Vehicle returned by player ID: " .. src)
end)

local function SpawnVehicle(source, model, coords)
    local src = source
    local Player = exports.qbx:GetPlayer(src)
    
    if QBX.PlayerData.job.name == 'tabac' then return end

    local netId, veh = exports.qbx:SpawnVehicle({
        model = model,
        spawnSource = coords,
        warp = GetPlayerPed(source)
    })

    local plate = Config.JobName:upper() .. math.random(1000, 9999)
    SetVehicleNumberPlateText(veh, plate)
    TriggerClientEvent('vehiclekeys:client:SetOwner', source, plate)
    return netId
end

exports('SpawnVehicle', SpawnVehicle) 