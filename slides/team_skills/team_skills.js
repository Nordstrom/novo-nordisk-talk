var margin = {
  top: 20,
  right: 160,
  bottom: 30,
  left: 0
},
  width = 960 - margin.left - margin.right,
  height = 500 - margin.top - margin.bottom;

var x = d3.scale.ordinal()
  .rangeRoundBands([0, width], .1);

var y = d3.scale.linear()
  .rangeRound([height, 0]);

var color = d3.scale.ordinal()
  .range(["#D53E4F", "#FC8D59", "#FEE08B", "#E6F598", "#99D594", "#3288BD"]);
  // .range(["#FFFFD4", "#FEE391", "#FEC44F", "#FE9929", "#D95F0E", "#993404"]);
  // .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);

var xAxis = d3.svg.axis()
  .scale(x)
  .orient("bottom");

var svg = d3.select("#chart").append("svg")
  .attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom)
  .append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

d3.csv("data.csv", function(error, data) {
  color.domain(d3.keys(data[0]).filter(function(key) {
    return key !== "TeamMember";
  }));

  data.forEach(function(d) {
    var y0 = 0;
    d.skills = color.domain().map(function(name) {
      return {
        name: name,
        y0: y0,
        y1: y0 += +d[name]
      };
    });
    d.skills.forEach(function(d) {
      d.y0 /= y0;
      d.y1 /= y0;
    });
  });

  data.sort(function(a, b) {
    return b.skills[0].y1 - a.skills[0].y1;
  });

  x.domain(data.map(function(d) {
    return d.TeamMember;
  }));

  svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis);

  var teamMember = svg.selectAll(".teamMember")
    .data(data)
    .enter().append("g")
    .attr("class", "teamMember")
    .attr("transform", function(d) {
      return "translate(" + x(d.TeamMember) + ",0)";
    });

  teamMember.selectAll("rect")
    .data(function(d) {
      return d.skills;
    })
    .enter().append("rect")
    .attr("width", x.rangeBand())
    .attr("y", function(d) {
      return y(d.y1);
    })
    .attr("height", function(d) {
      return y(d.y0) - y(d.y1);
    })
    .style("fill", function(d) {
      return color(d.name);
    });

  var legend = svg.select(".teamMember:last-child").selectAll(".legend")
    .data(function(d) {
      return d.skills;
    })
    .enter().append("g")
    .attr("class", "legend")
    .attr("transform", function(d) {
      return "translate(" + (x.rangeBand() - 10) + "," + y((d.y0 + d.y1) / 2) + ")";
    });

  legend.append("line")
    .attr("x2", 10);

  legend.append("text")
    .attr("x", 13)
    .attr("dy", ".35em")
    .text(function(d) {
      return d.name;
    });

});
