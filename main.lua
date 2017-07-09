-- Vectors

function Vector(x, y)
  return {
    x = x,
    y = y,
  }
end

function add(v1, v2)
  return Vector(v1.x+v2.x, v1.y+v2.y)
end

function sub(v1, v2)
  return Vector(v1.x-v2.x, v1.y-v2.y)
end

function div(v, n)
  return Vector(v.x/n, v.y/n)
end

function reverseDiv(v, n)
  return Vector(n/v.x, n/v.y)
end

function mult(v, n)
  return Vector(v.x*n, v.y*n)
end

function magnitude(v)
  return math.sqrt((v.x)^2 + (v.y)^2)
end

function rule1(b, boids)
  -- This is a position Vector
  local pc = Vector(0, 0)
  for _, boid in ipairs(boids) do
    if b ~= boid then
      pc = add(pc, boid.position)
    end
  end
  pc = div(pc, #boids-1)
  return Vector((pc.x - b.position.x) / boids.radius, (pc.y - b.position.y) / boids.radius)
end

function rule2(b, boids)
  -- This is a position Vector
  local c = Vector(0, 0)
  for _, boid in ipairs(boids) do
    if b ~= boid then
      local temp = sub(boid.position, b.position)
      if magnitude(temp) < boids.radius then
        c = sub(c, sub(boid.position, b.position))
      end
    end
  end
  return c
end

function rule3(b, boids)
  -- This is a velocity Vector
  local pv = Vector(0, 0)
  for _, boid in ipairs(boids) do
    if b ~= boid then
      pv = add(pv, b.velocity)
    end
  end
  pv = div(pv, #boids-1)
  return div(pv, 8)
end

local limit = 1
function limitVelocity(boid)
  if magnitude(boid.velocity) > limit then
    boid.velocity = mult(div(boid.velocity, magnitude(boid.velocity)), limit)
  end
end

local min = Vector(0, 0)
local max = Vector(love.graphics.getWidth(), love.graphics.getHeight())
function boundPosition(boid)
  if boid.position.x < min.x then
    boid.velocity.x = 10
  elseif boid.position.x > max.x then
    boid.velocity.x = -10
  end
  if boid.position.y < min.y then
    boid.velocity.y = 10
  elseif boid.position.y > max.y then
    boid.velocity.y = -10
  end
end

function avoidPlace(boid)
  local place = Vector(love.mouse.getX(), love.mouse.getY())
  return reverseDiv(sub(place, boid.position), 60)
end

local boids = {radius=10}
function InitializeBoids()
  math.randomseed(os.time())
  -- Number of boids
  local n = 30
  for i = 1, n do
    local x = math.random(0, love.graphics.getWidth())
    local y = math.random(0, love.graphics.getHeight())
    local vx = math.random(-1, 1)
    local vy = math.random(-1, 1)
    boids[#boids+1] = {position=Vector(x, y), velocity=Vector(vx, vy)}
  end
end

local m1, m2, m3 = 1, 1, 1
function MoveBoids(dt)
  for i, boid in ipairs(boids) do
    local v1 = mult(rule1(boid, boids), m1)
    local v2 = mult(rule2(boid, boids), m2)
    local v3 = mult(rule3(boid, boids), m3)
    local v4 = mult(avoidPlace(boid), -1)

    -- print(v3.x, v3.y)
    -- print(boid.velocity.x, boid.velocity.y)

    boid.velocity = add(add(add(add(boid.velocity, v1), v2), v3), v4)
    limitVelocity(boid)
    boid.position = add(boid.position, boid.velocity)
    -- print(i, 'boid', boid.position.x, boid.position.y)
    -- boid.velocity = mult(boid.velocity, dt)
    boundPosition(boid)
  end
end

function DrawBoids()
  for _, boid in ipairs(boids) do
    love.graphics.circle('fill', boid.position.x, boid.position.y, 3)
  end
end

function love.load()
  InitializeBoids()
end

function love.update(dt)
  MoveBoids(dt)
end

function love.draw()
  DrawBoids()
end

function love.keypressed(key)
  if key == '1' then
    m1 = m1 * -1
  end
end