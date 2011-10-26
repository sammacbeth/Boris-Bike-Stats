
rest = require 'restler'
db = require './datastore'

rest.get('http://borisbikeapi.appspot.com/service/rest/bikestats?format=json').on 'complete', (data) ->
	console.log "Data from: "+ data.updatedOn
	date = new Date()
	data.dockStation.forEach (station) ->
		db.station.create station["@ID"],
			station.name.replace("\n", '').replace(/^\s+|\s+$/g, ''),
			station.latitude,
			station.longitude,
			station.installed == 'true',
			station.locked == 'true',
			station.temporary == 'true',
			(err) ->
				console.log 'Error: '+ error if err?
		db.bikes.create_datapoint station["@ID"], date, station.bikesAvailable, station.emptySlots, (err) ->
			console.log 'Error: '+ error if err?
		true
	true
