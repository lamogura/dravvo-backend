mainRoutes = require './main_routes'

module.exports = (app) ->
	app.get  '/',         mainRoutes.home
	app.post '/newmsg', 	mainRoutes.newmsg