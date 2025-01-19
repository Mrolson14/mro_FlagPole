fx_version 'cerulean'
game 'gta5'

author '⸸♱♥ 𝓜𝓻.𝓢𝓜𝓤𝓡𝓕 ♥♱⸸ & Mr.Olson14'
description 'slrp_FlagPole'
version '1.0.0'
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

