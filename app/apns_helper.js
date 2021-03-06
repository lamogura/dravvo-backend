// Generated by CoffeeScript 1.3.3
var apns, errorHandler, util;

apns = require('apn');

util = require('util');

errorHandler = function(err, notification) {
  console.log("Error sending APNS notification");
  console.log(util.inspect(err));
  return console.log(util.inspect(notification));
};

module.exports.SendAPN = function(deviceToken, message, badgeCount, alertSound, payload) {
  var apnsConnection, iosDevice, note, options;
  if (badgeCount == null) {
    badgeCount = 0;
  }
  if (alertSound == null) {
    alertSound = "ping.aiff";
  }
  if (payload == null) {
    payload = null;
  }
  console.log("Sending notification to APNS for device: " + deviceToken);
  console.log("*** returning premature, no actual APNS sent ***");
  return 0;
  options = {
    cert: 'apns-prod-cert.pem',
    certData: null,
    key: 'apns-prod-key.pem',
    keyData: null,
    passphrase: "ferasdf",
    ca: null,
    pfx: null,
    pfxData: null,
    gateway: 'gateway.sandbox.push.apple.com',
    port: 2195,
    rejectUnauthorized: true,
    enhanced: true,
    errorCallback: errorHandler,
    cacheLength: 100,
    autoAdjustCache: true,
    connectionTimeout: 0
  };
  apnsConnection = new apns.Connection(options);
  iosDevice = new apns.Device(deviceToken);
  note = new apns.Notification();
  note.expiry = Math.floor(Date.now() / 1000) + 3600;
  note.badge = badgeCount;
  note.sound = alertSound;
  note.alert = message;
  note.payload = payload;
  note.device = iosDevice;
  return apnsConnection.sendNotification(note);
};
