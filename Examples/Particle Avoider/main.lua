-- PossiblyAxolotl
-- Feb 8, 2023
-- Particle Avoider

local showFPS <const> = false -- SET TO 'true' TO SEE FPS

import "CoreLibs/graphics"
import "CoreLibs/object"
import "pdParticles"

local gfx <const> = playdate.graphics
local speed <const> = 2

-- define the player particle
local partPlayer = ParticlePoly(200, 120)
partPlayer:setSize(7,12)
partPlayer:setMode(Particles.modes.DECAY)
partPlayer:setSpeed(1,3)

-- define the obstacle particles
local partObstacles = ParticleCircle(0,0)
partObstacles:setBounds(0,0,400,240)
partObstacles:setMode(Particles.modes.LOOP)
partObstacles:setSize(10, 15)
partObstacles:setSpeed(1, 2)

-- define the main menu func, this will be used later. Self explanatory code
function menu()
    gfx.clear()
    gfx.drawText("Press A to Play", 200 - gfx.getTextSize("Press A to Play") / 2, 120)

    if playdate.buttonJustPressed(playdate.kButtonA) then
        playdate.update = game
        partObstacles:add(30)
    end
end

-- game screen
function game()

    -- [[ UPDATE ]] --

    -- set the player's position based on player input
    local changeX, changeY = 0, 0
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        changeY -= speed
    end
    if playdate.buttonIsPressed(playdate.kButtonDown) then
        changeY += speed
    end
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        changeX -= speed
    end
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        changeX += speed
    end

    partPlayer:moveBy(changeX, changeY)

    local xp, yp = partPlayer:getPos() -- get the player position so...
    -- ...I can detect the player going off the screen and loop it around
    if xp > 400 then partPlayer:moveTo(0,yp) elseif xp < 0 then partPlayer:moveTo(400,yp) end
    if yp > 240 then partPlayer:moveTo(xp, 0) elseif yp < 0 then partPlayer:moveTo(xp, 240) end

    -- DRAW
    gfx.clear()
    partPlayer:add(1)
    Particles:update()

    local parts = partObstacles:getParticles() -- get a table of the enemy particles

    for p = 1, #parts, 1 do -- detect if each enemy particle is colliding with the player
        local part = parts[p]
        if playdate.geometry.distanceToPoint(xp,yp,part.x,part.y) < part.size then -- if one is, then go to the menu
            playdate.update = menu
            partObstacles:clearParticles()
            partPlayer:clearParticles()
            partPlayer:moveTo(200,120)
            break
        end
    end

    if showFPS then playdate.drawFPS(0,0) end
end

playdate.update = menu -- override the playdate.update() function, setting it to the menu() function
-- cool lua feature, way cleaner than a state machine
