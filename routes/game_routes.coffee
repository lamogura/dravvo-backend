Game = require '../models/Game'
apns = require '../src/apns_helper'
util = require 'util'

#hardcoded device ids for now
deviceTokens = 
  p1: "073af1914b43e524976062ab82d537556b356e5efd5a10ca4e28cf7d3db6fbb3" #justin
  p2: "b" #jeremy

module.exports.newGame = (req, res) -> 
  console.log "#{req.method} to '#{req.url}' with body: #{util.inspect(req.body)}'"

  game = new Game
    nextTurn: req.body.deviceToken

  console.log "Saving Game to DB: #{util.inspect(game)}"
  game.save (error, game) ->
    status_code = 200 # ok
    if error
      status_code = 500 # server error
      json_response = JSON.stringify {error}
    else
      json_response = JSON.stringify {game}

    res.writeHead status_code, {"Content-Type": "application/json"}
    console.log "Response: #{json_response}"
    res.end json_response

module.exports.getGame = (req, res) -> 
  console.log "#{req.method} to '#{req.url}' with body: #{util.inspect(req.body)}'"

  console.log "Searching for Game with ID: #{req.params.gameID}"
  Game.findOne {_id: req.params.gameID}, (error, game) ->
    status_code = 200 # ok
    if error
      status_code = 500 # server error
      json_response = JSON.stringify {error}
    else
      json_response = JSON.stringify {game}

    res.writeHead status_code, {"Content-Type": "application/json"}
    console.log "Response: #{json_response}"
    res.end json_response

module.exports.updateGame = (req, res) -> 
  console.log "#{req.method} to '#{req.url}' with body: #{util.inspect(req.body)}'"

  console.log "Searching for Game with ID: #{req.params.gameID}"
  Game.findOne {_id: req.params.gameID}, (error, game) ->
    status_code = 200 # ok
    if error
      status_code = 500 # server error
      json_response = JSON.stringify {error}
      res.writeHead status_code, {"Content-Type": "application/json"}
      console.log "Response: #{json_response}"
      res.end json_response
    else
      if req.body.deviceToken isnt game.nextTurn
        status_code = 500
        json_response = JSON.stringify {error: "It is not your turn, no cheatin!!!"}
        res.writeHead status_code, {"Content-Type": "application/json"}
        console.log "Response: #{json_response}"
        res.end json_response
      else
        console.log "Updating game with update: #{req.body.lastUpdate}"
        game.lastUpdate = req.body.lastUpdate

        console.log "Was '#{game.nextTurn}' turn"
        game.nextTurn = if game.nextTurn is deviceTokens.p1 then deviceTokens.p2 else deviceTokens.p1
        console.log "Now its '#{game.nextTurn}' turn"

        game.isGameOver = req.body.isGameOver unless req.body.isGameOver? is false

        game.save (error, game) ->
          if error
            status_code = 500 # server error
            json_response = JSON.stringify {error}
          else
            json_response = JSON.stringify {status: "ok"}

          apns.SendAPN(game.nextTurn, "Your turn loser!", 1)

          res.writeHead status_code, {"Content-Type": "application/json"}
          console.log "Response: #{json_response}"
          res.end json_response