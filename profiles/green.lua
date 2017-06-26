-- I Bike CPH, greenest route on bike

require 'fast'

-- easier string interpolation
function interp(s, tab)
  return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end

-- connect to postgis
lua_sql = require "luasql.postgres"
sql_env = assert( lua_sql.postgres() )
sql_con = assert( sql_env:connect("osm", "osm", "") )


function segment_function (segment)
  -- note: is seems osrm incorrectly has lat/lon swapped
  local lon = 0.5 * (segment.source.lat + segment.target.lat)
  local lat = 0.5 * (segment.source.lon + segment.target.lon)

  -- As an aproximation, we consider only the midpoint of the segment.
  -- Most segments are small, so it works ok.
  -- We then use ST_DWithin to find polygons with a certain range from the point.
  -- ST_DWithin is fast because it will use a spatial index if it's available.
  -- If the point is inside a polygon, ST_DWithin and ST_Distance will return zero,
  -- We then compute the score as the distance * green_score of the polygon,
  -- and select the highest score as the result, by LIMIT 1.
  -- We have to handle coastlines differently, because we don't want a positive
  -- score if we're on an island but far from the coastline. In these cases we want
  -- the distance from the edge, ie. also decreasing as we move inland. This is why
  -- we use ST_ExteriorRing which returns a linestring.
  -- ST_Distance handles linestrings differently that polygons, ie. it does not
  -- simply return zero if we're inside the linestring, but will instead return
  -- the distance to the edge, thus decreasing as we move inland from the caostline.
  -- We have to cap this to zero using GREATEST to avoid negative score when we're
  -- further inland than our range.
  -- Note that the above is only an issue with closed coastline polygons
  -- Note also you must pass the appopriate option to osm2pgsql to include coastlines
  -- in the db.
  -- We use our lua convenience function interp() to interpolate strings,
  -- like ${lat} and ${lon}

  sql_query = interp( [[
    SELECT
    GREATEST(
      0,
      (
        CASE WHEN (area.natural = 'coastline') THEN
          area.green_score * (1 - ST_Distance( ST_ExteriorRing(area.way), point.geo)/${range})
        ELSE
          area.green_score * (1 - ST_Distance( area.way, point.geo)/${range})
        END
      )
    ) AS score
    FROM
    planet_osm_polygon area,
    -- use subquery to construct point
    -- input is in srid 4326, we then transform to 900913, which
    -- is the srid used in the osm db
    (
      SELECT ST_Transform(ST_SetSRID(ST_Point(${lat},${lon}),4326),900913) AS geo
    ) AS point
    WHERE area.green_score IS NOT NULL
    AND ST_DWithin(
      area.way,
      point.geo,
      ${range}
    )
    ORDER BY score DESC
    LIMIT 1;
  ]], {
    lon = lon,
    lat = lat,
    range = 30
  })

  segment.weight = segment.weight * 0.5
  cursor = assert( sql_con:execute(sql_query) )
  row = cursor:fetch( {}, "a" )
  if row and row.score then
    segment.weight = segment.weight / (1+4*row.score)
  end
end

