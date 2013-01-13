apns = require 'apn'
util = require 'util'
path = require 'path' 

errorHandler = (err, notification) ->
  console.log "Error sending APNS notification"
  console.log util.inspect(err)
  console.log util.inspect(notification)

module.exports.registerDevice = (req, res) ->
  res.end "Not yet implemented"

module.exports.testSend = (req, res) ->
  console.log "#{req.method} to '#{req.url}' with body: #{util.inspect(req.body)}'"

  deviceToken = req.body.deviceToken
  console.log "Attempting to send APNS to DeviceWithToken: #{deviceToken}"

  options =
    cert: 'apns-prod-cert.pem'                # Certificate file path
    certData: null                            # String or Buffer containing certificate data, if supplied uses this instead of cert file path
    key:  'apns-prod-key.pem'                 # Key file path
    keyData: null                             # String or Buffer containing key data, as certData
    passphrase: "ferasdf"                     # A passphrase for the Key file
    ca: null                                  # String or Buffer of CA data to use for the TLS connection
    pfx: null                                 # File path for private key, certificate and CA certs in PFX or PKCS12 format. If supplied will be used instead of certificate and key above
    pfxData: null                             # PFX or PKCS12 format data containing the private key, certificate and CA certs. If supplied will be used instead of loading from disk.
    gateway: 'gateway.sandbox.push.apple.com' # gateway address, "gateway.sandbox.push.apple.com" for dev, "gateway.push.apple.com" for production
    port: 2195                                # gateway port
    rejectUnauthorized: true                  # Value of rejectUnauthorized property to be passed through to tls.connect()
    enhanced: true                            # enable enhanced format
    errorCallback: errorHandler                # Callback when error occurs function(err,notification)
    cacheLength: 100                          # Number of notifications to cache for error purposes
    autoAdjustCache: true                     # Whether the cache should grow in response to messages being lost after errors.
    connectionTimeout: 0                      # The duration the socket should stay alive with no activity in milliseconds. 0 = Disabled.
    
  apnsConnection = new apns.Connection(options)
  iosDevice = new apns.Device(deviceToken)

  note = new apns.Notification();
  note.expiry = Math.floor(Date.now() / 1000) + 3600 # Expires 1 hour from now.
  note.badge = 2
  note.sound = "ping.aiff"
  note.alert = req.body.message
  note.payload = {'messageFrom': 'Caroline'}
  note.device = iosDevice

  apnsConnection.sendNotification(note)

  json_response = JSON.stringify {result: "Notification given to Dravvo server to send to APNS."}
  res.writeHead 200, {"Content-Type": "application/json"}
  res.end json_response
