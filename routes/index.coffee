message_routes = require './message_routes'

module.exports = (app) ->
  app.get     '/message/all', message_routes.showAll
  app.post    '/message/new', message_routes.newMessage
  app.delete  '/message/all', message_routes.deleteAll