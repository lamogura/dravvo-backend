mongoose = require 'mongoose'

UserSchema = new mongoose.Schema
  username:      { type: String, required: true }
  message_text:  { type: String, required: true }
  received_at:   { type : Date,  default : Date.now()}

module.exports = mongoose.model('TextMessage', UserSchema)