local particles = {}
local precision = 1
local particle_pool_size = 25

-- base particle class
class("Particle").extends()
function Particle:init(x, y, pool_size)
    pool_size = pool_size or particle_pool_size
    self.x = x or 0
    self.y = y or 0
    self.size = {1,1}
    self.spread = {0,359}
    self.speed = {1,1}
    self.acceleration = {0, 0}
    self.thickness = {0,0}
    self.lifespan = {1,1}
    self.decay = 1
    self.colour = playdate.graphics.kColorBlack
    self.bounds = {0,0,0,0}
    self.mode = 0
    if self.type == 2 then -- polys
        self.points={3,3}
        self.angular={0,0}
        self.rotation={0,359}
    elseif self.type == 3 then -- images
        self.angular={0,0}
        self.image = playdate.graphics.image.new(1,1)
        self.table = nil
        self.rotation = {0,359}
    end

    self.partlist = table.create(pool_size, 0)
    self.active = table.create(pool_size, 0)
    self.available = table.create(pool_size, 0)
    self:create(pool_size)
    table.insert(particles, self)
end

function Particle:default(part)
    part = part or {}
    -- Stub function, should be overridden by child classes
    return part or {}
end

function Particle:create(amount)
    for _ = 1, amount do
        self.partlist[#self.partlist + 1] = self:default()
        table.insert(self.available, #self.partlist)
    end
end

function Particle:add(amount)
    if #self.available - amount < 0 then
        self:create(amount - #self.available)
    end

    for _ = 1, amount do
        local index = table.remove(self.available)
        table.insert(self.active, index)
        self.partlist[index] = self:default(self.partlist[index])
    end
end

-- [[ SETTERS AND GETTERS ]] --

-- movement
function Particle:moveTo(x,y)
    self.x = x
    self.y = y
end

function Particle:moveBy(x,y)
    self.x += x
    self.y += y
end

function Particle:getPos()
    return self.x, self.y
end

-- size
function Particle:setSize(min, max)
    self.size = {min, max or min}
end

function Particle:getSize()
    return self.size[1], self.size[2]
end

-- mode
function Particle:setMode(mode)
    self.mode = mode
end

function Particle:getMode()
    return self.mode
end

-- spread
function Particle:setSpread(min,max)
    self.spread = {min, max or min}
end

function Particle:getSpread()
    return self.spread[1], self.spread[2]
end

-- speed
function Particle:setSpeed(min,max)
    self.speed = {min, max or min}
end

function Particle:getSpeed()
    return self.speed[1], self.speed[2]
end

-- acceleration
function Particle:setAcceleration(min,max)
    self.acceleration = {min, max or min}
end

function Particle:getAcceleration()
    return self.acceleration[1], self.acceleration[2]
end

-- thickness
function Particle:setThickness(min, max)
    self.thickness = {min, max or min}
end

function Particle:getThickness()
    return self.thickness[1], self.thickness[2]
end

-- lifespan
function Particle:setLifespan(min,max)
    self.lifespan = {min, max or min}
end

function Particle:getLifespan()
    return self.lifespan[1], self.lifespan[2]
end

-- colour
function Particle:setColor(colour)
    self.colour = colour
end

function Particle:getColor()
    return self.colour
end

function Particle:setColour(colour)
    self.colour = colour
end

function Particle:getColour()
    return self.colour
end

-- bounds
function Particle:setBounds(x1, y1, x2, y2)
    self.bounds = {x1,y1,x2,y2}
end

function Particle:getBounds()
    return self.bounds[1],self.bounds[2],self.bounds[3],self.bounds[4]
end

-- decay
function Particle:setDecay(decay)
    self.decay = decay
end

function Particle:getDecay()
    return self.decay
end

-- particles
function Particle:getParticles()
    return self.partlist
end

function Particle:getActive()
    return self.active
end

function Particle:clearParticles()
    self.partlist = {}
    self.active = {}
    self.available = {}
end

function Particle:update()
end

-- [[ PARTICLE MODES ]] --

local function remove(index, active, available)
    table.insert(available, index)
    table.remove(active, index)
end

local function decay(parts, active, available, decay)
    for i = #active, 1, -1 do
        local index = active[i]
        local part = parts[index]
        part.size -= decay

        if part.size <= 0 then
            part.size = 0
            remove(i, active, available)
        end
    end
end

local function disappear(partlist, active, available)
    for i = #active, 1, -1 do
        local index = active[i]
        local particle = partlist[index]
        particle.lifespan -= .1

        if particle.lifespan <= 0 then
            remove(i, active, available)
        end
    end
end

local function loop(partlist, active, _, bounds)
    if bounds[3] > bounds[1] and bounds[4] > bounds[2] then
        local xDif , yDif = bounds[3] - bounds[1], bounds[4] - bounds[2]
        for index = 1, #active, 1 do
            local particle = partlist[active[index]]
            if particle.x > bounds[3] then particle.x -= xDif
            elseif particle.x < bounds[1] then particle.x += xDif end
            if particle.y > bounds[4] then particle.y -= yDif
            elseif particle.y < bounds[2] then particle.y += yDif end
        end
    end
end

local function stay(partlist, active, available, bounds)
    if bounds[3] > bounds[1] and bounds[4] > bounds[2] then
        for i = #active, 1, -1 do
            local index = active[i]
            local particle = partlist[index]
            if particle.x > bounds[3] then
                remove(i, active, available)
            elseif particle.x < bounds[1] then
                remove(i, active, available)
            elseif particle.y > bounds[4] then
                remove(i, active, available)
            elseif particle.y < bounds[2] then
                remove(i, active, available)
            end
        end
    end
end

class("ParticleCircle", {type = 1}).extends(Particle)

function ParticleCircle:default(part)
    part = part or {}
    part.x = self.x
    part.y = self.y
    part.dir = math.random(self.spread[1],self.spread[2])
    part.size = math.random(self.size[1],self.size[2]) * precision
    part.speed = math.random(self.speed[1],self.speed[2]) * precision
    part.acceleration = math.random(self.acceleration[1],self.acceleration[2]) * precision
    part.lifespan = math.random(self.lifespan[1],self.lifespan[2]) * precision
    part.thickness = math.random(self.thickness[1],self.thickness[2])
    part.decay = self.decay
    return part
end

function ParticleCircle:update()
    local w = playdate.graphics.getLineWidth()
    local c = playdate.graphics.getColor()
    playdate.graphics.setColor(self.colour)
    for i = #self.active, 1, -1 do
        local index = self.active[i]
        local circ = self.partlist[index]
        if circ.thickness < 1 then
            playdate.graphics.fillCircleAtPoint(circ.x,circ.y,circ.size)
        else
            playdate.graphics.setLineWidth(circ.thickness)
            playdate.graphics.drawCircleAtPoint(circ.x, circ.y, circ.size)
        end

        circ.x += math.sin(math.rad(circ.dir)) * circ.speed
        circ.y -= math.cos(math.rad(circ.dir)) * circ.speed

        circ.speed += circ.acceleration / 100

        self.partlist[index] = circ
    end
    playdate.graphics.setLineWidth(w)
    playdate.graphics.setColor(c)
    if self.mode == 1 then
        decay(self.partlist, self.active, self.available, self.decay)
    elseif self.mode == 0 then
        disappear(self.partlist, self.active, self.available)
    elseif self.mode == 2 then
        loop(self.partlist, self.active, nil, self.bounds)
    else
        stay(self.partlist, self.active, self.available, self.bounds)
    end
end

class("ParticlePoly", {type = 2}).extends(Particle)

function ParticlePoly:getPoints()
    return self.points[1], self.points[2]
end

function ParticlePoly:setPoints(min,max)
    self.points = {min, max or min}
end

-- angular
function ParticlePoly:getAngular()
    return self.angular[1], self.angular[2]
end

function ParticlePoly:setAngular(min,max)
    self.angular = {min, max or min}
end

function ParticlePoly:getRotation()
    return self.rotation[1], self.rotation[2]
end

function ParticlePoly:setRotation(min,max)
    self.rotation = {min, max or min}
end

function ParticlePoly:default(part)
    part = part or {}
    part.x = self.x
    part.y = self.y
    part.dir = math.random(self.spread[1],self.spread[2])
    part.size = math.random(self.size[1],self.size[2]) * precision
    part.speed = math.random(self.speed[1],self.speed[2]) * precision
    part.acceleration = math.random(self.acceleration[1],self.acceleration[2]) * precision
    part.lifespan = math.random(self.lifespan[1],self.lifespan[2]) * precision
    part.thickness = math.random(self.thickness[1],self.thickness[2]) * precision
    part.angular = math.random(self.angular[1],self.angular[2]) * precision
    part.points = math.random(self.points[1], self.points[2])
    part.decay = self.decay
    part.rotation = math.random(self.rotation[1],self.rotation[2])
    return part
end

function ParticlePoly:update()
    local w = playdate.graphics.getLineWidth()
    local c = playdate.graphics.getColor()
    playdate.graphics.setColor(self.colour)
    for i = #self.active, 1, -1 do
        local index = self.active[i]
        local poly = self.partlist[index]
        local polygon = {}
        local degrees = 360 / poly.points
        for point = 1, poly.points, 1 do
            polygon[#polygon+1] = poly.x + math.sin(math.rad(degrees * point + poly.rotation)) * poly.size
            polygon[#polygon+1] = poly.y - math.cos(math.rad(degrees * point + poly.rotation)) * poly.size
        end
        if poly.thickness < 1 then
            playdate.graphics.fillPolygon(table.unpack(polygon))
        else
            playdate.graphics.setLineWidth(poly.thickness)
            playdate.graphics.drawPolygon(table.unpack(polygon))
        end

        poly.x += math.sin(math.rad(poly.dir)) * poly.speed
        poly.y = poly.y - math.cos(math.rad(poly.dir)) * poly.speed

        poly.rotation += poly.angular

        poly.speed += poly.acceleration / 100

        self.partlist[index] = poly
    end
    playdate.graphics.setLineWidth(w)
    playdate.graphics.setColor(c)

    if self.mode == 1 then
        decay(self.partlist, self.active, self.available, self.decay)
    elseif self.mode == 0 then
        disappear(self.partlist, self.active, self.available)
    elseif self.mode == 2 then
        loop(self.partlist, self.active, self.available, self.bounds)
    else
        stay(self.partlist, self.active, self.available, self.bounds)
    end
end

class("ParticleImage", {type = 3}).extends(Particle)

function ParticleImage:getAngular()
    return self.angular[1], self.angular[2]
end

function ParticleImage:setAngular(min,max)
    self.angular = {min, max or min}
end

function ParticleImage:getRotation()
    return self.rotation[1], self.rotation[2]
end

function ParticleImage:setRotation(min,max)
    self.rotation = {min, max or min}
end

function ParticleImage:setImage(image)
    self.image = image
    self.table = nil
end

function ParticleImage:setImageTable(image)
    self.image = nil
    self.table = image
end

function ParticleImage:getImage()
    return self.image
end

function ParticleImage:getImageTable()
    return self.table
end

function ParticleImage:default(part)
    part = part or {}
    part.x = self.x
    part.y = self.y
    part.dir = math.random(self.spread[1],self.spread[2])
    part.size = math.random(self.size[1],self.size[2]) * precision
    part.speed = math.random(self.speed[1],self.speed[2]) * precision
    part.acceleration = math.random(self.acceleration[1],self.acceleration[2]) * precision
    part.acceleration = math.random(self.acceleration[1],self.acceleration[2]) * precision
    part.lifespan = math.random(self.lifespan[1],self.lifespan[2]) * precision
    part.thickness = math.random(self.thickness[1],self.thickness[2])
    part.angular = math.random(self.angular[1],self.angular[2]) * precision
    part.decay = self.decay
    part.image = self.image
    part.rotation = math.random(self.rotation[1],self.rotation[2])
    return part
end

function ParticleImage:update()
    for i = #self.active, 1, -1 do
        local index = self.active[i]
        local img = self.partlist[index]

        img.image:drawRotated(img.x,img.y,img.rotation,img.size)

        img.rotation += img.angular

        img.x += math.sin(math.rad(img.dir)) * img.speed
        img.y = img.y - math.cos(math.rad(img.dir)) * img.speed

        img.speed += img.acceleration / 100

        self.partlist[index] = img
    end

    if self.mode == 1 then
        decay(self.partlist, self.active, self.available, self.decay)
    elseif self.mode == 0 then
        disappear(self.partlist, self.active, self.available)
    elseif self.mode == 2 then
        loop(self.partlist, self.active, nil, self.bounds)
    else
        stay(self.partlist, self.active, self.available, self.bounds)
    end
end

class("ParticleImageBasic", {type = 3}).extends(ParticleImage)

function ParticleImageBasic:update()
    for i = #self.active, 1, -1 do
        local index = self.active[i]
        local img = self.partlist[index]

        img.image:drawScaled(img.x,img.y,img.size)

        img.rotation += img.angular

        img.x += math.sin(math.rad(img.dir)) * img.speed
        img.y = img.y - math.cos(math.rad(img.dir)) * img.speed

        img.speed += img.acceleration / 100

        self.partlist[index] = img
    end

    if self.mode == 1 then
        decay(self.partlist, self.decay)
    elseif self.mode == 0 then
        disappear(self.partlist)
    elseif self.mode == 2 then
        loop(self.partlist, self.bounds)
    else
        stay(self.partlist, self.bounds)
    end
end

class("ParticlePixel").extends(Particle)

function ParticlePixel:default(part)
    part = part or {}
    part.x = self.x
    part.y = self.y
    part.dir = math.random(self.spread[1],self.spread[2])
    part.size = math.random(self.size[1],self.size[2]) * precision
    part.speed = math.random(self.speed[1],self.speed[2]) * precision
    part.acceleration = math.random(self.acceleration[1],self.acceleration[2]) * precision
    part.lifespan = math.random(self.lifespan[1],self.lifespan[2]) * precision
    return part
end

function ParticlePixel:update()
    local c = playdate.graphics.getColor()
    playdate.graphics.setColor(self.colour)
    for i = #self.active, 1, -1 do
        local index = self.active[i]
        local pix = self.partlist[index]

        playdate.graphics.drawPixel(pix.x,pix.y,pix.size)

        pix.x += math.sin(math.rad(pix.dir)) * pix.speed
        pix.y -= math.cos(math.rad(pix.dir)) * pix.speed

        pix.speed += pix.acceleration / 100

        self.partlist[index] = pix
    end
    playdate.graphics.setColor(c)

    if self.mode == 0 then
        disappear(self.partlist, self.active, self.available)
    elseif self.mode == 2 then
        loop(self.partlist, self.active, nil, self.bounds)
    else
        stay(self.partlist, self.active, self.available, self.bounds)
    end
end

-- [[ GLOBAL PARTICLE STUFF ]] --

class("Particles").extends()

Particles.modes = {DISAPPEAR = 0, DECAY = 1, LOOP = 2, STAY = 3}

function Particles:update()
    for particle = 1, #particles, 1 do
        particles[particle]:update()
    end
end

function Particles:clearAll()
    for part = 1, #particles, 1 do
        particles[part]:clearParticles()
    end
end

function Particles:removeAll()
    local lb = #particles
    for part = 1, #particles, 1 do
        particles[part] = nil
    end
end

function Particles:setPrecision(prec)
    precision = prec
end

function Particles:getPrecision()
    return precision
end

function Particles:setParticlePoolSize(size)
    particle_pool_size = size
end

function Particles:getParticlePoolSize()
    return particle_pool_size
end
