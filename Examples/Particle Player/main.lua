local gfx <const> = playdate.graphics

import "coreLibs/graphics"
import "coreLibs/object"
import "pdParticles"

local speed = 3

local part = ParticleCircle(200,120)

part:setMode(Particles.modes.DECAY)
part:setSpeed(1,5)

local bgShapes = ParticlePoly(200,120)

bgShapes:setBounds(0,0,400,240)
bgShapes:setPoints(3, 6)
bgShapes:setSize(10, 30)
bgShapes:setThickness(2)
bgShapes:setAngular(-15,15)
bgShapes:setSpeed(1, 5)
bgShapes:setMode(Particles.modes.LOOP)
bgShapes:add(10)

function playdate.update()
    gfx.clear()
    part:add(1)
    Particles:update()

    print(#part:getParticles())

    local vel = {0,0}

    if playdate.buttonIsPressed(playdate.kButtonDown) then
        vel[2] += 1
    end
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        vel[2] -= 1
    end
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        vel[1] += 1
    end
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        vel[1] -= 1
    end

    part:moveBy(vel[1] * speed,vel[2] * speed)
end