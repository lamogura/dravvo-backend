message_routes = require './message_routes'

module.exports = (app) ->
	app.get			'/message/all',	message_routes.show_all
	app.post		'/message/new',	message_routes.new_message
	app.delete	'/message/all',	message_routes.delete_all