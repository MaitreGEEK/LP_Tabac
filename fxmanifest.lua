fx_version 'cerulean'
game 'gta5'

description 'Job Tabac pour QBX Core'
author 'TonPseudo'
version '1.0.0'

shared_scripts {
    '@qbx_core/import.lua', -- Import QBX Core
    'config.lua',
    'locales/*.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
