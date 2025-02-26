Config = {}

Config.Debug = true

-- Job Settings
Config.JobName = 'tabac' -- Make sure this matches exactly with your job name

-- Blip Settings
Config.Blip = {
    coords = vec3(-43.38, -1060.54, 27.81), -- Replace with your job location
    sprite = 79,
    display = 4,
    scale = 0.7,
    color = 5,
    name = "Tabac" -- Replace with your job name
}

-- Vehicle Settings
Config.VehicleSpawnPoint = {
    coords = vec4(-51.47, -1050.81, 27.96, 343.64), -- Your coordinates
    marker = {
        type = 36,
        size = vector3(1.5, 1.5, 1.5),
        color = {r = 0, g = 150, b = 255, a = 155},
        distance = 7.0
    },
    vehicle = {
        model = 'mule', -- Make sure this is a valid vehicle model
        defaultFuel = 100
    }
}

Config.VehicleReturnPoint = {
    coords = vec3(-50.72, -1068.71, 26.41), -- Replace with return point coords
    marker = {
        type = 1,
        size = vector3(3.0, 3.0, 1.0),
        color = {r = 255, g = 0, b = 0, a = 155},
        distance = 7.0
    }
} 