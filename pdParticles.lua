local circles = {}

-- base particle class
class("Particle").extends()
function Particle:init(x, y)
    self.x = x or 0
    self.y = y or 0
    self.size = {10,10}
    self.spread = {0,359}
    self.speed = {1,1}
    self.thickness = {0,0}
    self.lifespan = {1,1}
    self.decay = 1
    self.particles = {}
    self.colour = playdate.graphics.kColorBlack
    self.bounds = {0,0,0,0}
    self.mode = 0
    self.angular=0

    if self.type == 1 then
        circles[#circles+1] = self
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
    return self.particles
end

function Particle:clearParticles()
    self.particles = {}
end

function Particle:update()
end

-- [[ PARTICLE MODES ]] --

local function decay(partlist, decay)
    for part = 1, #partlist, 1 do
        local particle = partlist[part]
        particle.size -= decay

        if particle.size <= 0 then
            particle.size = 0
        end

        partlist[part] = particle
    end

    for part = 1, #partlist, 1 do
        local particle = partlist[part]
        if particle.size <= 0 then
            table.remove(partlist,part)
            break
        end
    end

    return partlist
end

local function disappear(partlist)
    for part = 1, #partlist, 1 do
        local particle = partlist[part]
        particle.lifespan -= .1
    end
    for part = 1, #partlist, 1 do
        local particle = partlist[part]
        if particle.lifespan <= 0 then
            table.remove(partlist,part)
            break
        end
    end

    return partlist
end

local function loop(partlist, bounds)
    if bounds[3] > bounds[1] and bounds[4] > bounds[2] then
        local xDif , yDif = bounds[3] - bounds[1], bounds[4] - bounds[2]
        for part = 1, #partlist, 1 do
            local particle = partlist[part]
            if particle.x > bounds[3] then particle.x -= xDif
            elseif particle.x < bounds[1] then particle.x += xDif end
            if particle.y > bounds[4] then particle.y -= yDif
            elseif particle.y < bounds[2] then particle.y += yDif end
        end
    end

    return partlist
end

local function stay(partlist, bounds)
    if bounds[3] > bounds[1] and bounds[4] > bounds[2] then
        local xDif , yDif = bounds[3] - bounds[1], bounds[4] - bounds[2]
        for part = 1, #partlist, 1 do
            local particle = partlist[part]
            if particle.x > bounds[3] then table.remove(partlist,part) break
            elseif particle.x < bounds[1] then table.remove(partlist,part) break
            elseif particle.y > bounds[4] then table.remove(partlist,part) break
            elseif particle.y < bounds[2] then table.remove(partlist,part) break end
        end
    end

    return partlist
end

class("ParticleCircle", {type = 1}).extends(Particle)

function ParticleCircle:create(amount)
    for i = 1, amount, 1 do
        local part = {
            x = self.x,
            y = self.y,
            dir = math.random(self.spread[1],self.spread[2]),
            size = math.random(self.size[1],self.size[2]),
            speed = math.random(self.speed[1],self.speed[2]),
            lifespan = math.random(self.lifespan[1],self.lifespan[2]),
            thickness = math.random(self.thickness[1],self.thickness[2]),
            decay = self.decay
        }

        self.particles[#self.particles+1] = part
    end
end

function ParticleCircle:add(amount)
    self:create(amount)
end

function ParticleCircle:update()
    local w = playdate.graphics.getLineWidth()
    local c = playdate.graphics.getColor()
    playdate.graphics.setColor(self.colour)
    for part = 1, #self.particles, 1 do
        local circ = self.particles[part]
        if circ.thickness < 1 then
            playdate.graphics.fillCircleAtPoint(circ.x,circ.y,circ.size)
        else
            playdate.graphics.setLineWidth(circ.thickness)
            playdate.graphics.drawCircleAtPoint(circ.x, circ.y, circ.size)
        end

        circ.x += math.sin(math.rad(circ.dir)) * circ.speed
        circ.y -= math.cos(math.rad(circ.dir)) * circ.speed

        self.particles[part] = circ
    end
    playdate.graphics.setLineWidth(w)
    playdate.graphics.setColor(c)
    if self.mode == 1 then
        local newCircs = decay(self.particles, self.decay)
        self.circs = newCircs
    elseif self.mode == 0 then
        local newCircs = disappear(self.particles)
        self.circs = newCircs
    elseif self.mode == 2 then
        local newCircs = loop(self.particles, self.bounds)
        self.circs = newCircs
    else
        local newCircs = stay(self.particles, self.bounds)
        self.circs = newCircs
    end
end

class("Particles").extends()

Particles.modes = {DISAPPEAR = 0, DECAY = 1, LOOP = 2, STAY = 3}

function Particles:update()
    for circle = 1, #circles, 1 do
        circles[circle]:update()
    end
end

function Particles:clearAll()
    for circle = 1, #circles, 1 do
        circles[circle]:clearParticles()
    end
end