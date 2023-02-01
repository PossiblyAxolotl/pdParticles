local gfx <const> = playdate.graphics

import "coreLibs/graphics"
import "coreLibs/object"
import "pdParticles"

local part = ParticlePoly(200,120)

part:setThickness(0, 3)

part:setAngular(-15, 15)

part:setPoints(3, 5)

part:setMode(Particles.modes.LOOP)

part:setBounds(0,0,400,240)

part:setSize(10,25)

part:setSpeed(5, 25)

function playdate.update()
    gfx.clear()
    part:update()

    if playdate.buttonJustPressed(playdate.kButtonA) then
        part:add(5)
    end
    if playdate.buttonJustPressed(playdate.kButtonB) then
        Particles:clearAll()
    end
end