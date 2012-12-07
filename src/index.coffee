express = require 'express'
stylus  = require 'stylus'
assets  = require 'connect-assets'
db      = require './cfg-mongoose'

app = express()

app.configure ->
  app.use express.bodyParser()

app.configure 'development', ->
	console.log "* development mode"
	app.use express.errorHandler { dumpExceptions: true, showStack: true }
	db.startup 'mongodb://localhost/dravvo', true
	
app.configure 'production', ->
  console.log "* production mode"
  app.use express.errorHandler()

  if not process.env.VCAP_SERVICES?
    console.log "Error: couldnt find VCAP_SERVICES in process.env" 
  
  env = JSON.parse process.env.VCAP_SERVICES
  mongo = env['mongodb-1.8'][0]['credentials']
  dburl = "mongodb://#{mongo.username}:#{mongo.password}@#{mongo.hostname}:#{mongo.port}/#{mongo.db}"
  db.startup dburl

require('../routes')(app)

port = process.env.VCAP_APP_PORT or process.env.PORT or 3000

app.listen port, -> console.log "Listening on #{port}\nPress CTRL-C to stop server."