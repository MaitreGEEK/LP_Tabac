local function GetPlayer(src)
    return exports.qbx_core:GetPlayer(src)
end

local function HasTabacJob(player)
    return player and player.PlayerData and player.PlayerData.job and player.PlayerData.job.name == 'tabac'
end

-- Récolte tabac (depuis ox_target interaction prop plante)
RegisterNetEvent('qbx_tabac:harvest_plant', function(id)
    local src = source
    local Player = GetPlayer(src)
    if not Player then return end

    if not HasTabacJob(Player) then
        TriggerClientEvent('ox_lib:notify', src, {
            description = "Vous n'êtes pas tabagiste !",
            type = 'error'
        })
        return
    end

    Player.Functions.AddItem(Config.ItemRaw, 1)

    -- Broadcast suppression et respawn plant
    TriggerClientEvent('qbx_tabac:client:respawn_plant', -1, id)

    TriggerClientEvent('ox_lib:notify', src, {
        description = 'Vous avez récolté du tabac',
        type = 'success'
    })
end)

-- Transformation tabac brut en cigarette
RegisterNetEvent('qbx_tabac:process', function()
    local src = source
    local Player = GetPlayer(src)
    if not Player then return end

    if not HasTabacJob(Player) then
        TriggerClientEvent('ox_lib:notify', src, {
            description = "Vous n'êtes pas tabagiste !",
            type = 'error'
        })
        return
    end

    if Player.Functions.RemoveItem(Config.ItemRaw, 4) then
        Player.Functions.AddItem(Config.ItemProcessed, 1)
        TriggerClientEvent('ox_lib:notify', src, {
            description = 'Vous avez fabriqué une cigarette',
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            description = 'Pas assez de tabac brut',
            type = 'error'
        })
    end
end)

-- Vente des cigarettes
RegisterNetEvent('qbx_tabac:sell', function()
    local src = source
    local Player = GetPlayer(src)
    if not Player then return end

    if not HasTabacJob(Player) then
        TriggerClientEvent('ox_lib:notify', src, {
            description = "Vous n'êtes pas tabagiste !",
            type = 'error'
        })
        return
    end

    local item = Player.Functions.GetItemByName(Config.ItemProcessed)
    local count = item and item.amount or 0

    if count > 0 then
        Player.Functions.RemoveItem(Config.ItemProcessed, count)
        Player.Functions.AddMoney('cash', count * Config.SellPrice)
        TriggerClientEvent('ox_lib:notify', src, {
            description = string.format('Vous avez vendu vos cigarettes pour $%s', count * Config.SellPrice),
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            description = 'Vous n\'avez rien à vendre',
            type = 'error'
        })
    end
end)
