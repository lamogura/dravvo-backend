mongoose = require 'mongoose'

UserSchema = new mongoose.Schema
	username:		{ type: String, required: true }
	text:				{ type: String, required: true }
	receivedAt:	{ type : Date,  default : Date.now()}

module.exports = mongoose.model('TextMessage', UserSchema)