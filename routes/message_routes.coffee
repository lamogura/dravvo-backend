TextMessage = require '../models/TextMessage'
util = require 'util'

module.exports.showAll = (req, res) ->
  console.log "#{req.method} to '#{req.url}' with body: #{util.inspect(req.body)}'"
  TextMessage.find({}).sort('-_id').execFind (error, msgs) ->
    if error
      status_code = 500 # server error
      json_response = JSON.stringify {error}
    else
      status_code = 200 # ok
      json_response = JSON.stringify msgs

    res.writeHead status_code, {
      "Content-Type": "application/json"
      "Pragma": "no-cache"
      "Cache-Control": "s-maxage=0, max-age=0, must-revalidate, no-cache"
    }

    console.log "Response: #{json_response}"
    res.end json_response
    
module.exports.newMessage = (req, res) -> 
  console.log "#{req.method} to '#{req.url}' with body: #{util.inspect(req.body)}'"

  msg = new TextMessage
    username:     req.body.username
    message_text: req.body.message_text

  console.log "Saving TextMessage to DB: #{util.inspect(msg)}"
  msg.save (error, msg) ->
    status_code = 200 # ok
    if error
      status_code = 500 # server error
      json_response = JSON.stringify {error}
    else
      json_response = JSON.stringify {saved_message: msg}

    res.writeHead status_code, {"Content-Type": "application/json"}
    console.log "Response: #{json_response}"
    res.end json_response

module.exports.deleteAll = (req, res) -> 
  console.log "#{req.method} to '#{req.url}' with body: #{util.inspect(req.body)}'"

  status_code = 200 # ok

  if req.body.password is "matsuya"
    TextMessage.remove {}, (error) ->
      console.log "delete successful"
      if error
        status_code = 500 # server error
        json_response = JSON.stringify {error}
      else
        json_response = JSON.stringify {result: "All text messages deleted from DB"}

      res.writeHead status_code, {"Content-Type": "application/json"}
      console.log "Response: #{json_response}"
      res.end json_response
  else
    status_code = 401 # unauthorized
    json_response = JSON.stringify {result: "Not an authorized action, sorry."}

    res.writeHead status_code, {"Content-Type": "application/json"}
    console.log "Response: #{json_response}"
    res.end json_response

module.exports.deleteMsg = (req, res) ->
  console.log "#{req.method} to '#{req.url}' with body: #{util.inspect(req.body)}'"

  console.log "Deleting TextMessage with _id: #{req.params.dbID}"
  TextMessage.remove { _id: req.params.dbID }, (error) ->
    status_code = 200 # ok
    if error
      status_code = 500 # server error
      json_response = JSON.stringify {error}
    else
      json_response = JSON.stringify {result: "Deleted message sucessfully."}

    res.writeHead status_code, JSON_CONTENT
    console.log "Response: #{json_response}"
    res.end json_response