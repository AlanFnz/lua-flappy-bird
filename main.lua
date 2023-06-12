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

-- game state and state machines
require 'StateMachine'
require 'states/BaseState'
require 'states/CountdownState'
require 'states/PlayState'
require 'states/ScoreState'
require 'states/TitleScreenState'

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60
local BACKGROUND_LOOPING_POINT = 413

-- images we load into memory from files to later draw onto the screen
local background = love.graphics.newImage('background.png')
local ground = love.graphics.newImage('ground.png')
local backgroundScroll = 0
local groundScroll = 0
local bird = Bird()
local pipePairs = {}
local spawnTimer = 0
local scrolling = true

-- initialize last recorder Y value for gap 
local lastY = -PIPE_HEIGHT + math.random(80) + 20

function love.load()
    -- initialize nearest-neighbor filter
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- app window title
    love.window.setTitle('Fifty Bird')

    -- initialize virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    -- initialize text fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    mediumFont = love.graphics.newFont('flappy.ttf', 14)
    flappyFont = love.graphics.newFont('flappy.ttf', 28)
    hugeFont = love.graphics.newFont('flappy.ttf', 56)
    love.graphics.setFont(flappyFont)

    -- initialize state machine with all state-returning functions
    gStateMachine = StateMachine {
        ['title'] = function()
            return TitleScreenState()
        end,
        ['countdown'] = function()
            return CountdownState()
        end,
        ['play'] = function()
            return PlayState()
        end,
        ['score'] = function()
            return ScoreState()
        end
    }
    gStateMachine:change('title')

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

    -- update the state machine
    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()

    -- draw state machine between the background and ground
    love.graphics.draw(background, -backgroundScroll, 0)
    gStateMachine:render()
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)

    push:finish()
end
