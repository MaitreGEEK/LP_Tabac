-- Secure server-side handling for harvest / process / sell, synced with Config + client
Config.ActionCooldown = Config.ActionCooldown or 2         -- seconds
Config.HarvestDistance = Config.HarvestDistance or 3.0      -- meters
Config.PlantRespawn     = Config.PlantRespawn or 300        -- seconds (5 min)
Config.ProcessDistance  = Config.ProcessDistance or 3.0
Config.ProcessInput     = Config.ProcessInput or 4
Config.ProcessOutput    = Config.ProcessOutput or 1
Config.SellDistance     = Config.SellDistance or 3.0


local function GetPlayer(src)
    return exports.qbx_core:GetPlayer(src)
end

local function HasTabacJob(player)
    return player and player.PlayerData and player.PlayerData.job
        and player.PlayerData.job.name == 'tabac'
end

-- Use Config values from shared config file
local Plants = {}
for i, coords in ipairs(Config.Fields) do
    Plants[i] = { coords = coords, harvested = false, respawnAt = 0 }
end

local PlayerCooldowns = {}

local function Now() return os.time() end
local function IsOnCooldown(src) return PlayerCooldowns[src] and Now() < PlayerCooldowns[src] end
local function SetCooldown(src, sec) PlayerCooldowns[src] = Now() + sec end
local function Distance(a, b) return #(a - b) end
local function GetCoordsServerSide(src)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return nil end
    local x, y, z = table.unpack(GetEntityCoords(ped))
    return vector3(x, y, z)
end

local function RespawnPlant(id)
    if Plants[id] then
        Plants[id].harvested = false
        Plants[id].respawnAt = 0
        TriggerClientEvent('qbx_tabac:client:respawn_plant', -1, id)
    end
end

-- HARVEST ------------------------------------------------
RegisterNetEvent('qbx_tabac:harvest_plant', function(id, clientCoords)
    local src = source
    local Player = GetPlayer(src)
    if not Player then print(('[QBX-TABAC] %s not a valid player'):format(src)) return end
    if not HasTabacJob(Player) then print(('[QBX-TABAC] %s no tabac job'):format(src)) return end
    if IsOnCooldown(src) then print(('[QBX-TABAC] %s on cooldown'):format(src)) return end

    SetCooldown(src, Config.ActionCooldown)

    local plant = Plants[id]
    if not plant then print(('[QBX-TABAC] %s invalid plant ID %s'):format(src, id)) return end
    if plant.harvested then print(('[QBX-TABAC] %s tried already harvested plant %s'):format(src, id)) return end

    local coords = GetCoordsServerSide(src) or vector3(clientCoords.x, clientCoords.y, clientCoords.z)
    if Distance(coords, plant.coords) > Config.HarvestDistance then
        print(('[QBX-TABAC] %s too far from plant %s'):format(src, id))
        return
    end

    local success = Player.Functions.AddItem(Config.ItemRaw, 1)
    if not success then
        print(('[QBX-TABAC] %s could not receive item'):format(src))
        return
    end

    plant.harvested = true
    plant.respawnAt = Now() + Config.PlantRespawn

    print(('[QBX-TABAC] Respawning plant %d for all clients'):format(id))

    TriggerClientEvent('ox_lib:notify', src, { description = 'Vous avez récolté du tabac', type = 'success' })


    CreateThread(function()
        Wait(Config.PlantRespawn * 1000)
        RespawnPlant(id)  -- This will send the respawn event once after cooldown
    end)
end)


-- PROCESS ------------------------------------------------
RegisterNetEvent('qbx_tabac:process', function()
    local src = source
    local Player = GetPlayer(src)
    if not Player or not HasTabacJob(Player) then return end
    if IsOnCooldown(src) then return end
    SetCooldown(src, Config.ActionCooldown)

    local coords = GetCoordsServerSide(src)
    if not coords or Distance(coords, Config.Process) > Config.ProcessDistance then return end

    if Player.Functions.RemoveItem(Config.ItemRaw, Config.ProcessInput) then
        Player.Functions.AddItem(Config.ItemProcessed, Config.ProcessOutput)
        TriggerClientEvent('ox_lib:notify', src, { description = 'Transformation réussie', type = 'success' })
    else
        TriggerClientEvent('ox_lib:notify', src, { description = 'Pas assez de tabac brut', type = 'error' })
    end
end)

-- SELL ---------------------------------------------------
RegisterNetEvent('qbx_tabac:sell', function()
    local src = source
    local Player = GetPlayer(src)
    if not Player or not HasTabacJob(Player) then return end
    if IsOnCooldown(src) then return end
    SetCooldown(src, Config.ActionCooldown)

    local coords = GetCoordsServerSide(src)
    if not coords or Distance(coords, Config.Sell) > Config.SellDistance then return end

    local item = Player.Functions.GetItemByName(Config.ItemProcessed)
    if not item or item.amount < 1 then
        TriggerClientEvent('ox_lib:notify', src, { description = 'Rien à vendre', type = 'error' })
        return
    end

    Player.Functions.RemoveItem(Config.ItemProcessed, item.amount)
    Player.Functions.AddMoney('cash', item.amount * Config.SellPrice)
    TriggerClientEvent('ox_lib:notify', src,
        { description = ('Vous avez vendu pour $%s'):format(item.amount * Config.SellPrice), type = 'success' })
end)

AddEventHandler('playerDropped', function()
    PlayerCooldowns[source] = nil
end)
