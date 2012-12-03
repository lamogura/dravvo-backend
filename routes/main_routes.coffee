TextMessage = require '../models/TextMessage'
util = require 'util'

module.exports.home = (req, res) ->
	TextMessage.find({}).sort('-receivedAt').execFind (err, msgs) ->
		if err
			console.log err
		else
			console.log "msgs: #{util.inspect(msgs)}"

		res.writeHead 200, {"Content-Type": "application/json"}
		res.end JSON.stringify(msgs)
		
module.exports.newmsg = (req, res) -> 
	console.log "received body: #{util.inspect(req.body)}"

	msg = new TextMessage
		username: req.body.username
		text: req.body.text

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