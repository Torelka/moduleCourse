fx_version 'cerulean'
game 'gta5'

author ''
description ''
version '1.0.0'
server_script {'@mysql-async/lib/MySQL.lua','server/*.lua'}
client_script {
    "src/RageUI.lua",
	"src/Menu.lua",
	"src/MenuController.lua",
	"src/components/*.lua",
	"src/elements/*.lua",
	"src/items/*.lua",
	"src/panels/*.lua",
	"src/windows/*.lua",
    'client/*.lua',
}
shared_script 'shared/*.lua'

