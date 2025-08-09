local ox_target = exports.ox_target
local plants = {}

local activePlantIds = {}
local MAX_ACTIVE_PLANTS = 5

local isHarvesting = false

local function AddActivePlant(id)
    table.insert(activePlantIds, id)
end

local function RemoveActivePlant(id)
    for i, v in ipairs(activePlantIds) do
        if v == id then
            table.remove(activePlantIds, i)
            break
        end
    end
end

local function DeletePlant(id)
    local plant = plants[id]
    if plant and DoesEntityExist(plant) then
        print("Deleting plant with ID: " .. tostring(id))

        ox_target:removeLocalEntity(plant)
        SetEntityAsMissionEntity(plant, true, true)
        DeleteObject(plant)
        Wait(50)
        if DoesEntityExist(plant) then
            DeleteObject(plant)
        end

        plants[id] = nil
    else
        print("DeletePlant called but plant does not exist or is invalid: " .. tostring(id))
    end
end

-- Forward declare SpawnRandomPlants so SpawnPlant can call it
local SpawnRandomPlants

local function SpawnPlant(coords, id)
    local model = Config.PlantModel

    RequestModel(model)
    local start = GetGameTimer()
    while not HasModelLoaded(model) do
        Wait(10)
        if GetGameTimer() - start > 5000 then
            print("^1[QBX-TABAC] Model "..model.." failed to load^0")
            return
        end
    end

    local plant = CreateObject(model, coords.x, coords.y, coords.z, false, true, true)
    SetEntityCoordsNoOffset(plant, coords.x, coords.y, coords.z, false, false, false)
    FreezeEntityPosition(plant, true)
    SetEntityInvincible(plant, true)
    SetModelAsNoLongerNeeded(model)

    ox_target:addLocalEntity(plant, {
        {
            name = 'qbx_tabac_harvest_' .. id,
            icon = 'fas fa-hand-paper',
            label = 'Récolter le tabac',
            onSelect = function()
                if isHarvesting then return end
                isHarvesting = true

                local ped = PlayerPedId()
                TaskStartScenarioInPlace(ped, "world_human_gardener_plant", 0, true)
                TriggerEvent('ox_lib:notify', {description = 'Récolte en cours...', type = 'info'})

                Wait(5000)

                ClearPedTasks(ped)
                TriggerServerEvent('qbx_tabac:harvest_plant', id)

                DeletePlant(id)
                RemoveActivePlant(id)

                if #activePlantIds == 0 then
                    SpawnRandomPlants()
                end

                isHarvesting = false
            end,
            canInteract = function()
                return not isHarvesting
            end,
            distance = 2.5,
        }
    })

    plants[id] = plant
end

-- Now assign the actual SpawnRandomPlants function
SpawnRandomPlants = function()
    for _, id in pairs(activePlantIds) do
        DeletePlant(id)
    end
    activePlantIds = {}

    local availableCoords = {}
    for id, coords in pairs(Config.Fields) do
        table.insert(availableCoords, {id = id, coords = coords})
    end

    for i = #availableCoords, 2, -1 do
        local j = math.random(i)
        availableCoords[i], availableCoords[j] = availableCoords[j], availableCoords[i]
    end

    for i = 1, math.min(MAX_ACTIVE_PLANTS, #availableCoords) do
        local data = availableCoords[i]
        SpawnPlant(data.coords, data.id)
        AddActivePlant(data.id)
    end
end

CreateThread(function()
    SpawnRandomPlants()

    -- Interaction pour transformer le tabac
    ox_target:addBoxZone({
        coords = Config.Process,
        size = vec3(2, 2, 2),
        rotation = 0,
        debug = false,
        options = {
            {
                name = 'qbx_tabac_process',
                icon = 'fas fa-industry',
                label = 'Transformer tabac',
                onSelect = function()
                    TriggerServerEvent('qbx_tabac:process')
                end,
                distance = 2.5,
            }
        }
    })

    -- Interaction pour vendre les cigarettes
    ox_target:addBoxZone({
        coords = Config.Sell,
        size = vec3(2, 2, 2),
        rotation = 0,
        debug = false,
        options = {
            {
                name = 'qbx_tabac_sell',
                icon = 'fas fa-dollar-sign',
                label = 'Vendre cigarettes',
                onSelect = function()
                    TriggerServerEvent('qbx_tabac:sell')
                end,
                distance = 2.5,
            }
        }
    })
end)
