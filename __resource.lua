description 'ESX Scubashop'

version '0.7.1'

client_scripts {
	'config.lua',
	'client/main.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server/main.lua'
}
