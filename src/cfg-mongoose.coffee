mongoose = require('mongoose')
util = require('util')
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
		# console.log util.inspect(msgs)

		for msg in msgs
			newMsg = new TextMessage
				username: msg.username
				text: msg.text
				receivedAt: msg.receivedAt

			newMsg.save (err) ->
				console.log "Error saving card: #{err}" if err

		console.log "Seeded DB with #{msgs.length} msgs..."

	# # TODO: get rid of getAllCards() only should exist during alpha stage
	# getAllCards: (callback) ->
	# 	Card.find (err, cards) ->
	# 		callback(err, cards)

	# findCardById: (id, callback) ->
	# 	Card.findById id, (err, card) ->
	# 		callback(err, card)

	# deleteCardById: (id, callback) ->
	# 	Card.findById id, (err, card) ->
	# 		if err then callback(err)
	# 		else 
	# 			console.log "Deleting Card id: #{id}"
	# 			card.remove()
	# 			callback(null)

	# seed_cards_to_db: (limit=false, doClearFirst=false) ->
	# 	Card.collection.drop() if doClearFirst

	# 	count = 1
	# 	for card in require './stubs/cards'
	# 		new_card = new Card
	# 			entry: card.entry
	# 			reading: card.reading
	# 			defn: card.defn
	# 			score: card.score
	# 			language: "japanese"
	# 			readingScore: card.readingScore
	# 			defnScore: card.defnScore

	# 		new_card.save (err) ->
	# 			console.log "Error saving card: #{err}" if err

	# 		count += 1
	# 		break if limit and count > limit

	# 	console.log "Seeded DB with #{count-1} cards..."