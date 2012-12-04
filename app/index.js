// Generated by CoffeeScript 1.3.3
var TextMessage, TextMessageSchema, app, db, express, mongoose, port, util;

mongoose = require('mongoose');

express = require('express');

util = require('util');

TextMessageSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true
  },
  text: {
    type: String,
    required: true
  },
  receivedAt: {
    type: Date,
    "default": Date.now()
  }
});

TextMessage = mongoose.model('TextMessage', TextMessageSchema);

db = {
  startup: function(dbURL) {
    console.log("Waiting for MongoDB connection...");
    mongoose.connect(dbURL);
    return mongoose.connection.on('open', function() {
      return console.log('...connected');
    });
  },
  close: function() {
    return mongoose.disconnect();
  },
  seedTextMessages: function(doClearFirst) {
    var msg, msgs, newMsg, _i, _len;
    if (doClearFirst == null) {
      doClearFirst = false;
    }
    if (doClearFirst) {
      TextMessage.collection.drop();
    }
    msgs = require('../stubs/TextMessages');
    for (_i = 0, _len = msgs.length; _i < _len; _i++) {
      msg = msgs[_i];
      newMsg = new TextMessage({
        username: msg.username,
        text: msg.text,
        receivedAt: msg.receivedAt
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

app = express();

app.configure(function() {
  return app.use(express.bodyParser());
});

app.configure('development', function() {
  console.log("* development mode");
  app.use(express.errorHandler({
    dumpExceptions: true,
    showStack: true
  }));
  db.startup('mongodb://localhost/dravvo');
  return db.seedTextMessages(true);
});

app.configure('production', function() {
  var dburl, env, mongo;
  console.log("* production mode");
  app.use(express.errorHandler());
  if (!(process.env.VCAP_SERVICES != null)) {
    console.log("Error: couldnt find VCAP_SERVICES in process.env");
  }
  env = JSON.parse(process.env.VCAP_SERVICES);
  mongo = env['mongodb-1.8'][0]['credentials'];
  dburl = "mongodb://" + mongo.username + ":" + mongo.password + "@" + mongo.hostname + ":" + mongo.port + "/" + mongo.db;
  return db.startup(dburl);
});

app.get('/', function(req, res) {
  return TextMessage.find({}).sort('-receivedAt').execFind(function(err, msgs) {
    res.writeHead(200, {
      "Content-Type": "application/json"
    });
    if (err) {
      console.log(err);
      res.end(JSON.stringify);
      return {
        status: "error",
        details: err
      };
    } else {
      console.log("msgs: " + (util.inspect(msgs)));
      return res.end(JSON.stringify(msgs));
    }
  });
});

app.post('/newmsg', function(req, res) {
  var msg;
  console.log("received body: " + (util.inspect(req.body)));
  msg = new TextMessage({
    username: req.body.username,
    text: req.body.text
  });
  console.log("saving message: " + (util.inspect(msg)));
  return msg.save(function(err, msg) {
    res.writeHead(200, {
      "Content-Type": "application/json"
    });
    if (err) {
      console.log(err);
      res.write(JSON.stringify({
        status: "error",
        details: err
      }));
    } else {
      console.log("saved successful");
      res.write(JSON.stringify({
        status: "ok",
        saved_msg: msg
      }));
    }
    return res.end();
  });
});

port = process.env.VCAP_APP_PORT || process.env.PORT || 3000;

app.listen(port, function() {
  return console.log("Listening on " + port + "\nPress CTRL-C to stop server.");
});
