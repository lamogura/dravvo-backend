# imports
mongoose = require('mongoose') # object mapper for mongodb
express = require 'express' # sinatra like web framework
util = require('util') # gives some sys utilities

# database models
TextMessageSchema = new mongoose.Schema
	username:	 	{ type: String, required: true }
	text:				{ type: String, required: true }
	receivedAt: { type : Date,	default : Date.now()}

TextMessage = mongoose.model('TextMessage', TextMessageSchema)

# database utility object for easy connecting etc (like a class)
db = 
	startup: (dbURL) ->
		# connect to the passed mongo DB url
		console.log "Waiting for MongoDB connection..."
		mongoose.connect(dbURL)
		mongoose.connection.on 'open', -> console.log '...connected'

	# call this when finished
	close: -> mongoose.disconnect()

	seedTextMessages: (doClearFirst=false) ->
		# remove all existing data in DB
		TextMessage.collection.drop() if doClearFirst
		
		# import test messages
		msgs = require '../stubs/TextMessages'
		# console.log util.inspect(msgs)

		for msg in msgs
			# create new object for saving into DB
			newMsg = new TextMessage
				username: msg.username
				text: msg.text
				receivedAt: msg.receivedAt

			# save to DB
			newMsg.save (err) ->
				console.log "Error saving card: #{err}" if err

		console.log "Seeded DB with #{msgs.length} msgs..."

# make the express app
app = express()

# configure the parts we need
app.configure ->
	app.use express.bodyParser() # parser for request body

# optional config for dev mode (if NODE_ENV=development)
app.configure 'development', ->
	console.log "* development mode"
	
	# extra debugging info on a fail
	app.use express.errorHandler { dumpExceptions: true, showStack: true }
	
	# connect to our local mongo DB
	db.startup 'mongodb://localhost/dravvo'

	# seed our test messages into DB
	db.seedTextMessages(true)

# optional config for production mode (if NODE_ENV=development)
app.configure 'production', ->
	console.log "* production mode"
	# use standard errors
	app.use express.errorHandler()

	# this all comes from appfog tutorial on using mongo DB on their server
	if not process.env.VCAP_SERVICES?
		console.log "Error: couldnt find VCAP_SERVICES in process.env" 
	
	env = JSON.parse(process.env.VCAP_SERVICES)
	mongo = env['mongodb-1.8'][0]['credentials']
	dburl = "mongodb://#{mongo.username}:#{mongo.password}@#{mongo.hostname}:#{mongo.port}/#{mongo.db}"
	
	# connect to remote mongo DB
	db.startup dburl

# the URL routes we will listen for
app.get '/', (req, res) ->
	# get all text messages in reverse chronological order
	TextMessage.find({}).sort('-receivedAt').execFind (err, msgs) ->
		# return all messages as a JSON object
		res.writeHead 200, {"Content-Type": "application/json"}
		if err
			console.log err
			res.end JSON.stringify
			status: "error"
			details: err
		else
			console.log "msgs: #{util.inspect(msgs)}"
			res.end JSON.stringify(msgs)
		
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
		res.writeHead 200, {"Content-Type": "application/json"}
		if err
			console.log err
			res.write JSON.stringify
				status: "error"
				details: err
		else
			console.log "saved successful"
			res.write JSON.stringify
				status: "ok"
				saved_msg: msg
		res.end()

# determine port to run on, appfog uses VCAP_APP_PORT
port = process.env.VCAP_APP_PORT or process.env.PORT or 3000

# start the server on the port
app.listen port, -> console.log "Listening on #{port}\nPress CTRL-C to stop server."