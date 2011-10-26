
google.load("visualization", "1", {packages:["corechart"]});
google.setOnLoadCallback(availabilityChart);

function availabilityChart() {

	var latlng = new google.maps.LatLng(51.51251523, -0.133201961);

	var myOptions = {
		zoom: 13,
		center: latlng,
		mapTypeId: google.maps.MapTypeId.ROADMAP
	};
	var map = new google.maps.Map(document.getElementById("map"), myOptions);
	superagent.get('/data/stations', function(res) {
		var stations = JSON.parse(res.text);
		for(i=0; i<stations.length; i++) {
			marker = new google.maps.Marker({
				position: new google.maps.LatLng(stations[i].latitude, stations[i].longitude),
				map: map,
				title: stations[i].name,
				type: "circle",
				stationID: i
			});
			google.maps.event.addListener(marker, 'click', function() {
				selectStation(stations[this.stationID].ID);
			});
		}
	});
}

function selectStation(id) {
	superagent.get('/data/availability/'+id, function(res) {
		var d = JSON.parse(res.text);
		var data = new google.visualization.DataTable();
		data.addColumn('string', 'Time');
		data.addColumn('number', 'Bikes available');
		data.addColumn('number', 'Total');
		for(i=0; i<d.length; i++) {
			data.addRow(
				[new Date(d[i].timestamp * 1000).toTimeString(), d[i].bikesAvailable, d[i].bikesAvailable+d[i].emptySlots]
			);
		}

		var chart = new google.visualization.AreaChart(document.getElementById('chart'));
		chart.draw(data, {width: 900, height: 600, title: 'Bikes Available'});

	});
}
