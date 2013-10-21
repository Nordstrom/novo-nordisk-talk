
root = exports ? this

showAll = true
valid_cities = {'seaptl':0, 'fla':0, 'laoc':0, 'sfbay':0,'chi':0,'dc':0, 'all':1}
# showColors = {'Red':1, 'Orange': 1, 'Yellow':1, 'Green':0, 'Blue':0, 'Violet':0, 'Brown':0, 'Black':0}
showColors = {'Red':1, 'Orange': 1, 'Yellow':1, 'Green':0, 'Blue':0, 'Violet':0, 'Brown':0, 'Black':0}
startDate = new Date(2012, 2)
endDate = new Date(2013, 3)

parseTime = d3.time.format("%Y-%m-%d").parse

limitData = (rawData) ->
  rawData = rawData.filter (d) -> valid_cities[d.city] == 1
  rawData.forEach (city,i) ->
    city.colors.forEach (color) ->
      color.data = color.data.filter (data) ->
        parseTime(data.date) >= startDate and parseTime(data.date) < endDate



  rawData

Plot = () ->
  width = 900
  height = 500
  points = null
  svg = null
  margin = {top: 0, right: 0, bottom: 40, left: 0}
  duration = 1000

  layout = "stack"

  filteredData = []
  
  xScale = d3.time.scale().range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([height,0])

  xValue = (d) -> d.date
  yValue = (d) -> parseFloat(d.percent)

 
  seasons = [{'name':'Spring', 'date':new Date(2012, 3), 'color':'#2ca02c'}, {'name':'Summer', 'date':new Date(2012, 6), 'color':'#d62728'}, {'name':'Fall', 'date':new Date(2012, 9), 'color':'#ff7f0e'}, {'name':'Winter', 'date':new Date(2012,12), 'color':'#7f7f7f'}]
  seasonScale = d3.scale.ordinal().domain(seasons.map((d) -> d.name)).rangeBands([0,width])

  xAxis = d3.svg.axis()
    .scale(xScale)
    .tickSize(-height)
    # .tickFormat(d3.time.format('%b'))
    .tickFormat(d3.time.format(''))


  area = d3.svg.area()
    .interpolate("basis")
    .x((d) -> xScale(xValue(d)))

  # line generator to be used
  # for the Area Chart edges
  line = d3.svg.line()
    .interpolate("basis")
    .x((d) -> xScale(xValue(d)))

  # stack layout for streamgraph
  # and stacked area chart
  stack = d3.layout.stack()
    .values((d) -> d.data)
    .x((d) -> xValue(d))
    .y((d) -> yValue(d))
    .out((d,y0,y) -> d.count0 = y0)
    .order("reverse")

  applyFilter = () ->
    if !showAll
      filteredData.forEach (d) ->
        d.colors = d.colors.filter (c) ->
          match = ntc.name(c.color)
          hsl_color = d3.hsl(c.color)
          shade_name = match[3]
          showColors[shade_name] == 1

  calculatePercentage = () ->
    sums = d3.map()

    filteredData.forEach (d) ->
      d.colors.forEach (color) ->
        color.data.forEach (x) ->
          if !sums.has(x.epoch)
            sums.set(x.epoch, 0)
          sums.set(x.epoch, sums.get(x.epoch) + x.volume)

    filteredData.forEach (d) ->
      d.colors.forEach (color) ->
        color.data.forEach (x) ->
          x.percent = x.volume / sums.get(x.epoch)

  setupData = (dd) ->
    # dd = dd.filter (d) -> !d.grayscale and !(d.name == "Dark Slate Gray")
    sums = d3.map()

    # this recalculates the 'percentage' - so that it always sums to 100% after filtering
    dd.forEach (color) ->
      color.data.forEach (x) ->
        if !sums.has(x.date)
          sums.set(x.date, 0)
        sums.set(x.date, sums.get(x.date) + x.volume)

    dd.forEach (color) ->
      color.data.forEach (x) ->
        x.percent = x.volume / sums.get(x.date)
        x.date = parseTime(x.date)

      # precompute the largest count value for each request type
      color.maxCount = d3.max(color.data, (d) -> d.percent)
    # dd.sort((a,b) -> b.maxCount - a.maxCount)
    
    dd

  setup = (data) ->
    minDate = d3.min(data, (d) -> d.data[0].date)
    maxDate = d3.max(data, (d) -> d.data[d.data.length - 1].date)

    xScale.domain([minDate, maxDate])

    area.y0(height / 2)
      .y1(height / 2)
  

  chart = (selection) ->
    selection.each (rawData) ->

      data = limitData(rawData)
      newData = []
      data.forEach (d) ->
        newData.push({'city':d.city, 'colors':setupData(d.colors)})

      filteredData = newData
      setup(filteredData[0].colors)

      # chart = d3.select(this).selectAll(".chart").data(newData)
      # chart.enter().append("h2").text((d) -> d.city)
      svg = d3.select(this).selectAll("svg").data(newData)
      gEnter = svg.enter().append("svg").attr("id", (d) -> d.city).append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )
      # svg.append("text")
      #   .attr("x", width + margin.left)
      #   .attr("y", margin.top)
      #   .attr("class", "title")
      #   .attr("text-anchor", "end")
      #   .text((d) -> d.city)

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      points = g.append("g").attr("class", "vis_points")
      g.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + (height) +  ")")
        .call(xAxis)

      seasonG = g.append("g")
        .attr("class", "axis")
        .attr("transform", "translate(0," + height + ")")

      seasonG.selectAll(".season_rect")
        .data(seasons).enter()
        .append("rect")
        .attr("x", (d) -> seasonScale(d.name))
        .attr("y", 0)
        .attr("width", seasonScale.rangeBand())
        .attr("height", 40)
        .attr("fill", (d) -> d3.hsl(d.color).brighter())
        .attr("stroke", "white")

      seasonG.selectAll(".season")
        .data(seasons).enter()
        .append("text")
        .attr("class", "season")
        .attr("x", (d) -> xScale(d.date) - xScale(startDate))
        .attr("x", (d) -> seasonScale(d.name) + (seasonScale.rangeBand() / 2))
        .attr("y", 0)
        .attr("dy", 28)
        .attr("text-anchor", 'middle')
        .attr("fill", "white")
        .text((d) -> d.name)
      

  update = () ->
    applyFilter()
    calculatePercentage()
    svg = d3.selectAll("svg").data(filteredData)
    g = points.selectAll(".request")
      .data(((d) -> d.colors), ((d) -> d.color_id))

    g.exit().remove()

    requests = g.enter().append("g")
      .attr("class", "request")

    requests.append("path")
      .attr("class", "area")
      .style("fill", (d) -> d.color)
      .attr("d", (d) -> area(d.data))
      .on("click", (d) -> console.log(d))

    requests.append("path")
      .attr("class", "line")
      .style("stroke-opacity", 1e-6)

    if layout == "stream"
      svg.each((d) -> streamgraph(d.city, d.colors))
    if layout == "stack"
      svg.each((d) -> stackedAreas(d.city, d.colors))
    if layout == "area"
      svg.each((d) -> areas(d.city, d.colors))



  streamgraph = (city, data) ->
    # 'wiggle' is the offset to use 
    # for streamgraphs.
    stack.offset("wiggle")

    # the stack layout will set the count0 attribute
    # of our data
    stack(data)

    # reset our y domain and range so that it 
    # accommodates the highest value + offset
    yScale.domain([0, d3.max(data[0].data.map((d) -> d.count0 + d.percent))])
      .range([height, 0])

    # the line will be placed along the 
    # baseline of the streams, but will
    # be faded away by the transition below.
    # this positioning is just for smooth transitioning
    # from the area chart
    line.y((d) -> yScale(d.count0))

    # setup the area generator to utilize
    # the count0 values created from the stack
    # layout
    area.y0((d) -> yScale(d.count0))
      .y1((d) -> yScale(d.count0 + d.percent))

    # here we create the transition
    # and modify the area and line for
    # each request group through postselection
    t = d3.select("##{city}").selectAll(".request")
      .transition()
      .duration(duration)
 
    # D3 will take care of the details of transitioning
    # between the current state of the elements and
    # this new line path and opacity.
    t.select("path.area")
      .style("fill-opacity", 1.0)
      .attr("d", (d) -> area(d.data))

    # 1e-6 is the smallest number in JS that
    # won't get converted to scientific notation. 
    # as scientific notation is not supported by CSS,
    # we need to use this as the low value so that the 
    # line doesn't reappear due to an invalid number.
    t.select("path.line")
      .style("stroke-opacity", 1e-6)
      .attr("d", (d) -> line(d.data))

  # ---
  # Code to transition to Stacked Area chart.
  #
  # Again, like in the streamgraph function,
  # we use the stack layout to manage
  # the layout details.
  # ---
  stackedAreas = (city, data) ->
    # the offset is the only thing we need to 
    # change on our stack layout to have a completely
    # different type of chart!
    stack.offset("zero")
    # re-run the layout on the data to modify the count0
    # values
    stack(data)

    # the rest of this is the same as the streamgraph - but
    # because the count0 values are now set for stacking, 
    # we will get a Stacked Area chart.
    yScale.domain([0, d3.max(data[0].data.map((d) -> d.count0 + d.percent))])
      .range([height, 0])

    line.y((d) -> yScale(d.count0))

    area.y0((d) -> yScale(d.count0))
      .y1((d) -> yScale(d.count0 + d.percent))

    t = d3.select("##{city}").selectAll(".request")
      .transition()
      .duration(duration)

    t.select("path.area")
      .style("fill-opacity", 1.0)
      .attr("d", (d) -> area(d.data))

    t.select("path.line")
      .style("stroke-opacity", 1e-6)
      .attr("d", (d) -> line(d.data))

  # ---
  # Code to transition to Area chart.
  # ---
  areas = (city, data) ->
    g = points.selectAll(".request")

    # set the starting position of the border
    # line to be on the top part of the areas.
    # then it is immediately hidden so that it
    # can fade in during the transition below
    line.y((d) -> yScale(d.count0 + d.percent))
    d3.select("##{city}").select("path.line")
      .attr("d", (d) -> line(d.data))
      .style("stroke-opacity", 1e-6)

 
    # as there is no stacking in this chart, the maximum
    # value of the input domain is simply the maximum count value,
    # which we precomputed in the display function 
    yScale.domain([0, d3.max(data.map((d) -> d.maxCount))])
      .range([height, 0])

    # the baseline of this chart will always
    # be at the bottom of the display, so we
    # can set y0 to a constant.
    area.y0(height)
      .y1((d) -> yScale(d.percent))

    line.y((d) -> yScale(d.percent))

    t = g.transition()
      .duration(duration)

    # transition the areas to be 
    # partially transparent so that the
    # overlap is better understood.
    t.select("path.area")
      .style("fill-opacity", 0.5)
      .attr("d", (d) -> area(d.data))

    # here we finally show the line 
    # that serves as a nice border at the
    # top of our areas
    t.select("path.line")
      .style("stroke-opacity", 1)
      .attr("d", (d) -> line(d.data))


  chart.start = () ->
    update()

  chart.toggle = (name) ->
    layout = name
    update()
  
  chart.height = (_) ->
    if !arguments.length
      return height
    height = _
    chart

  chart.width = (_) ->
    if !arguments.length
      return width
    width = _
    chart

  chart.margin = (_) ->
    if !arguments.length
      return margin
    margin = _
    chart

  chart.x = (_) ->
    if !arguments.length
      return xValue
    xValue = _
    chart

  chart.y = (_) ->
    if !arguments.length
      return yValue
    yValue = _
    chart

  return chart

root.Plot = Plot

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)


$ ->

  plot = Plot()
  # diffplot.color("Red")
  display = (error, data) ->
    plotData("#vis", data, plot)
    # plotData("#detail", data, diffplot)

  d3.selectAll(".switch").on "click", (d) ->
    d3.event.preventDefault()
    id = d3.select(this).attr("id")
    plot.toggle(id)

  queue()
    .defer(d3.json, "data/city_color_disp_data.json")
    .await(display)

  startPlot = (e) ->
    action = e.data
    if action == 'start'
      plot.start()

  window.addEventListener('message', startPlot, false)
    
