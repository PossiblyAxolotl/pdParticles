local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "CoreLibs/object"
import "pdParticles"

local particleA = ParticleCircle(200, 120)

particleA:setSize(5,7)

particleA:setSpeed(1, 5)

particleA:setMode(Particles.modes.LOOP)

particleA:setThickness(0, 3)

particleA:setBounds(0,0,400,240)

local particleB = ParticleCircle(200, 120)

particleB:setSize(15,25)

particleB:setSpeed(1, 3)

particleB:setMode(Particles.modes.LOOP)

particleB:setBounds(0,0,400,240)

particleB:setColour(gfx.kColorXOR)


function playdate.update()
    gfx.clear()
    Particles:update()

    if playdate.buttonJustPressed(playdate.kButtonA) then
        particleA:add(20)
    end

    if playdate.buttonJustPressed(playdate.kButtonB) then
        particleB:add(5)
    end

    if playdate.buttonJustPressed(playdate.kButtonUp) then
        Particles:clearAll()
    end
end
