TextMessage = require '../models/TextMessage'
util = require 'util'

JSON_CONTENT = {"Content-Type": "application/json"}

module.exports.show_all = (req, res) ->
	console.log "GET to '/message/all'"
	TextMessage.find({}).sort('receivedAt').execFind (error, msgs) ->
		if error
			status_code = 500 # server error
			json_response = JSON.stringify {error}
		else
			status_code = 200 # ok
			json_response = JSON.stringify msgs

		res.writeHead status_code, JSON_CONTENT
		console.log "Response: #{json_response}"
		res.end json_response
		
module.exports.new_message = (req, res) -> 
	console.log "POST to '/message/new' with body: #{util.inspect(req.body)}"

	msg = new TextMessage
		username: req.body.username
		text: req.body.message

	console.log "Saving TextMessage to DB: #{util.inspect(msg)}"
	msg.save (error, msg) ->
		status_code = 200 # ok
		if error
			status_code = 500 # server error
			json_response = JSON.stringify {error}
		else
			json_response = JSON.stringify {saved_message: msg}

		res.writeHead status_code, JSON_CONTENT
		console.log "Response: #{json_response}"
		res.end json_response

module.exports.delete_all = (req, res) -> 
	console.log "DELETE to '/message/all' with body: #{util.inspect(req.body)}"
	status_code = 200 # ok

	if req.body.password is "matsuya"
		TextMessage.remove {}, (error) ->
			console.log "delete successful"
			if error
				status_code = 500 # server error
				json_response = JSON.stringify {error}
			else
				json_response = JSON.stringify {result: "All text messages deleted from DB"}

			res.writeHead status_code, JSON_CONTENT
			console.log "Response: #{json_response}"
			res.end json_response
	else
		status_code = 401 # unauthorized
		json_response = JSON.stringify {result: "Not an authorized action, sorry."}

		res.writeHead status_code, JSON_CONTENT
		console.log "Response: #{json_response}"
		res.end json_response

# // Find First 10 News Items
# News.find({
#     deal_id:deal._id // Search Filters
# },
# ['type','date_added'], // Columns to Return
# {
#     skip:0, // Starting Row
#     limit:10, // Ending Row
#     sort:{
#         date_added: -1 //Sort by Date Added DESC
#     }
# },
# function(err,allNews){
#     socket.emit('news-load', allNews); // Do something with the array of 10 objects
# })