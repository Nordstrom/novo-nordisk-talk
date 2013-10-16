
d3.tsv("data.csv", function(error, data) {
	console.log("Let's look at the data");
  // color.domain(d3.keys(data[0]).filter(function(key) { return key !== "date"; }));
  // Get all the distinct colors

	// avg: "0.000381119578378275"
	// color_id: "33"
	// month_epoch: "1367366400"
	// name: "Azure"
	// rgb: "{240,255,255}"

	// Convert some attribute values to numerics
	_.each(data, function(row) {
		row.color_id = parseInt(row.color_id);
		row.month_epoch = parseInt(row.month_epoch);
		row.percent = parseFloat(row.percent);
	});

	// Pass true as the isSorted argument for improved speed.
  var uniqueColors = _.uniq(_.map(data, function(d) { return d.color_id}), true);
  var uniqueTimeSeries = _.uniq(_.map(data, function(d) { return d.month_epoch; }), true);
  var series = [];
  var minValue = Number.MAX_VALUE, maxValue = Number.MIN_VALUE;

  _.each(uniqueColors, function(c) {
  	var colorRows = _.filter(data, function(row) { return row.color_id == c; });
  	var seriesData = _.map(colorRows, function(row) { return {x: row.month_epoch, y: row.percent }});

  	// If there are fewer rows in this series than the complete series, fill it in with the missing values
  	if (seriesData.length < uniqueTimeSeries.length) {
  		var missingDataPoints = _.map(_.difference(_.pluck(colorRows, "month_epoch"), uniqueTimeSeries), function(month_epoch) {
  			return { x: month_epoch, y: 0.0 }
  		});
  		seriesData = seriesData.concat(missingDataPoints);
  		_.sortBy(seriesData, 'x');
  	}

  	var hexColor = rgbToHex.apply(this, _.map(colorRows[0].rgb.substr(1, colorRows[0].rgb.length - 2).split(','), function(v) {
			return parseInt(v);
		}));

		minValue = Math.min(minValue, _.min(seriesData, "y").y);
		maxValue = Math.max(maxValue, _.max(seriesData, "y").y);

 		series.push({
 			color: hexColor,
 			data: seriesData,
 			name: colorRows[0].name
 		});
  });

	var logScale = d3.scale.log().domain([minValue/6, maxValue]);

	_.each(series, function(s) {
		s.scale = logScale
	});

  var graph = new Rickshaw.Graph( {
		element: document.getElementById("chart"),
		renderer: 'line',
		tension: 0.6,
		series: series
	});

	graph.render();

	// var legend = new Rickshaw.Graph.Legend( {
	// 	graph: graph,
	// 	element: document.getElementById('legend')
	// });

	// var shelving = new Rickshaw.Graph.Behavior.Series.Toggle( {
	// 	graph: graph,
	// 	legend: legend
	// });

	var axes = new Rickshaw.Graph.Axis.Time({
		graph: graph
	});

	new Rickshaw.Graph.Axis.Y.Scaled( {
	  graph: graph,
	  orientation: 'left',
	  tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
	  element: document.getElementById('y_axis'),
	  scale: logScale,
	  grid: true
	});

	axes.render();

 	new Rickshaw.Graph.HoverDetail({ graph: graph });
});

function componentToHex(c) {
    var hex = c.toString(16);
    return hex.length == 1 ? "0" + hex : hex;
}

function rgbToHex(r, g, b) {
    return "#" + componentToHex(r) + componentToHex(g) + componentToHex(b);
}