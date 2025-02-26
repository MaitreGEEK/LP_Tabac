-- Create job blip
local function CreateJobBlip()
    -- Main job blip
    local blip = AddBlipForCoord(Config.Blip.coords)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipDisplay(blip, Config.Blip.display)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blip.name)
    EndTextCommandSetBlipName(blip)

    -- Vehicle spawn point blip
    local spawnBlip = AddBlipForCoord(Config.VehicleSpawnPoint.coords.x, Config.VehicleSpawnPoint.coords.y, Config.VehicleSpawnPoint.coords.z)
    SetBlipSprite(spawnBlip, 225) -- Car sprite
    SetBlipDisplay(spawnBlip, 4)
    SetBlipScale(spawnBlip, 0.6)
    SetBlipColour(spawnBlip, 3) -- Blue
    SetBlipAsShortRange(spawnBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Vehicle Spawn")
    EndTextCommandSetBlipName(spawnBlip)
end

-- Ensure blips are created when resource starts
CreateThread(function()
    CreateJobBlip()
end)

-- Vehicle spawn configuration
local vehicleSpawnPoint = {
    coords = vector4(-1234.56, -1234.56, 12.34, 90.0), -- Replace with your coordinates (x, y, z, heading)
    marker = {
        type = 36,
        size = vector3(1.5, 1.5, 1.5),
        color = vector4(0, 150, 255, 155),
        distance = 7.0
    }
}

-- Vehicle return point
local vehicleReturnPoint = {
    coords = vector3(-1234.56, -1234.56, 12.34), -- Replace with your coordinates
    marker = {
        type = 1,
        size = vector3(3.0, 3.0, 1.0),
        color = vector4(255, 0, 0, 155),
        distance = 7.0
    }
}

-- Draw markers and handle interactions
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        -- Spawn point marker
        local distanceToSpawn = #(playerCoords - vector3(Config.VehicleSpawnPoint.coords.x, Config.VehicleSpawnPoint.coords.y, Config.VehicleSpawnPoint.coords.z))
        if distanceToSpawn < Config.VehicleSpawnPoint.marker.distance then
            sleep = 0
            DrawMarker(
                Config.VehicleSpawnPoint.marker.type,
                Config.VehicleSpawnPoint.coords.x, 
                Config.VehicleSpawnPoint.coords.y, 
                Config.VehicleSpawnPoint.coords.z,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                Config.VehicleSpawnPoint.marker.size.x, 
                Config.VehicleSpawnPoint.marker.size.y, 
                Config.VehicleSpawnPoint.marker.size.z,
                Config.VehicleSpawnPoint.marker.color.r, 
                Config.VehicleSpawnPoint.marker.color.g, 
                Config.VehicleSpawnPoint.marker.color.b, 
                Config.VehicleSpawnPoint.marker.color.a,
                false, false, 2, false, nil, nil, false
            )
            
            if distanceToSpawn < 2.0 then
                DrawText3D(Config.VehicleSpawnPoint.coords.x, Config.VehicleSpawnPoint.coords.y, Config.VehicleSpawnPoint.coords.z + 1.0, "~g~[E]~w~ Véhicule")
                if IsControlJustPressed(0, 38) then -- E key
                    ExecuteCommand('spawnvehicle')
                end
            end
        end
        
        -- Return point marker
        local distanceToReturn = #(playerCoords - Config.VehicleReturnPoint.coords)
        if distanceToReturn < Config.VehicleReturnPoint.marker.distance then
            sleep = 0
            DrawMarker(
                Config.VehicleReturnPoint.marker.type,
                Config.VehicleReturnPoint.coords.x, 
                Config.VehicleReturnPoint.coords.y, 
                Config.VehicleReturnPoint.coords.z,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                Config.VehicleReturnPoint.marker.size.x, 
                Config.VehicleReturnPoint.marker.size.y, 
                Config.VehicleReturnPoint.marker.size.z,
                Config.VehicleReturnPoint.marker.color.r, 
                Config.VehicleReturnPoint.marker.color.g, 
                Config.VehicleReturnPoint.marker.color.b, 
                Config.VehicleReturnPoint.marker.color.a,
                false, false, 2, false, nil, nil, false
            )
            
            if distanceToReturn < 2.0 and IsPedInAnyVehicle(playerPed, false) then
                DrawText3D(Config.VehicleReturnPoint.coords.x, Config.VehicleReturnPoint.coords.y, Config.VehicleReturnPoint.coords.z + 1.0, "Press ~r~[E]~w~ to return vehicle")
                if IsControlJustPressed(0, 38) then -- E key
                    ReturnJobVehicle()
                end
            end
        end
        Wait(sleep)
    end
end)

-- Function to spawn job vehicle
RegisterNetEvent('qbx-jobname:client:spawnVehicle', function(netId)
    if netId then
        lib.notify({
            title = 'Success',
            description = 'Vehicle spawned!',
            type = 'success'
        })
    end
end)

-- Function to return job vehicle
function ReturnJobVehicle()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if vehicle then
        DeleteEntity(vehicle)
        -- Optional: Add notification
        -- TriggerEvent('QBCore:Notify', 'Vehicle returned!', 'success')
    end
end

-- Function to draw 3D text
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end

RegisterCommand('spawnvehicle', function()
    if QBX.PlayerData.job.name == Config.JobName then
        local model = Config.VehicleSpawnPoint.vehicle.model
        local coords = Config.VehicleSpawnPoint.coords
        
        -- Request and load the model
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(0)
        end
        
        -- Spawn the vehicle
        local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, false)
        SetEntityAsMissionEntity(vehicle, true, true)
        SetVehicleEngineOn(vehicle, true, true, false)
        
        -- Set plate
        local plate = Config.JobName:upper() .. math.random(1000, 9999)
        SetVehicleNumberPlateText(vehicle, plate)
        
        -- Give keys
        TriggerEvent('vehiclekeys:client:SetOwner', plate)
        
        lib.notify({
            title = 'Success',
            description = 'Vehicle spawned!',
            type = 'success'
        })
        
        SetModelAsNoLongerNeeded(model)
    else
        lib.notify({
            title = 'Error',
            description = 'You are not authorized to use this!',
            type = 'error'
        })
    end
end)

