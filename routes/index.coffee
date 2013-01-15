game_routes = require './game_routes'

module.exports = (app) ->
  app.post '/game/new',            game_routes.newGame
  app.get  '/game/:gameID',        game_routes.getGame
  app.post '/game/:gameID/update', game_routes.updateGame