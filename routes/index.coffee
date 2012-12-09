message_routes = require './message_routes'
apns_routes = require './apns_routes'

module.exports = (app) ->
  app.get  '/message/all', message_routes.showAll
  app.post '/message/new', message_routes.newMessage
  
  app.delete '/message/:dbID/delete', message_routes.deleteMsg
  app.delete '/message/all',          message_routes.deleteAll

  app.post '/apns/testsend', apns_routes.testSend