local particles = {}
local precision = 1

-- base particle class
class("Particle").extends()
function Particle:init(x, y)
    self.x = x or 0
    self.y = y or 0
    self.size = {1,1}
    self.spread = {0,359}
    self.speed = {1,1}
    self.thickness = {0,0}
    self.lifespan = {1,1}
    self.decay = 1
    self.particles = {}
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

    particles[#particles+1] = self

end

function Particle:remove()
    for i = 1, #particles, 1 do
        if particles[i] == self then
            table.remove(particles, i)
            break
        end
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

    for part = #partlist, 1, -1 do
        local particle = partlist[part]
        if particle.size <= 0 then
            table.remove(partlist,part)
        end
    end

    return partlist
end

local function disappear(partlist)
    for part = 1, #partlist, 1 do
        local particle = partlist[part]
        particle.lifespan -= .1
    end
    for part = #partlist, 1, -1 do
        local particle = partlist[part]
        if particle.lifespan <= 0 then
            table.remove(partlist,part)
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
        for part = #partlist, 1, -1 do
            local particle = partlist[part]
            if particle.x > bounds[3] then table.remove(partlist,part)
            elseif particle.x < bounds[1] then table.remove(partlist,part)
            elseif particle.y > bounds[4] then table.remove(partlist,part)
            elseif particle.y < bounds[2] then table.remove(partlist,part) end
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
            size = math.random(self.size[1],self.size[2]) * precision,
            speed = math.random(self.speed[1],self.speed[2]) * precision,
            lifespan = math.random(self.lifespan[1],self.lifespan[2]) * precision,
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
        decay(self.particles, self.decay)
        
    elseif self.mode == 0 then
        disappear(self.particles)
        
    elseif self.mode == 2 then
        loop(self.particles, self.bounds)
        
    else
        stay(self.particles, self.bounds)
        
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

function ParticlePoly:create(amount)
    for i = 1, amount, 1 do
        local part = {
            x = self.x,
            y = self.y,
            dir = math.random(self.spread[1],self.spread[2]),
            size = math.random(self.size[1],self.size[2]) * precision,
            speed = math.random(self.speed[1],self.speed[2]) * precision,
            lifespan = math.random(self.lifespan[1],self.lifespan[2]) * precision,
            thickness = math.random(self.thickness[1],self.thickness[2]) * precision,
            angular = math.random(self.angular[1],self.angular[2]) * precision,
            points = math.random(self.points[1], self.points[2]),
            decay = self.decay,
            rotation = math.random(self.rotation[1],self.rotation[2])
        }

        self.particles[#self.particles+1] = part
    end
end

function ParticlePoly:add(amount)
    self:create(amount)
end

function ParticlePoly:update()
    local w = playdate.graphics.getLineWidth()
    local c = playdate.graphics.getColor()
    playdate.graphics.setColor(self.colour)
    for part = 1, #self.particles, 1 do
        local poly = self.particles[part]
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

        self.particles[part] = poly
    end
    playdate.graphics.setLineWidth(w)
    playdate.graphics.setColor(c)

    if self.mode == 1 then
        decay(self.particles, self.decay)
        
    elseif self.mode == 0 then
        disappear(self.particles)
        
    elseif self.mode == 2 then
        loop(self.particles, self.bounds)
        
    else
        stay(self.particles, self.bounds)
        
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

function ParticleImage:create(amount)
    if self.image ~= nil then
        for i = 1, amount, 1 do
            local part = {
                x = self.x,
                y = self.y,
                dir = math.random(self.spread[1],self.spread[2]),
                size = math.random(self.size[1],self.size[2]) * precision,
                speed = math.random(self.speed[1],self.speed[2]) * precision,
                lifespan = math.random(self.lifespan[1],self.lifespan[2]) * precision,
                thickness = math.random(self.thickness[1],self.thickness[2]),
                angular = math.random(self.angular[1],self.angular[2]) * precision,
                decay = self.decay,
                image = self.image,
                rotation = math.random(self.rotation[1],self.rotation[2])
            }

            self.particles[#self.particles+1] = part
        end
    else
        for i = 1, amount, 1 do
            local part = {
                x = self.x,
                y = self.y,
                dir = math.random(self.spread[1],self.spread[2]),
                size = math.random(self.size[1],self.size[2]) * precision,
                speed = math.random(self.speed[1],self.speed[2]) * precision,
                lifespan = math.random(self.lifespan[1],self.lifespan[2]) * precision,
                thickness = math.random(self.thickness[1],self.thickness[2]),
                angular = math.random(self.angular[1],self.angular[2]) * precision,
                decay = self.decay,
                image = self.table[math.random(#self.table)],
                rotation = math.random(self.rotation[1],self.rotation[2])
            }

            self.particles[#self.particles+1] = part
        end
    end
end

function ParticleImage:add(amount)
    self:create(amount)
end

function ParticleImage:update()
    for part = 1, #self.particles, 1 do
        local img = self.particles[part]

        img.image:drawRotated(img.x,img.y,img.rotation,img.size)

        img.rotation += img.angular

        img.x += math.sin(math.rad(img.dir)) * img.speed
        img.y = img.y - math.cos(math.rad(img.dir)) * img.speed

        self.particles[part] = img
    end

    if self.mode == 1 then
        decay(self.particles, self.decay)
        
    elseif self.mode == 0 then
        disappear(self.particles)
        
    elseif self.mode == 2 then
        loop(self.particles, self.bounds)
        
    else
        stay(self.particles, self.bounds)
        
    end
end

class("ParticleImageBasic", {type = 3}).extends(ParticleImage)

function ParticleImageBasic:update()
    for part = 1, #self.particles, 1 do
        local img = self.particles[part]

        img.image:drawScaled(img.x,img.y,img.size)

        img.rotation += img.angular

        img.x += math.sin(math.rad(img.dir)) * img.speed
        img.y = img.y - math.cos(math.rad(img.dir)) * img.speed

        self.particles[part] = img
    end

    if self.mode == 1 then
        decay(self.particles, self.decay)
        
    elseif self.mode == 0 then
        disappear(self.particles)
        
    elseif self.mode == 2 then
        loop(self.particles, self.bounds)
        
    else
        stay(self.particles, self.bounds)
        
    end
end

class("ParticlePixel").extends(Particle)

function ParticlePixel:create(amount)
    for i = 1, amount, 1 do
        local part = {
            x = self.x,
            y = self.y,
            dir = math.random(self.spread[1],self.spread[2]),
            speed = math.random(self.speed[1],self.speed[2]) * precision,
            lifespan = math.random(self.lifespan[1],self.lifespan[2])  * precision,
        }

        self.particles[#self.particles+1] = part
    end
end

function ParticlePixel:add(amount)
    self:create(amount)
end

function ParticlePixel:update()
    local c = playdate.graphics.getColor()
    playdate.graphics.setColor(self.colour)
    for part = 1, #self.particles, 1 do
        local pix = self.particles[part]
        
        playdate.graphics.drawPixel(pix.x,pix.y,pix.size)

        pix.x += math.sin(math.rad(pix.dir)) * pix.speed
        pix.y -= math.cos(math.rad(pix.dir)) * pix.speed

        self.particles[part] = pix
    end
    playdate.graphics.setColor(c)

    if self.mode == 0 then
        disappear(self.particles)
        
    elseif self.mode == 2 then
        loop(self.particles, self.bounds)
        
    else
        stay(self.particles, self.bounds)
        
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
