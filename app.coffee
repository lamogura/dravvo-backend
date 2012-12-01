express = require('express')
sys = require('util')

app = express()

app.configure -> 
	app.use(express.bodyParser())

app.get '/', (req, res) ->
    res.send('Hello from Dravvo')

app.post '/addmsg', (req, res) ->
	#console.log(sys.inspect(req))
	res.send("ok, i added #{req.body} to the db.")

app.listen(process.env.VCAP_APP_PORT || 3000)

console.log("listening on port 3000")