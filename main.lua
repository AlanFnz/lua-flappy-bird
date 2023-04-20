-- virtual resolution handling library
push = require 'push'
Class = require 'class'

require 'Bird'
require 'Pipe'
require 'PipePair'

-- physical screen dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual resolution dimensions
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

-- images we load into memory from files to later draw onto the screen
local background = love.graphics.newImage('background.png')
local ground = love.graphics.newImage('ground.png')
local backgroundScroll = 0
local groundScroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

local BACKGROUND_LOOPING_POINT = 413

local bird = Bird()

local pipePairs = {}

local spawnTimer = 0

-- initialize last recorder Y value for gap 
local lastY = -PIPE_HEIGHT + math.random(80) + 20

function love.load()
    -- initialize our nearest-neighbor filter
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- app window title
    love.window.setTitle('Fifty Bird')

    -- initialize our virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    -- seed 
    math.randomseed(os.time())

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true

    if key == 'escape' then
        love.event.quit()
    end
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.update(dt)
    -- background scrollin
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT

    -- pipePairs spawner
    spawnTimer = spawnTimer + dt
    if spawnTimer > 2 then
        local y = math.max(-PIPE_HEIGHT + 10, math.min(lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
        lastY = y
        table.insert(pipePairs, PipePair(y))
        spawnTimer = 0
    end

    -- bird update
    bird:update(dt)

    for k, pair in pairs(pipePairs) do
        pair:update(dt)
    end

    for k, pair in pairs(pipePairs) do
        if pair.remove then
            table.remove(pipePairs, k)
        end
    end

    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()

    -- draw the background starting at top left (0, 0)
    love.graphics.draw(background, -backgroundScroll, 0)

    -- draw pipePairs
    for k, pair in pairs(pipePairs) do
        pair:render()
    end

    -- draw the ground on top of the background, toward the bottom of the screen
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)

    bird:render()

    push:finish()
end
