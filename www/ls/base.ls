

yearsOld = [1945 to 2003]
dataOld = ig.data.znacky_2004

yearsNew = [1945 to 2013]
  ..unshift "stare"
dataNew = ig.data.znacky
yearWidth = 11
rectSize = 9
rectFullSize = rectSize + 1
znackaHeight = 200
rectCapacity = 5000
znacky_assoc = {}
znacky = d3.tsv.parse dataNew, (row) ->
  data = name: row.znacka
  data.sum = 0
  data.yearMax = -Infinity
  data.years = for year in yearsNew
    cars = parseInt row[year], 10
    data.sum += cars
    if data.yearMax < cars
      data.yearMax = cars
    cars
  data.height = Math.ceil data.yearMax / rectCapacity * rectFullSize
  data.height++ if data.height % 2
  data.height = 40 if data.height < 40
  znacky_assoc[data.name] = data
  data

d3.tsv.parse dataOld, (row) ->
  data = name: row.znacka
  data.sum = 0
  data.yearMax = -Infinity
  data.years = for year in yearsOld
    cars = parseInt row[year], 10
    data.sum += cars
    if data.yearMax < cars
      data.yearMax = cars
    cars
  data.height = Math.ceil data.yearMax / rectCapacity * rectFullSize
  data.height++ if data.height % 2
  data.height = 40 if data.height < 40
  if znacky_assoc[data.name]
    znacky_assoc[data.name].old = data
  data

znacky.sort (a, b) -> b.sum - a.sum
# znacky.length = 1

container = d3.select ig.containers.base
list = container.append \ul .attr \class \list
  ..selectAll \li.item .data znacky
    ..enter!append \li
      ..append \span
        ..attr \class \name
        ..html (.name)
        ..style \line-height -> "#{(it.height + (it.old?height || 0)) + 40}px"
      ..append \div
        ..attr \class "canvas-container new"
        ..style \height -> "#{it.height}px"
        ..append \span
          ..attr \class \year-label
          ..html "2014"
          ..style \font-size -> "#{it.height * 0.4}px"
          ..style \line-height -> "#{it.height + 20}px"
        ..append \canvas
          ..attr \class \new
          ..attr \height -> it.height
          ..attr \width 880
    ..filter (-> it.old)
      ..append \div
        ..attr \class "canvas-container old"
        ..style \height -> "#{it.old.height}px"
        ..append \span
          ..attr \class \year-label
          ..html "2004"
          ..style \font-size -> "#{it.height * 0.4}px"
          ..style \line-height -> "#{it.old.height + 20}px"
        ..append \canvas
          ..attr \class \old
          ..attr \height -> it.old.height
          ..attr \width 880

canvases = list.selectAll \canvas
  ..each (znacka) ->
    isOld = @className == \old
    color = isOld && '#acb5be' || '#003366'
    ctx = @getContext \2d
      ..strokeStyle = color
      ..fillStyle = color
    {years, height:canvasHeight} = isOld && znacka.old || znacka
    leftOffsetFromOld = isOld && 11 || 0
    for year, yearIndex in years
      rects = Math.floor year / 5000
      remainder = year % 5000
      lines = 0
      twinLines = 0
      if rects
        twinLines = Math.floor remainder / 2000
      else
        lines = Math.floor remainder / 1000
      remainder = remainder % 2000
      height = rects * rectFullSize
      leftOffset = yearWidth * (yearIndex + leftOffsetFromOld)
      topOffset = (canvasHeight - height) / 2
      for i in [0 til rects]
        ctx.fillRect do
          leftOffset
          topOffset + i * rectFullSize
          rectSize
          rectSize
      if lines == 1 or lines == 3
        topOffset += 1
      for i in [0 til lines]
        ii = Math.floor i / 2
        if i % 2 == 0
          d = -1.5
          top = topOffset - (ii) * 2
        else
          d = 0.5
          top = topOffset + height + (ii) * 2
        ctx.moveTo leftOffset, top + d
        ctx.lineTo leftOffset + rectSize, top + d
      for i in [0 til twinLines]
        topTop = topOffset - (i * 2)
        topBottom = topOffset + height + (i * 2)

        ctx.moveTo leftOffset, topTop - 1.5
        ctx.lineTo leftOffset + rectSize, topTop - 1.5

        ctx.moveTo leftOffset, topBottom + + 0.5
        ctx.lineTo leftOffset + rectSize, topBottom + + 0.5

      if rects == lines == 0
        width = Math.round year / 1000 * rectSize
        if width
          ctx.moveTo leftOffset + rectSize / 2 - width / 2, topOffset - 0.5
          ctx.lineTo leftOffset + rectSize / 2 + width / 2, topOffset - 0.5


    ctx.stroke!
