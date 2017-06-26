-- I Bike CPH, best routes for cargo bikes
-- based on fastest bicycle profile, with some modifications
profile = require 'fast'
local find_access_tag = require("lib/access").find_access_tag

local default_speed = 10
local walking_speed = 4

profile.default_speed                   = default_speed
profile.barrier_whitelist.cycle_barrier = nil

profile.turn_penalty  = 10

profile.bicycle_speeds = {
  cycleway = default_speed,
  primary = default_speed,
  primary_link = default_speed,
  secondary = default_speed,
  secondary_link = default_speed,
  tertiary = default_speed,
  tertiary_link = default_speed,
  residential = default_speed,
  unclassified = default_speed,
  living_street = default_speed,
  road = default_speed,
  service = default_speed,
  track = default_speed*0.5,
  path = default_speed*0.5,
}

profile.surface_speeds = {
  asphalt = default_speed,
  ["cobblestone:flattened"] = default_speed * 0.5,
  paving_stones = default_speed * 0.5,
  compacted = default_speed * 0.5,
  unpaved = default_speed * 0.5,
  fine_gravel = default_speed * 0.5,
  gravel = default_speed * 0.5,
  pebblestone = default_speed * 0.5,
  ground = default_speed * 0.5,
  dirt = default_speed * 0.5,
  earth = default_speed * 0.5,
  sett = default_speed * 0.5,
  cobblestone = default_speed * 0.2,
  grass = default_speed * 0.2,
  mud = default_speed * 0.2,
  sand = default_speed * 0.2,
}

profile.pedestrian_speeds = {
  footway = walking_speed,
  pedestrian = walking_speed
  -- steps not allowed
}


function node_function (node, result)
  -- parse access and barrier tags
  local barrier = node:get_value_by_key("barrier")

  -- the normal bicycle profile whitelists barrier=cycle_barrier,
  -- but a cargo bike typically cannot pass. we enfore this even
  -- if bicycle=yes
  if barrier == 'cycle_barrier' then
    result.barrier = true
    return
  end

  local highway = node:get_value_by_key("highway")
  local is_crossing = highway and highway == "crossing"
 
  local access = find_access_tag(node, profile.access_tags_hierarchy)
  if access and access ~= "" then
    -- access restrictions on crossing nodes are not relevant for
    -- the traffic on the road
    if profile.access_tag_blacklist[access] and not is_crossing then
      result.barrier = true
    end
  else
    if barrier and "" ~= barrier then
      if not profile.barrier_whitelist[barrier] then
        result.barrier = true
      end
    end
  end

  -- check if node is a traffic light
  local tag = node:get_value_by_key("highway")
  if tag and "traffic_signals" == tag then
    result.traffic_lights = true
  end
end
