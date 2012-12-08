mongoose    = require('mongoose')
util        = require('util')
TextMessage = require('../models/TextMessage')

module.exports =
  startup: (dbURL, withSeeds=false) ->
    console.log "Waiting for MongoDB connection..."
    mongoose.connect(dbURL)
    mongoose.connection.on 'open', => 
      console.log '...connected'
      @seedTextMessages() if withSeeds

  close: -> mongoose.disconnect()

  seedTextMessages: (doClearFirst=true) ->
    TextMessage.collection.drop() if doClearFirst
    
    msgs = require '../stubs/TextMessages'

    for msg in msgs
      newMsg = new TextMessage
        username:     msg.username
        message_text: msg.text
        received_at:  msg.received_at

      newMsg.save (err) ->
        console.log "Error saving card: #{err}" if err

    console.log "Seeded DB with #{msgs.length} msgs..."