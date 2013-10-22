
root = exports ? this

parseTime = d3.time.format("%H%M").parse

WorldPlot = () ->
  width = 960
  height = 650
  radius = 240
  origin = [-71, 42]
  rotate = [100,-45]
  velocity = [.013, 0.000]
  time = Date.now()
  data = []

  lastSec = 0

  allData = []
  g = null
  points = null
  feature = null
  cities = null
  startTime = null
  endTime  = null

  minRadius = 0
  maxRadius = 100

  rScale = d3.scale.sqrt().range([minRadius, maxRadius]).domain([0, 200])
  

  mworld = null
  mstores = null
  locations = {}

  projection = d3.geo.azimuthalEqualArea()
    # .scale(radius)
    .rotate([100, -45])
    .scale(1050)
    .translate([width / 2 - 40, height / 2 - 110])
    # .clipAngle(90 + 1e-6)
    # .precision(.1)

  path = d3.geo.path()
    .projection(projection)
    # .pointRadius(1.5)

  graticule = d3.geo.graticule()
    .extent([[-140, 20], [-60, 60]])
    .step([2, 2])

  # redraw = () ->
  #   dt = Date.now() - time
  #   projection.rotate([rotate[0] + velocity[0] * dt, rotate[1] + velocity[1] * dt])
  #   feature.attr("d", path)
  #   points.selectAll(".symbol").attr("d", path)
  #   
  #   false

  updateCities = () ->
    c = cities.selectAll(".city")
      .data(d3.values(locations))

    c.enter()
      .append("circle")
      .attr("class", "city")
      # .attr("r", (d) -> rScale(d.count))
      .attr("r", (d) -> 0)
      .attr("cx", (d,i) -> projection([d.lng, d.lat])[0])
      .attr("cy", (d,i) -> projection([d.lng, d.lat])[1])

    c.transition()
      .duration(900)
      # .delay((d,i) -> 60 * i)
      .attr("r", (d) -> rScale(d.count))
      
  addData = (timediff) ->
    if (timediff - lastSec) < 1000
      return false
    else
      lastSec = timediff
    console.log(timediff)
    rtn = false
    # console.log(startTime)
    # randomStore = d3.values(locations)[Math.floor(Math.random() * d3.values(locations).length)]
    # lat = randomStore.lat
    # lon = randomStore.lng
    # data.push({"type":"Feature", "id":i, "geometry":{"type":"Point", "coordinates":[lon,lat]},"properties":{'time':Date.now()}})
    # randomStore.count += 1

    data = allData.filter (d) ->
      d.properties.time < startTime

    allData = allData.filter (d) ->
      d.properties.time >= startTime

    startTime.setMinutes(startTime.getMinutes() + 1)

    if startTime > endTime
      rtn = true

    # console.log(data.length)
    data.forEach (d) ->
      if locations[d.properties.store_num]
        locations[d.properties.store_num].count += 1

    p = points.selectAll(".symbol")
      .data(data, (d) -> d.id)

    # p.enter().append("path")
    #   .attr("class", "symbol")
    #   .attr("d", path.pointRadius((d,i) -> 3))

    temps = p.enter().append("circle")
      .attr("class", "temp_symbol")
      .attr("cx", (d,i) -> projection([d.geometry.coordinates[0], d.geometry.coordinates[1]])[0])
      .attr("cy", (d,i) -> projection([d.geometry.coordinates[0], d.geometry.coordinates[1]])[1])
      .attr("r", 0)
      .attr("stroke-opacity", 1)

    temps.transition()
      .duration(600)
      .delay((d,i) -> i * 60)
      .attr("r", 80)
      .attr("cx", (d,i) -> projection([d.geometry.coordinates[0], d.geometry.coordinates[1]])[0])
      .attr("cy", (d,i) -> projection([d.geometry.coordinates[0], d.geometry.coordinates[1]])[1])
      .attr("stroke-opacity", 0.2)
      .remove()
      

    p.exit().remove()
    updateCities()

    rtn

  parseStores = (stores) ->
    locs = {}
    stores.forEach (s) ->
      locs[s.store] = s
      locs[s.store].count = 0
    locs

  parseData = (rawData) ->
    geoData = []
    rawData.forEach (d) ->
      d.date = parseTime(d.hh_mm)
      d.id = d.store_num + "_" + d.style_id + "_" + d.hh_mm
      store = locations[d.store_num]
      if !store
        console.log('no store for ' + d.store_num)
        store = d3.values(locations)[25]
      g = {"type":"Feature", "id":d.id, "geometry":{"type":"Point", "coordinates":[store.lng,store.lat]},"properties":{'time':d.date, 'store_num':d.store_num, 'name':d.name,'img_url':d.img_url, 'store':store}}
      geoData.push(g)
    startTime = rawData[0].date
    endTime = rawData[rawData.length - 1].date
    geoData


  chart = (selection) ->
    selection.each (rawData) ->

      locations = parseStores(mstores)

      allData = parseData(rawData)

      # rawData = rawData.filter((d) -> d.country ).filter (d) -> +d.count > 5

      # data = rawData

      # console.log(data)

      # count_extent = d3.extent(data, (d) -> +d.count)
      # radius.domain(count_extent)
      # console.log(count_extent)

      svg = d3.select(this).selectAll("svg").data([[1,2,3]])
      svg.enter().append("svg")

      svg
        .attr("width", width)
        .attr("height", height)

      # svg.append("defs").append("path")
      #   .datum({type: "Sphere"})
      #   .attr("id", "sphere")
      #   .attr("d", path)

      svg.append("use")
        .attr("class", "stroke")
        .attr("xlink:href", "#sphere")

      svg.append("use")
        .attr("class", "fill")
        .attr("xlink:href", "#sphere")

      g = svg.append("g")

      g.append("rect")
        .attr("class", "cover")
        .attr("width", width)
        .attr("height", height)


      g.append("path")
        .datum(topojson.feature(mworld, mworld.objects.land))
        .attr("class", "land")
        .attr("d", path)

      g.append("path")
        .datum(graticule)
        .attr("class", "graticule")
        .attr("d", path)
      # g.insert("path", ".graticule")
      #   .datum(topojson.mesh(mworld, mworld.objects.countries, (a, b) -> a != b))
      #   .attr("class", "boundary")
      #   .attr("d", path)

      feature = svg.selectAll("path")

      # d3.timer(redraw)


      
      # g = svg.select("g")

      cities = g.append("g").attr("id", "vis_cities")
      points = g.append("g").attr("id", "vis_points")


  chart.start = () ->
    d3.timer(addData, 200)

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


  chart.world = (_) ->
    if !arguments.length
      return mworld
    mworld = _
    chart

  chart.stores = (_) ->
    if !arguments.length
      return stores
    mstores = _
    chart

  return chart

# root.WorldPlot = WorldPlot

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)

$ ->

  worldplot = WorldPlot()

  display = (error, world, stores, data) ->
    console.log(error)

    worldplot.world(world)
    worldplot.stores(stores)
    plotData("#vis", data, worldplot)
    worldplot.start()


  queue()
    .defer(d3.json, "data/us.json")
    .defer(d3.json, "data/stores.json")
    .defer(d3.tsv, "data/transaction_map.tsv")
    .await(display)

  # function that is executed once a message is sent.
  # Here, we check the content of the message - to ensure
  # it is what we expect. 
  #
  # We could use the event's .data attribute to allow for
  # multiple sub-steps to be sent to the content of an iframe
  startPlot = (e) ->
    action = e.data
    if action == 'start'
      worldplot.start()

  # listen for postMessage() messages 
  window.addEventListener('message', startPlot, false)
