fx_version 'cerulean'
game 'gta5'

description 'QBX Tabac Job'
author 'Littlepork1'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/shared/locale.lua',
    'config.lua',
    '@qbx_core/modules/lib.lua'	
}

client_scripts {
    'client/*',
    '@qbx_core/modules/playerdata.lua',
}

server_scripts {
    'server/*'
}

lua54 'yes'

dependencies {
    'ox_lib',
    'qbx_core'
}