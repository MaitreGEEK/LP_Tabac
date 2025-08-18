fx_version 'cerulean'
game 'gta5'

description 'Job Tabac pour QBX Core'
author 'Littlepork1'
version '1.0.0'

shared_scripts {
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
