apns = require 'apn'
util = require 'util'
path = require 'path' 
errorHandler = (err, notification) ->
  console.log util.inspect(err)
  console.log util.inspect(notification)

module.exports.testSend = (req, res) ->
  console.log "#{req.method} to '#{req.url}' with body: #{util.inspect(req.body)}'"
  console.log path.join(path.dirname(require.main.filename), "/src/afile.jpg")

  deviceToken = req.body.deviceID
  console.log "Attempting to send APNS to DeviceID: #{deviceToken}"
  options =
    cert: 'apns-prod-cert.pem'        # Certificate file path
    certData: null                           # String or Buffer containing certificate data, if supplied uses this instead of cert file path
    key: 'apns-prod-key.pem'          # Key file path
    keyData: null                            # String or Buffer containing key data, as certData
    passphrase: null                         # A passphrase for the Key file
    ca: null                                 # String or Buffer of CA data to use for the TLS connection
    gateway: 'gateway.sandbox.push.apple.com'# gateway address, "gateway.sandbox.push.apple.com" for dev, "gateway.push.apple.com" for production
    port: 2195                               # gateway port
    enhanced: true                           # enable enhanced format
    errorCallback: errorHandler              # Callback when error occurs function(err,notification)
    cacheLength: 100                         # Number of notifications to cache for error purposes
  apnsConnection = new apns.Connection(options)

  iosDevice = new apns.Device(deviceToken)
  note = new apns.Notification()

  note.expiry = Math.floor(Date.now() / 1000) + 3600 # Expires 1 hour from now.
  note.badge = 3
  note.sound = "ping.aiff"
  note.alert = "You have a new message"
  note.payload = {'messageFrom': 'Caroline'}
  note.device = iosDevice

  apnsConnection.sendNotification(note)