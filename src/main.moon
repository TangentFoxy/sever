import max, min from math

class Generator
  new: =>
    @acceleration = 1.5 -- rate of rpm change based on rpm
    @fuel = 0.0011     -- use per rpm
    @fuelCurve = 1.1
    @energy = 0.038    -- produced per rpm
    @energyCurve = 0.9
    @rpm = 0 -- current rpm
    @throttle = 0 -- 0 to 1 throttle
    @maximum_rpm = 8000
    @instability = 0.01 -- random modification in rpm
    @redline = 7000 -- maximum safe rpm
    @volume = {                -- TEMP
      pressure: -> return 1
      remove: (f) => return f
    }
    @battery = { add: -> }     -- TEMP

  update: (dt) =>
    target = @throttle * @maximum_rpm
    if target < @rpm
      @rpm = max target, @rpm - (@rpm^0.9 + 500) * @acceleration * dt
      -- @rpm = target if @rpm < target
      @battery\add(@energy * @rpm^@energyCurve * dt)
    else
      if target > @rpm
        -- @rpm = 100 if @rpm < 100
        @rpm = min target, @rpm + (@rpm^0.9 + 500) * @acceleration * dt
      @rpm += @rpm * @instability * (math.random! - 0.5)
      fuel = @fuel * @rpm^@fuelCurve * dt
      fuel = @volume\remove(fuel) / fuel -- TEMP (needs to be both fuel types)
      if fuel < 1
        @rpm = max 0, @rpm - @rpm * @acceleration * (1 - fuel) * dt
      @battery\add(@energy * @rpm^@energyCurve * dt)

gen = Generator!

love.update = (dt) ->
  if love.keyboard.isDown("up")
    -- gen.throttle += dt
    gen.throttle = min 1, gen.throttle + dt / 5
  elseif love.keyboard.isDown("down")
    -- gen.throttle -= dt
    gen.throttle = max 0, gen.throttle - dt / 5
  gen\update dt

love.draw = ->
  love.graphics.print "RPM: #{math.floor gen.rpm} Throttle: #{math.floor(gen.throttle * 100) / 100} Generating: #{math.floor(gen.energy * gen.rpm) / 10} Using: #{math.floor( gen.fuel * gen.rpm * 10) / 10} Efficiency: #{math.floor((gen.energy * gen.rpm^0.9) / (gen.fuel * gen.rpm^1.1) * 10) / 10}"

  cx, cy = 400, 300 -- TEMP
  -- mod = math.pi / gen.redline
  mod = math.pi / gen.maximum_rpm
  angle = gen.rpm * mod + math.pi
  love.graphics.line cx, cy, cx + 100 * math.cos(angle), cy + 100 * math.sin(angle)

actions = {
  "1": -> gen.throttle = 0.1
  "2": -> gen.throttle = 0.2
  "3": -> gen.throttle = 0.3
  "4": -> gen.throttle = 0.4
  "5": -> gen.throttle = 0.5
  "6": -> gen.throttle = 0.6
  "7": -> gen.throttle = 0.7
  "8": -> gen.throttle = 0.8
  "9": -> gen.throttle = 0.9
  "0": -> gen.throttle = 1
  "escape": -> love.event.quit!
}
love.keypressed = (key) ->
  actions[key]() if actions[key]
