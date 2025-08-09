Config = {}

-- Positions
Config.Fields = {
    vec3(2479.71, 4735.13, 33.3),
    vec3(2473.56, 4741.88, 33.3),
    vec3(2467.64, 4734.59, 33.3),
    vec3(2471.57, 4725.44, 33.3),
    vec3(2487.81, 4720.66, 33.3),
    vec3(2493.33, 4730.73, 33.3),
    vec3(2489.82, 4739.81, 33.3)
} -- Champs tabac (récolte)

Config.Process = vector3(1544.74, 2233.19, 77.67)   -- Transformation
Config.Sell = vector3(-1172.54, -1571.12, 4.66)     -- Vente

-- Items
Config.ItemRaw = 'tabac_brut'
Config.ItemProcessed = 'cigarette'

-- Prix
Config.SellPrice = 10

-- Modèle prop plante et timer respawn
Config.PlantModel = 'prop_weed_01' -- à adapter si besoin
Config.RespawnTime = 5 -- en secondes (5 minutes)
