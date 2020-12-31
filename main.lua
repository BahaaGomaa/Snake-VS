TILE_SIZE = 32

-- load modules
require "Settings"
Img = require "Img"
Sounds = require "Sounds"
Fonts = require "Fonts"

-- get display dimensions and set MAX_TILES in relation to it
WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()

MAX_TILES_X =  math.floor(WINDOW_WIDTH / TILE_SIZE)
MAX_TILES_Y =  math.floor(WINDOW_HEIGHT / TILE_SIZE)

-- declare tiles ids
TILE_EMPTY = 0
BL_SNAKE1_HEAD = 1
BL_SNAKE1_BODY = 2
BL_SNAKE1_TAIL = 3
BL_SNAKE1_TURN_1 = 4
BL_SNAKE1_TURN_2 = 5
BL_SNAKE1_TURN_3 = 6
BL_SNAKE1_TURN_4 = 7
OOBA = 8
STONE = 9
RD_SNAKE2_HEAD = 10
RD_SNAKE2_BODY = 11
RD_SNAKE2_TAIL = 12
RD_SNAKE2_TURN_1 = 13
RD_SNAKE2_TURN_2 = 14
RD_SNAKE2_TURN_3 = 15
RD_SNAKE2_TURN_4 = 16

-- snake moving directions
RIGHT = 1
UP = 2
LEFT = 3
DOWN = 4

-- declare gameplay variables
scoreLimit = 10
BLscore = 0
RDscore = 0
SET_LIVES = 3
BLlives = SET_LIVES
RDlives = SET_LIVES
STONES_MAX_N = 8
SNAKE_LEN = 5

SNAKE_SPEED = 0.090  -- old SNAKE_SPEED = 0.1 - (SNAKE_SPEED_FACTOR * 0.005)

-- declare booleans for game states
isBlueWon = false
isRedWon = false
isTie = false
isPaused = false
isStop = true
isEnd = false
isGameStart = true
isOptions = false
DrawLines = true
FPS = true

-- declare grids
local tileGrid = {}
local BLrotationGrid = {}
local RDrotationGrid = {}

-- declare snakes variables
local BLsnakeX, BLsnakeY
local RDsnakeX, RDsnakeY
local BLsnakeMoving = RIGHT
local RDsnakeMoving = RIGHT

-- provides discrete snake movement
local BLsnakeTimer = 0
local RDsnakeTimer = 0

-- snake data structure
local BLsnakeTiles = {}
local RDsnakeTiles = {}

function love.load()
    love.window.setTitle("Snake VS")

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = true,
        vsync = true
    })

    math.randomseed(os.time())  -- get seed for RNG

    -- tune the audio
    Sounds.musicSound:setLooping(true)
    Sounds.musicSound:setVolume(0.1)
    Sounds.musicSound:play()
    Sounds.hitSound:setVolume(0.65)
    Sounds.deathSound:setVolume(0.65)

    -- load options buttons to their respective tables so they can be drawn and clicked
    iforspeed = 1
    iforlives = 1
    iforlength = 3
    iforscore = 5
    SNAKE_SPEED_txt = 2
    STONES_txt = "Custom"
    for c = 16, 34, 2 do
        add_speed_button(32 * c, WINDOW_HEIGHT / 6, iforspeed, iforspeed)
        iforspeed = iforspeed + 1

        add_lives_button(32 * c, WINDOW_HEIGHT / 3.5, iforlives, iforlives)
        iforlives = iforlives + 1

        add_length_button(32 * c, WINDOW_HEIGHT / 2.4, iforlength, iforlength)
        iforlength = iforlength + 2

        add_score_button(32 * c, WINDOW_HEIGHT / 1.85, iforscore, iforscore)
        iforscore = iforscore + 5
    end
    add_stone_button(WINDOW_WIDTH / 2.35, WINDOW_HEIGHT / 1.5, "Few", 10)
    add_stone_button(WINDOW_WIDTH / 1.85, WINDOW_HEIGHT / 1.5, "Some", 20)
    add_stone_button(WINDOW_WIDTH / 1.5, WINDOW_HEIGHT / 1.5, "LOTS", 30)
end

function love.keypressed(key)

    if key == "escape" then
        if isOptions then  -- return from settings tab to main menu
            isOptions = false
        elseif isPaused or isGameStart then  -- pause game or quit game if game is already paused
            love.event.quit()
        else
            isStop = true
            isPaused = true
        end
    end

    if key == "space" then  -- resume the game
        if not isGameStart and not isEnd then
            isPaused = false
            isStop = false
            love.mouse.setVisible(false)  -- not needed but here just to make sure :)
        end
    end
    
    if key == 'm' then   -- mute/unmute music at any time using M key
        if Sounds.musicSound:isPlaying() then
            Sounds.musicSound:pause()
        else
            Sounds.musicSound:play()
        end
    end

    if key == 'l' then   -- turn on/off drawing grid lines using L key
        if not isGameStart then
            if DrawLines then
                DrawLines = false
            else
                DrawLines = true
            end
        end
    end
    
    if key == 'f' then   -- show/hide FPS counter at any time using F key
        if FPS then
            FPS = false
        else
            FPS = true
        end
    end

    if key == 'o' then   -- go to settings tab using O key
        if isGameStart then
            isOptions = true
            love.mouse.setVisible(true)
        end
    end

    if key == 'backspace' then   -- go back to main menu from settings tab
        if isOptions then
            isOptions = false
        end
    end

    if key == 'home' then   -- go back to main menu from paused screen
        if isPaused then
            isGameStart = true
        end
    end

    -- handling of snake movement
    if not isStop then
        if key == "a" and BLsnakeMoving ~= RIGHT then
            BLsnakeMoving = LEFT
        elseif key == "d" and BLsnakeMoving ~= LEFT then
            BLsnakeMoving = RIGHT
        elseif key == "w" and BLsnakeMoving ~= DOWN then
            BLsnakeMoving = UP
        elseif key == "s" and BLsnakeMoving ~= UP then
            BLsnakeMoving = DOWN
        end

        if key == "left" and RDsnakeMoving ~= RIGHT then
            RDsnakeMoving = LEFT
        elseif key == "right" and RDsnakeMoving ~= LEFT then
            RDsnakeMoving = RIGHT
        elseif key == "up" and RDsnakeMoving ~= DOWN then
            RDsnakeMoving = UP
        elseif key == "down" and RDsnakeMoving ~= UP then
            RDsnakeMoving = DOWN
        end
    end

    if isEnd or isGameStart and not isOptions then
        if key == "enter" or key == "return" then  -- reset the game
            BLscore = 0
            RDscore = 0
            BLlives = SET_LIVES
            RDlives = SET_LIVES
            initializeGrid()  -- generate a grid with stones and OOBA
            initializeRotationGrid()  -- generate an empty rotationGrid
            initializeSnake()  -- create snakes
            isBlueWon = false
            isRedWon = false
            isTie = false
            isEnd = false
            isGameStart = false
            love.mouse.setVisible(false)  -- makes the mouse cursor invisible
        end
    end
end

function love.mousepressed(x, y)
    if isOptions then
        button_clicked(x, y)
    end
end

-- KNOWN BUG: too quick player input could result in player death as snakeMoving is updating a couple of times between drawing new frames
function love.update(dt)

    if not isStop then
        BLsnakeTimer = BLsnakeTimer + dt
        RDsnakeTimer = RDsnakeTimer + dt

        -- save current snake head coords for later use
        local BLpriorHeadX, BLpriorHeadY = BLsnakeX, BLsnakeY
        local RDpriorHeadX, RDpriorHeadY = RDsnakeX, RDsnakeY

        -- move the snake in one of 4 directions and handle edge of screen movement
        if BLsnakeTimer >= SNAKE_SPEED then
            if BLsnakeMoving == UP then
                if BLsnakeY <= 1 then
                    BLsnakeY = MAX_TILES_Y
                else
                    BLsnakeY = BLsnakeY - 1
                end
            elseif BLsnakeMoving == DOWN then
                if BLsnakeY >= MAX_TILES_Y then
                    BLsnakeY = 1
                else
                    BLsnakeY = BLsnakeY + 1
                end
            elseif BLsnakeMoving == LEFT then
                if BLsnakeX <= 1 then
                    BLsnakeX = MAX_TILES_X
                else
                    BLsnakeX = BLsnakeX - 1
                end
            else
                if BLsnakeX >= MAX_TILES_X then
                    BLsnakeX = 1
                else
                    BLsnakeX = BLsnakeX + 1
                end
            end

            -- push a new head element onto the snake data structure
            table.insert(BLsnakeTiles, 1, {BLsnakeX, BLsnakeY, BLsnakeMoving})

            -- if there is a head to head collision with the other snake
            if tileGrid[BLsnakeY][BLsnakeX] == RD_SNAKE2_HEAD then
                isStop = true  -- stop movement
                Sounds.hitSound:play()
                BLlives, RDlives = BLlives - 1, RDlives - 1  -- both players lose a live
                clearSnake()
                initializeSnake()
                if BLlives == 0 and RDlives == 0 then
                    Sounds.winSound:play()
                    if BLscore > RDscore then  -- if blue player has more score points
                        isBlueWon = true
                        isEnd = true
                    elseif BLscore < RDscore then  -- if blue player has less score points
                        isRedWon = true
                        isEnd = true
                    else  -- players tie
                        isTie = true
                        isEnd = true
                    end
                elseif BLlives == 0 and RDlives ~= 0 then
                    isRedWon = true
                    isEnd = true
                    Sounds.deathSound:play()
                elseif RDlives == 0 and BLlives ~= 0 then  
                    isBlueWon = true
                    isEnd = true
                    Sounds.deathSound:play()
                end

            -- if there is collision with a stone, rest of the snake or the other snake
            elseif  tileGrid[BLsnakeY][BLsnakeX] == BL_SNAKE1_BODY or
                    tileGrid[BLsnakeY][BLsnakeX] == BL_SNAKE1_TAIL or
                    tileGrid[BLsnakeY][BLsnakeX] == STONE or
                    tileGrid[BLsnakeY][BLsnakeX] == RD_SNAKE2_BODY or
                    tileGrid[BLsnakeY][BLsnakeX] == RD_SNAKE2_TAIL or
                    tileGrid[BLsnakeY][BLsnakeX] == RD_SNAKE2_TURN_1 or
                    tileGrid[BLsnakeY][BLsnakeX] == RD_SNAKE2_TURN_2 or
                    tileGrid[BLsnakeY][BLsnakeX] == RD_SNAKE2_TURN_3 or
                    tileGrid[BLsnakeY][BLsnakeX] == RD_SNAKE2_TURN_4 then
                
                    isStop = true  -- stop movement
                    Sounds.hitSound:play()
                    BLlives = BLlives - 1  -- Blue player loses one live
                    clearSnake()
                    initializeSnake()

                    if BLlives == 0 and RDlives ~= 0 then  -- Blue player loses
                        isRedWon = true
                        isEnd = true
                        Sounds.deathSound:play()
                    end

            elseif tileGrid[BLsnakeY][BLsnakeX] == OOBA then -- if snake is eating an OOBA increase score and generate a new OOBA
                BLscore = BLscore + 1
                Sounds.scoreSound:play()
                
                -- if player reached the scoreLimit
                if BLscore == scoreLimit then
                    isStop = true
                    Sounds.winSound:play()
                    isBlueWon = true
                    isEnd = true
                    clearSnake()
                    return
                end

                generateObstacle(OOBA)  -- generate a new OOBA
            
            -- otherwise, pop the snake tail and earse from the grid
            else
                local BLtail = BLsnakeTiles[#BLsnakeTiles]
                tileGrid[BLtail[2]][BLtail[1]] = TILE_EMPTY
                table.remove(BLsnakeTiles)
            end

            if not isStop then

                local BLheadMoving = BLsnakeTiles[1][3] -- should be the same as snakeMoving var
                local BLpriorHeadMoving = BLsnakeTiles[2][3]
                --[[set the correct turn tile for the 2nd piece of snake (tile just afterthe head) 
                    if there was a turn (so snakeTiles[n][3] and snakeTiles[n+1][3] will be different) 
                    there are 4 possible directions of snake head movement 
                    and in each case the 2nd tile has to be moving in one of two directions ]]
                if BLheadMoving ~= BLpriorHeadMoving then
                    if BLheadMoving == LEFT then
                        if BLpriorHeadMoving == UP then
                            tileGrid[BLpriorHeadY][BLpriorHeadX] = BL_SNAKE1_TURN_1
                        elseif BLpriorHeadMoving == DOWN then
                            tileGrid[BLpriorHeadY][BLpriorHeadX] = BL_SNAKE1_TURN_2
                        end
                    elseif BLheadMoving == DOWN then
                        if BLpriorHeadMoving == RIGHT then
                            tileGrid[BLpriorHeadY][BLpriorHeadX] = BL_SNAKE1_TURN_1
                        elseif BLpriorHeadMoving == LEFT then
                            tileGrid[BLpriorHeadY][BLpriorHeadX] = BL_SNAKE1_TURN_4
                        end
                    elseif BLheadMoving ==  UP then
                        if BLpriorHeadMoving == RIGHT then
                            tileGrid[BLpriorHeadY][BLpriorHeadX] = BL_SNAKE1_TURN_2
                        elseif BLpriorHeadMoving == LEFT then
                            tileGrid[BLpriorHeadY][BLpriorHeadX] = BL_SNAKE1_TURN_3
                        end
                    else -- elseif headMoving == RIGHT then
                        if BLpriorHeadMoving == DOWN then
                            tileGrid[BLpriorHeadY][BLpriorHeadX] = BL_SNAKE1_TURN_3
                        elseif BLpriorHeadMoving == UP then
                            tileGrid[BLpriorHeadY][BLpriorHeadX] = BL_SNAKE1_TURN_4
                        end
                    end

                -- if there was no turn set the prior head value to a body value
                else
                    tileGrid[BLpriorHeadY][BLpriorHeadX] = BL_SNAKE1_BODY
                end

                -- make the last snake tile its tail
                local BLtail = BLsnakeTiles[#BLsnakeTiles]
                tileGrid[BLtail[2]][BLtail[1]] = BL_SNAKE1_TAIL

                -- update the view with the next snake head location
                tileGrid[BLsnakeY][BLsnakeX] = BL_SNAKE1_HEAD
                BLrotationGrid[BLsnakeY][BLsnakeX] = BLsnakeMoving
            end
            BLsnakeTimer = 0  -- reset snakeTimer to avoid acceleration on dt
        end

        if RDsnakeTimer >= SNAKE_SPEED then
            if RDsnakeMoving == UP then
                if RDsnakeY <= 1 then
                    RDsnakeY = MAX_TILES_Y
                else
                    RDsnakeY = RDsnakeY - 1
                end
            elseif RDsnakeMoving == DOWN then
                if RDsnakeY >= MAX_TILES_Y then
                    RDsnakeY = 1
                else
                    RDsnakeY = RDsnakeY + 1
                end
            elseif RDsnakeMoving == LEFT then
                if RDsnakeX <= 1 then
                    RDsnakeX = MAX_TILES_X
                else
                    RDsnakeX = RDsnakeX - 1
                end
            else
                if RDsnakeX >= MAX_TILES_X then
                    RDsnakeX = 1
                else
                    RDsnakeX = RDsnakeX + 1
                end
            end

            table.insert(RDsnakeTiles, 1, {RDsnakeX, RDsnakeY, RDsnakeMoving})
            
            if tileGrid[RDsnakeY][RDsnakeX] == BL_SNAKE1_HEAD then
                isStop = true
                Sounds.hitSound:play()
                RDlives, BLlives = RDlives - 1, BLlives - 1
                clearSnake()
                initializeSnake()
                if RDlives == 0 and BLlives == 0 then
                    Sounds.winSound:play()
                    if RDscore > BLscore then
                        isRedWon = true
                        isEnd = true
                    elseif RDscore < BLscore then
                        isBlueWon = true
                        isEnd = true
                    else
                        isTie = true
                        isEnd = true
                    end
                elseif RDlives == 0 and BLlives ~= 0 then  
                    isBlueWon = true
                    isEnd = true
                    Sounds.deathSound:play()
                elseif BLlives == 0 and RDlives ~= 0 then
                    isRedWon = true
                    isEnd = true
                    Sounds.deathSound:play()
                end

            elseif  tileGrid[RDsnakeY][RDsnakeX] == RD_SNAKE2_BODY or
                    tileGrid[RDsnakeY][RDsnakeX] == RD_SNAKE2_TAIL or
                    tileGrid[RDsnakeY][RDsnakeX] == STONE or
                    tileGrid[RDsnakeY][RDsnakeX] == BL_SNAKE1_BODY or
                    tileGrid[RDsnakeY][RDsnakeX] == BL_SNAKE1_TAIL or
                    tileGrid[RDsnakeY][RDsnakeX] == BL_SNAKE1_TURN_1 or
                    tileGrid[RDsnakeY][RDsnakeX] == BL_SNAKE1_TURN_2 or
                    tileGrid[RDsnakeY][RDsnakeX] == BL_SNAKE1_TURN_3 or
                    tileGrid[RDsnakeY][RDsnakeX] == BL_SNAKE1_TURN_4 then
                
                isStop = true
                Sounds.hitSound:play()
                RDlives = RDlives - 1  -- Red player loses one live
                clearSnake()
                initializeSnake()

                if RDlives == 0 and BLlives ~= 0 then  
                    isBlueWon = true
                    isEnd = true
                    Sounds.deathSound:play()
                end

            elseif tileGrid[RDsnakeY][RDsnakeX] == OOBA then
                RDscore = RDscore + 1
                Sounds.scoreSound:play()
                
                if RDscore == scoreLimit then
                    isStop = true
                    Sounds.winSound:play()
                    isRedWon = true
                    isEnd = true
                    clearSnake()
                    return
                end

                generateObstacle(OOBA)
            
            else
                local RDtail = RDsnakeTiles[#RDsnakeTiles]
                tileGrid[RDtail[2]][RDtail[1]] = TILE_EMPTY
                table.remove(RDsnakeTiles)
            end

            if not isStop then

                local RDheadMoving = RDsnakeTiles[1][3]
                local RDpriorHeadMoving = RDsnakeTiles[2][3]
                if RDheadMoving ~= RDpriorHeadMoving then
                    if RDheadMoving == LEFT then
                        if RDpriorHeadMoving == UP then
                            tileGrid[RDpriorHeadY][RDpriorHeadX] = RD_SNAKE2_TURN_1
                        elseif RDpriorHeadMoving == DOWN then
                            tileGrid[RDpriorHeadY][RDpriorHeadX] = RD_SNAKE2_TURN_2
                        end
                    elseif RDheadMoving == DOWN then
                        if RDpriorHeadMoving == RIGHT then
                            tileGrid[RDpriorHeadY][RDpriorHeadX] = RD_SNAKE2_TURN_1
                        elseif RDpriorHeadMoving == LEFT then
                            tileGrid[RDpriorHeadY][RDpriorHeadX] = RD_SNAKE2_TURN_4
                        end
                    elseif RDheadMoving ==  UP then
                        if RDpriorHeadMoving == RIGHT then
                            tileGrid[RDpriorHeadY][RDpriorHeadX] = RD_SNAKE2_TURN_2
                        elseif RDpriorHeadMoving == LEFT then
                            tileGrid[RDpriorHeadY][RDpriorHeadX] = RD_SNAKE2_TURN_3
                        end
                    else
                        if RDpriorHeadMoving == DOWN then
                            tileGrid[RDpriorHeadY][RDpriorHeadX] = RD_SNAKE2_TURN_3
                        elseif RDpriorHeadMoving == UP then
                            tileGrid[RDpriorHeadY][RDpriorHeadX] = RD_SNAKE2_TURN_4
                        end
                    end

                else
                    tileGrid[RDpriorHeadY][RDpriorHeadX] = RD_SNAKE2_BODY
                end

                local RDtail = RDsnakeTiles[#RDsnakeTiles]
                tileGrid[RDtail[2]][RDtail[1]] = RD_SNAKE2_TAIL

                tileGrid[RDsnakeY][RDsnakeX] = RD_SNAKE2_HEAD
                RDrotationGrid[RDsnakeY][RDsnakeX] = RDsnakeMoving
            end

            RDsnakeTimer = 0
        end
    end
end

COLOR_WHITE = {1, 1, 1}
COLOR_RED = {1, 0, 0}
COLOR_BLUE = {0, 0, 1}
COLOR_PAIGE  = {0.8, 0.5, 0.3}

function love.draw()
    if isOptions then
        draw_button()
        drawOptionsScreen()
    elseif isGameStart then
        drawGameScreen()
    else
        drawGrid()
        drawStats()
        if isEnd then
            clearGrid()
            drawEndScreen()
        elseif isStop or isPaused then
            drawPausedScreen()
        end
    end

    if FPS then
        displayFPS()
    end
end

function drawGameScreen()  -- display game start screen
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Fonts.hugeFont)
    love.graphics.printf({"Snake ", COLOR_BLUE, "V", COLOR_RED, "S"}, 0, WINDOW_HEIGHT / 6, WINDOW_WIDTH, "center")

    love.graphics.setFont(Fonts.XlargeFont)
    love.graphics.printf({"Press ", COLOR_PAIGE, "Enter ", COLOR_WHITE, "to start"}, 0, WINDOW_HEIGHT / 2, WINDOW_WIDTH, "center")
                         
    love.graphics.setFont(Fonts.medFont)
    love.graphics.printf({"Press ", COLOR_PAIGE, "L ", COLOR_WHITE, "to switch drawing lines                 Press ", 
                           COLOR_PAIGE, "M ", COLOR_WHITE, "to mute/unmute music"}, 0, 
                           WINDOW_HEIGHT / 1.5, WINDOW_WIDTH, "center")

    love.graphics.printf({"Press ", COLOR_PAIGE, "F ", COLOR_WHITE, "to Show/hide FPS                 Press ", 
                           COLOR_PAIGE, "O ", COLOR_WHITE, "to go to settings"}, 0, 
                           WINDOW_HEIGHT / 1.3, WINDOW_WIDTH, "center")

    love.graphics.printf({"Press ", COLOR_PAIGE, "Esc ", COLOR_WHITE, "once to pause or twice to quit"}, 0,
                           WINDOW_HEIGHT / 1.15, WINDOW_WIDTH, "center")
end

function drawOptionsScreen()  -- display settings tab screen
    love.graphics.setColor(COLOR_WHITE)
    love.graphics.setFont(Fonts.XlargeFont)
    love.graphics.print("Settings", TILE_SIZE, TILE_SIZE)

    love.graphics.setFont(Fonts.largeFont)
    love.graphics.print("Sanke Speed", WINDOW_WIDTH / 7, WINDOW_HEIGHT / 6)
    love.graphics.print("Sanke Lives", WINDOW_WIDTH / 7, WINDOW_HEIGHT / 3.5)
    love.graphics.print("Sanke Length", WINDOW_WIDTH / 7, WINDOW_HEIGHT / 2.4)
    love.graphics.print("Score To Win", WINDOW_WIDTH / 7, WINDOW_HEIGHT / 1.85)
    love.graphics.print("Number of Stones", WINDOW_WIDTH / 7, WINDOW_HEIGHT / 1.5)

    love.graphics.setColor(1, 0, 1, 1)
    love.graphics.print(SNAKE_SPEED_txt, WINDOW_WIDTH / 1.16, WINDOW_HEIGHT / 6)
    love.graphics.print(SET_LIVES, WINDOW_WIDTH / 1.16, WINDOW_HEIGHT / 3.5)
    love.graphics.print(SNAKE_LEN, WINDOW_WIDTH / 1.16, WINDOW_HEIGHT / 2.4)
    love.graphics.print(scoreLimit, WINDOW_WIDTH / 1.16, WINDOW_HEIGHT / 1.85)
    love.graphics.print(STONES_txt, WINDOW_WIDTH / 1.2, WINDOW_HEIGHT / 1.5)

    love.graphics.setColor(COLOR_WHITE)
    love.graphics.setFont(Fonts.medFont)
    love.graphics.printf({"Press ", COLOR_PAIGE, "Esc ", COLOR_WHITE, "or ", COLOR_PAIGE, "Backspace ", COLOR_WHITE, "to go back"}, 0,
                           WINDOW_HEIGHT / 1.1, WINDOW_WIDTH, "center")

    love.graphics.print("Defult: 2~8", WINDOW_WIDTH / 6.1, WINDOW_HEIGHT / 1.4)
    love.graphics.setFont(Fonts.smallFont)
    love.graphics.print("1~10", WINDOW_WIDTH / 2.3, WINDOW_HEIGHT / 1.4)
    love.graphics.print("11~20", WINDOW_WIDTH / 1.8, WINDOW_HEIGHT / 1.4)
    love.graphics.print("21~30", WINDOW_WIDTH / 1.47, WINDOW_HEIGHT / 1.4)
end

function drawEndScreen()  -- display winner or tie
    love.graphics.setFont(Fonts.hugeFont)
    if isBlueWon then
        love.graphics.setColor(COLOR_BLUE)
        love.graphics.printf("BLUE WON", 0, WINDOW_HEIGHT / 4, WINDOW_WIDTH, "center")
    elseif isRedWon then
        love.graphics.setColor(COLOR_RED)
        love.graphics.printf("RED WON", 0, WINDOW_HEIGHT / 4, WINDOW_WIDTH, "center")
    elseif isTie then
        love.graphics.printf("TIE", 0, WINDOW_HEIGHT / 4, WINDOW_WIDTH, "center")
    end
    love.graphics.setFont(Fonts.largeFont)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf({"Press ", COLOR_PAIGE, "Enter ", COLOR_WHITE, "to Play Again"}, 0, WINDOW_HEIGHT / 1.5, WINDOW_WIDTH, "center")
end

function drawPausedScreen()  -- displayed when starting a new game or game paused
    love.graphics.setFont(Fonts.largeFont)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf({"Press ", COLOR_PAIGE, "Space ", COLOR_WHITE, "to start"}, 0, WINDOW_HEIGHT / 1.5, WINDOW_WIDTH, "center")
    if isPaused then
        love.graphics.printf({"Press ", COLOR_PAIGE, "Home ", COLOR_WHITE, "to go to main menu"}, 0, WINDOW_HEIGHT / 1.3, WINDOW_WIDTH, "center")
        love.graphics.printf({"Press ", COLOR_PAIGE, "Esc ", COLOR_WHITE, "to quit"}, 0, WINDOW_HEIGHT / 1.15, WINDOW_WIDTH, "center")
    end
end

function drawStats()  -- display music icon, lives and score
    if TILE_SIZE == 20 then
        love.graphics.setFont(Fonts.smallFont)
    else
        love.graphics.setFont(Fonts.medFont)
    end
    love.graphics.setColor(COLOR_BLUE)
    love.graphics.print("Blue Score: " .. tostring(BLscore), TILE_SIZE, 1)
    love.graphics.setColor(COLOR_RED)
    love.graphics.print("Red Score: " .. tostring(RDscore), TILE_SIZE * (MAX_TILES_X - 19), 1)

    -- draw remaining lives
    for i = 0, BLlives - 1 do
        drawQuadImage(Img.BheartImg, TILE_SIZE * 9 + TILE_SIZE * i, WINDOW_HEIGHT / 192, 0, 0.5)
    end
    for i = 0, RDlives - 1 do
        drawQuadImage(Img.RheartImg, TILE_SIZE * (MAX_TILES_X - 11) + TILE_SIZE * i, WINDOW_HEIGHT / 192, 0, 0.5)
    end

    -- draw music on/off image
    if isStop then
        if Sounds.musicSound:isPlaying() then
            drawQuadImage(Img.musicOnImg, WINDOW_WIDTH - TILE_SIZE * 2.8, TILE_SIZE, 0, 0.4)
        else
            drawQuadImage(Img.musicOffImg, WINDOW_WIDTH - TILE_SIZE * 2.8, TILE_SIZE, 0, 0.4)
        end
    end
end

function displayFPS()  -- display FPS on the top right corner
    love.graphics.setFont(Fonts.smallFont)
    love.graphics.setColor(0, 1, 0, 0.75)
    love.graphics.printf("FPS: " .. tostring(love.timer.getFPS()), 0, TILE_SIZE / 8, WINDOW_WIDTH, "right")
end

function drawGrid()  -- draw a grid depending on the type of tiles saved in tileGrid table
    for y = 1, MAX_TILES_Y do
        for x = 1, MAX_TILES_X do
            if tileGrid[y][x] == TILE_EMPTY and DrawLines and not isEnd then
                love.graphics.setColor(1, 1, 1, .15)  -- changed to 15% transparency for the grid
                love.graphics.rectangle("line", (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)

            elseif tileGrid[y][x] == OOBA           then drawTileImage(Img.oobaImg, x, y)
            elseif tileGrid[y][x] == BL_SNAKE1_HEAD then drawSnake(Img.BLsnake1headImg, x, y, BLrotationGrid[y][x])
            elseif tileGrid[y][x] == BL_SNAKE1_BODY then drawSnake(Img.BLsnake1bodyImg, x, y, BLrotationGrid[y][x])
            elseif tileGrid[y][x] == BL_SNAKE1_TAIL then drawSnake(Img.BLsnake1tailImg, x, y, BLsnakeTiles[#BLsnakeTiles - 1][3])
            elseif tileGrid[y][x] == BL_SNAKE1_TURN_1 then drawTileImage(Img.BLsnake1turn1Img, x, y)
            elseif tileGrid[y][x] == BL_SNAKE1_TURN_2 then drawTileImage(Img.BLsnake1turn2Img, x, y)
            elseif tileGrid[y][x] == BL_SNAKE1_TURN_3 then drawTileImage(Img.BLsnake1turn3Img, x, y)
            elseif tileGrid[y][x] == BL_SNAKE1_TURN_4 then drawTileImage(Img.BLsnake1turn4Img, x, y)            
            elseif tileGrid[y][x] == STONE          then drawTileImage(Img.stoneImg, x, y)
            elseif tileGrid[y][x] == RD_SNAKE2_HEAD then drawSnake(Img.RDsnake2headImg, x, y, RDrotationGrid[y][x])
            elseif tileGrid[y][x] == RD_SNAKE2_BODY then drawSnake(Img.RDsnake2bodyImg, x, y, RDrotationGrid[y][x])
            elseif tileGrid[y][x] == RD_SNAKE2_TAIL then drawSnake(Img.RDsnake2tailImg, x, y, RDsnakeTiles[#RDsnakeTiles - 1][3])
            elseif tileGrid[y][x] == RD_SNAKE2_TURN_1 then drawTileImage(Img.RDsnake2turn1Img, x, y)
            elseif tileGrid[y][x] == RD_SNAKE2_TURN_2 then drawTileImage(Img.RDsnake2turn2Img, x, y)
            elseif tileGrid[y][x] == RD_SNAKE2_TURN_3 then drawTileImage(Img.RDsnake2turn3Img, x, y)
            elseif tileGrid[y][x] == RD_SNAKE2_TURN_4 then drawTileImage(Img.RDsnake2turn4Img, x, y)
            end
        end
    end
end

function drawQuadImage(quad, x, y, rotation, transparency)
    -- draw quad from spriteSheet with optional rotation or transparency
    rotation = rotation or 0  -- default value is 0
    transparency = transparency or 1  -- default value is 1
    love.graphics.setColor(1, 1, 1, transparency)
    love.graphics.draw(Img.spriteSheet, quad, x, y, rotation)
end

function drawTileImage(image, x, y)
    drawQuadImage(image, (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE)  -- draw non-transparent tiles
end

function drawSnake(image, x, y, movementDirection)
    -- since img is rotated around its top left corner we need to change coordinates depending on the movement direction in rotationGrid
    if movementDirection == DOWN then
        drawQuadImage(image, (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE, 0)
    elseif movementDirection == UP then
        drawQuadImage(image, (x + 0) * TILE_SIZE, (y - 0) * TILE_SIZE, math.pi)  -- note that rotation has to be in radians
    elseif movementDirection == LEFT then
        drawQuadImage(image, (x - 0) * TILE_SIZE, (y - 1) * TILE_SIZE, math.pi / 2)
    else
        drawQuadImage(image, (x - 1) * TILE_SIZE, (y - 0) * TILE_SIZE, -math.pi / 2)
    end
end

function generateObstacle(obstacle)
    repeat
        obstacleX, obstacleY = math.random(MAX_TILES_X), math.random(MAX_TILES_Y)  -- get random coordinates
    until(tileGrid[obstacleY][obstacleX] == TILE_EMPTY)  -- makes sure not to overlap obstacles

    tileGrid[obstacleY][obstacleX] = obstacle
end

function clearSnake()  -- clear tileGrid from snakes data
    for i, elem in pairs(RDsnakeTiles) do
        tileGrid[elem[2]][elem[1]] = TILE_EMPTY
    end
    for i, elem in pairs(BLsnakeTiles) do
        tileGrid[elem[2]][elem[1]] = TILE_EMPTY
    end
end

function clearGrid()  -- populate tileGrid with all empty tiles
    for y = 1, MAX_TILES_Y do
        for x = 1, MAX_TILES_X do
            tileGrid[y][x] = TILE_EMPTY
        end
    end
end

function initializeSnake()
    -- create a snake that is (SNAKE_LEN) tiles long
    BLsnakeX, BLsnakeY = 6, 2  -- snake place on the grid
    BLsnakeMoving = RIGHT
    BLsnakeTiles = {}
    for sc = 0, SNAKE_LEN - 1 do
        table.insert(BLsnakeTiles, {BLsnakeX - sc, BLsnakeY, BLsnakeMoving})
    end
    for sc = 1, SNAKE_LEN do
        if sc == 1 then
            tileGrid[BLsnakeTiles[sc][2]][BLsnakeTiles[sc][1]] = BL_SNAKE1_HEAD
        elseif sc == SNAKE_LEN then
            tileGrid[BLsnakeTiles[sc][2]][BLsnakeTiles[sc][1]] = BL_SNAKE1_TAIL
        else
            tileGrid[BLsnakeTiles[sc][2]][BLsnakeTiles[sc][1]] = BL_SNAKE1_BODY
        end
    end

    RDsnakeX, RDsnakeY = 30, 17
    RDsnakeMoving = RIGHT
    RDsnakeTiles = {}
    for sc = 0, SNAKE_LEN - 1 do
        table.insert(RDsnakeTiles, {RDsnakeX - sc, RDsnakeY, RDsnakeMoving})
    end
    for sc = 1, SNAKE_LEN do
        if sc == 1 then
        tileGrid[RDsnakeTiles[sc][2]][RDsnakeTiles[sc][1]] = RD_SNAKE2_HEAD
        elseif sc == SNAKE_LEN then
        tileGrid[RDsnakeTiles[sc][2]][RDsnakeTiles[sc][1]] = RD_SNAKE2_TAIL
        else
        tileGrid[RDsnakeTiles[sc][2]][RDsnakeTiles[sc][1]] = RD_SNAKE2_BODY
        end
    end
end

function initializeGrid()
    tileGrid = {}
    for y = 1, MAX_TILES_Y do
        table.insert(tileGrid, {})
        for x = 1, MAX_TILES_X do
            table.insert(tileGrid[y], TILE_EMPTY)
        end
    end

    if STONES_MAX_N == 30 then
        for i = 1, math.max(21, math.random(STONES_MAX_N)) do  -- generate a random number of stones between 21 and 30
            generateObstacle(STONE)
        end
    elseif STONES_MAX_N == 20 then
        for i = 1, math.max(11, math.random(STONES_MAX_N)) do  -- generate a random number of stones between 11 and 20
            generateObstacle(STONE)
        end
    elseif STONES_MAX_N == 10 then
        for i = 1, math.max(1, math.random(STONES_MAX_N)) do  -- generate a random number of stones between 1 and 10
            generateObstacle(STONE)
        end
    else
        for i = 1, math.max(2, math.random(STONES_MAX_N)) do  -- generate a random number of stones between 2 and 8
            generateObstacle(STONE)
        end
    end

    generateObstacle(OOBA)
end

function initializeRotationGrid()  -- we create rotation grid for both snakes in order to correctly rotate snake head, body and tail
    BLrotationGrid = {}
    RDrotationGrid = {}
    for y = 1, MAX_TILES_Y do
        table.insert(BLrotationGrid, {})
        table.insert(RDrotationGrid, {})
        for x = 1, MAX_TILES_X do
            table.insert(BLrotationGrid[y], 0)
            table.insert(RDrotationGrid[y], 0)
        end
    end
end