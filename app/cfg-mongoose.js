// Generated by CoffeeScript 1.3.1
var TextMessage, mongoose, util;

mongoose = require('mongoose');

util = require('util');

TextMessage = require('../models/TextMessage');

module.exports = {
  startup: function(dbURL, withSeeds) {
    var _this = this;
    if (withSeeds == null) {
      withSeeds = false;
    }
    console.log("Waiting for MongoDB connection...");
    mongoose.connect(dbURL);
    return mongoose.connection.on('open', function() {
      console.log('...connected');
      if (withSeeds) {
        return _this.seedTextMessages();
      }
    });
  },
  close: function() {
    return mongoose.disconnect();
  },
  seedTextMessages: function(doClearFirst) {
    var msg, msgs, newMsg, _i, _len;
    if (doClearFirst == null) {
      doClearFirst = true;
    }
    if (doClearFirst) {
      TextMessage.collection.drop();
    }
    msgs = require('../stubs/TextMessages');
    for (_i = 0, _len = msgs.length; _i < _len; _i++) {
      msg = msgs[_i];
      newMsg = new TextMessage({
        username: msg.username,
        message_text: msg.text,
        received_at: msg.received_at
      });
      newMsg.save(function(err) {
        if (err) {
          return console.log("Error saving card: " + err);
        }
      });
    }
    return console.log("Seeded DB with " + msgs.length + " msgs...");
  }
};
