mongoose = require 'mongoose'

GameSchema = new mongoose.Schema
  lastUpdate: { type: String, default: null }
  nextTurn:   { type: String, required: true }
  isGameOver: { type: Boolean, default: false }
  createdAt:  { type: Date,  default : Date.now() }

module.exports = mongoose.model('Game', GameSchema)