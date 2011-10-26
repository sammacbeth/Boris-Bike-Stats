
express = require 'express'
app = express.createServer()
ds = require './datastore'

app.set("view options", { layout: false })
app.use(express.static(__dirname + '/client'))

log_request = (req) ->
	console.log "#{req.route.method} #{req.route.path} (#{req.connection.remoteAddress})"

bind_data_uri = (url, dataFn) ->
	app.get url, (req, res) ->
		log_request req
		dataFn req, (err, data) ->
			if err?
				res.send JSON.stringify(error: err)
				false
			else
				res.send JSON.stringify(data)

bind_data_uri '/data/stations', (req, cb) ->
	ds.station.get_all (err, stations) ->
		cb err, stations

bind_data_uri '/data/station/:id', (req, cb) ->
	ds.station.get req.params.id, (err, station) ->
		cb err, station

app.listen 3000
