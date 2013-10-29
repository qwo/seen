# ## Shapes
# #### Shape primitives and shape-making methods
# ------------------

seen.Shapes = {
  _cubeCoordinateMap : [
    [0,1,3,2] # left
    [5,4,6,7] # right
    [1,0,4,5] # bottom
    [2,3,7,6] # top
    [3,1,5,7] # front
    [0,2,6,4] # back
  ]

  _mapPointsToSurfaces: (points, coordinateMap) ->
    surfaces = []
    for coords in coordinateMap
      spts = (points[c].copy() for c in coords)
      surfaces.push(new seen.Surface(spts))
    return surfaces

  cube: =>
    points = [
      seen.P(-1, -1, -1)
      seen.P(-1, -1,  1)
      seen.P(-1,  1, -1)
      seen.P(-1,  1,  1)
      seen.P( 1, -1, -1)
      seen.P( 1, -1,  1)
      seen.P( 1,  1, -1)
      seen.P( 1,  1,  1)
    ]

    return new seen.Shape('cube', seen.Shapes._mapPointsToSurfaces(points, seen.Shapes._cubeCoordinateMap))

  unitcube: =>
    points = [
      seen.P(0, 0, 0)
      seen.P(0, 0, 1)
      seen.P(0, 1, 0)
      seen.P(0, 1, 1)
      seen.P(1, 0, 0)
      seen.P(1, 0, 1)
      seen.P(1, 1, 0)
      seen.P(1, 1, 1)
    ]

    return new seen.Shape('unitcube', seen.Shapes._mapPointsToSurfaces(points, seen.Shapes._cubeCoordinateMap))


  rectangle : (point1, point2) =>
    compose = (x, y, z) ->
      return seen.P(
        x(point1.x, point2.x)
        y(point1.y, point2.y)
        z(point1.z, point2.z)
      )

    points = [
      compose(Math.min, Math.min, Math.min)
      compose(Math.min, Math.min, Math.max)
      compose(Math.min, Math.max, Math.min)
      compose(Math.min, Math.max, Math.max)
      compose(Math.max, Math.min, Math.min)
      compose(Math.max, Math.min, Math.max)
      compose(Math.max, Math.max, Math.min)
      compose(Math.max, Math.max, Math.max)
    ]

    return new seen.Shape('rect', seen.Shapes._mapPointsToSurfaces(points, seen.Shapes._cubeCoordinateMap))

  tetrahedron: =>
    points = [
      seen.P( 1,  1,  1)
      seen.P(-1, -1,  1)
      seen.P(-1,  1, -1)
      seen.P( 1, -1, -1)]

    coordinateMap = [
      [0,2,1]
      [0,1,3]
      [3,2,0]
      [1,2,3]]

    return new seen.Shape('tetrahedron', seen.Shapes._mapPointsToSurfaces(points, coordinateMap))

  icosahedron : ->
    X = 0.525731112119133606
    Z = 0.850650808352039932

    points = [
      seen.P(-X, 0.0, -Z)
      seen.P(X, 0.0, -Z)
      seen.P(-X, 0.0, Z)
      seen.P(X, 0.0, Z)
      seen.P(0.0, Z, -X)
      seen.P(0.0, Z, X)
      seen.P(0.0, -Z, -X)
      seen.P(0.0, -Z, X)
      seen.P(Z, X, 0.0)
      seen.P(-Z, X, 0.0)
      seen.P(Z, -X, 0.0)
      seen.P(-Z, -X, 0.0)
    ]

    coordinateMap = [
       [0,4,1]
       [0,9,4]
       [9,5,4]
       [4,5,8]
       [4,8,1]
       [8,10,1]
       [8,3,10]
       [5,3,8]
       [5,2,3]
       [2,7,3]
       [7,10,3]
       [7,6,10]
       [7,11,6]
       [11,0,6]
       [0,1,6]
       [6,1,10]
       [9,0,11]
       [9,11,2]
       [9,2,5]
       [7,2,11]
    ]

    return new seen.Shape('icosahedron', seen.Shapes._mapPointsToSurfaces(points, coordinateMap))

  text: (text) ->
    surface = new seen.Surface([
      seen.P(0,  0, 0)
      seen.P(20, 0, 0)
      seen.P(0, 20, 0)
    ], seen.Painters.text)
    surface.text = text
    return new seen.Shape('text', [surface])

  extrude : (points, distance = 1) ->
    surfaces = []
    front = new seen.Surface (p.copy() for p in points)
    back  = new seen.Surface (p.translate(0,0,distance) for p in points)

    for i in [1...points.length]
      surfaces.push new seen.Surface [
        front.points[i - 1].copy()
        back.points[i - 1].copy()
        back.points[i].copy()
        front.points[i].copy()
      ]

    len = points.length
    surfaces.push new seen.Surface [
      front.points[len - 1].copy()
      back.points[len - 1].copy()
      back.points[0].copy()
      front.points[0].copy()
    ]

    back.points.reverse()
    surfaces.push front
    surfaces.push back
    return new seen.Shape('extrusion', surfaces)

  arrow : (thickness = 1, tailLength = 1, tailWidth = 1, headLength = 1, headPointiness = 0) ->
    htw = tailWidth/2
    points = [
      seen.P(0, 0, 0)
      seen.P(headLength + headPointiness, 1, 0)
      seen.P(headLength, htw, 0)
      seen.P(headLength + tailLength, htw, 0)
      seen.P(headLength + tailLength, -htw, 0)
      seen.P(headLength, -htw, 0)
      seen.P(headLength + headPointiness, -1, 0)
    ]
    return seen.Shapes.extrude(points, thickness)

  path : (points) ->
    return new seen.Shape('path', [new seen.Surface(points)])

  custom: (s) ->
    surfaces = []
    for f in s.surfaces
      surfaces.push new seen.Surface((seen.P(p...) for p in f))
    return new seen.Shape('custom', surfaces)
}
