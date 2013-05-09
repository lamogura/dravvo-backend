# imports
mongoose = require('mongoose') # object mapper for mongodb
express = require 'express' # sinatra like web framework
util = require('util') # gives some sys utilities

# database models
TextMessageSchema = new mongoose.Schema
  username:   { type: String, required: true }
  text:       { type: String, required: true }
  receivedAt: { type : Date,  default: Date.now }

TextMessage = mongoose.model('TextMessage', TextMessageSchema)

# setup database url
dburl = 'mongodb://localhost/dravvo' # assume local first

if process.env.VCAP_SERVICES # check for if we are on appfog, then use their defined way to get dburl
  env = JSON.parse(process.env.VCAP_SERVICES)
  mongo = env['mongodb-1.8'][0]['credentials']
  dburl = "mongodb://#{mongo.username}:#{mongo.password}@#{mongo.hostname}:#{mongo.port}/#{mongo.db}"

# connect to the database
mongoose.connect dburl
mongoose.connection.on 'open', -> console.log "MongoDB connected to #{dburl}"

# make the express app
app = express()

# configure the common parts we need
app.configure ->
  app.use express.bodyParser() # parser for request body
  app.use express.methodOverride() # gives us del, patch http verbs etc (default is only get & post)

# optional config for dev mode (if NODE_ENV=development)
app.configure 'development', ->
  console.log "* development mode"
  # extra debugging info on a fail
  app.use express.errorHandler { dumpExceptions: true, showStack: true }

# optional config for production mode (if NODE_ENV=development)
app.configure 'production', ->
  console.log "* production mode"
  # use standard errors
  app.use express.errorHandler()

# the URL routes we will listen for
app.get '/', (req, res) ->
  # get all text messages in reverse chronological order
  TextMessage.find({}).sort('-receivedAt').exec (err, msgs) ->
    if err?
      console.log "got an error #{err}"
      return res.json 500, {erorr: err} # http code, then dict of error
    else
        # return all messages as a JSON object
      console.log "msgs: #{util.inspect(msgs)}"
      return res.json msgs # res.json takes care of converting object to json, uses http code 200 by default

# take a post to this URL of the text message to save to DB
app.post '/newmsg', (req, res) -> 
  console.log "received body: #{util.inspect(req.body)}"

  # create new object for saving to DB
  msg = new TextMessage
    username: req.body.username
    text: req.body.text

  # return JSON object as response if success or error
  console.log "saving message: #{util.inspect(msg)}"
  msg.save (err, msg) ->
    if err?
      console.log "got an error #{err}"
      return res.json 500, {error: err} # http code, then dict of error
    else
        # return message as a JSON object
      console.log "msgs: #{util.inspect(msgs)}"
      return res.json msg # res.json takes care of converting object to json, uses http code 200 by default

# determine port to run on, appfog uses VCAP_APP_PORT
port = process.env.VCAP_APP_PORT or process.env.PORT or 3000

# start the server on the port
app.listen port, -> console.log "Listening on #{port}\nPress CTRL-C to stop server."
