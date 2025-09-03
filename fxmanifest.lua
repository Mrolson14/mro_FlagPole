fx_version 'cerulean'
game 'gta5'

author 'Mr.Olson14'
description 'flagPole'
version '2.0.0'
lua54 'yes'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

