db = require('./mongo').db;

# shorthand access to collections
c =
	s: db.collection("station")
	b: db.collection("bikes")

exports.station =
	# create/update a station entry
	create: (id, name, latitude, longitude, installed, locked, temporary, cb = noop) ->
		s =
			_id: (Number) id
			name: name
			latitude: (Number) latitude
			longitude: (Number) longitude
			installed: installed
			locked: locked
			temporary: temporary
		c.s.save(s, {safe: true}, cb)
		true
	# get a station by it's id
	get: (id, cb = noop) ->
		db.collection("station").findOne({_id: (Number) id}, cb)
		true
	# get all stations
	get_all: (cb) ->
		c.s.find().toArray cb

exports.bikes =
	# create a datapoint for a bike station
	create_datapoint: (stationID, time, bikesAvailable, emptySlots, cb = noop) ->
		if not stationID? or not time? or not bikesAvailable? or not emptySlots?
			cb("Missing data") if cb?
			false
		else
			[date, slice] = get_timeslice time
			c.b.insert(
				stationID: (Number) stationID
				date: date
				time: slice
				bikesAvailable: (Number) bikesAvailable
				emptySlots: (Number) emptySlots,
				{safe: true},
				cb
			);
			true

# noop. Used in case caller doesn't provide a callback to make
# sure the mongo library doesn't complain
noop = (err) ->
	console.log "in Noop: "+err if err?

# get the timeslice for a given Date object.
get_timeslice = (time) ->
	date = time.getDate() + (time.getMonth()+1)*100 + time.getFullYear()*10000
	t_slice = time.getHours() * 4 + Math.floor(time.getMinutes() / 15)
	[date, t_slice]

# set up indices
c.s.ensureIndex('latitude', noop)
c.s.ensureIndex('longitude', noop)
c.s.ensureIndex('installed', noop)
c.s.ensureIndex('locked', noop)
c.s.ensureIndex('temporary', noop)

c.b.ensureIndex('stationID', noop)
c.b.ensureIndex('date', noop)
c.b.ensureIndex('time', noop)
