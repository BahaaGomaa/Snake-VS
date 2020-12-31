require "Fonts"

scoreLimit_buttons = {}
SNAKE_LIVES_buttons = {}
SNAKE_LEN_buttons = {}
SNAKE_SPEED_buttons = {}
STONES_buttons = {}

function add_length_button(x, y, text, id)
    table.insert(SNAKE_LEN_buttons, {x = x, y = y, text = text, id = id})
end
function add_lives_button(x, y, text, id)
    table.insert(SNAKE_LIVES_buttons, {x = x, y = y, text = text, id = id})
end
function add_score_button(x, y, text, id)
    table.insert(scoreLimit_buttons, {x = x, y = y, text = text, id = id})
end
function add_speed_button(x, y, text, id)
    table.insert(SNAKE_SPEED_buttons, {x = x, y = y, text = text, id = id})
end
function add_stone_button(x, y, text, id)
    table.insert(STONES_buttons, {x = x, y = y, text = text, id = id})
end

function draw_button()
    love.graphics.setFont(Fonts.largeFont)
    love.graphics.setColor(1, 1, 1, 1)
    for i, v in ipairs(SNAKE_LEN_buttons) do
        love.graphics.print(v.text, v.x, v.y)
    end
    for i, v in ipairs(SNAKE_LIVES_buttons) do
        love.graphics.print(v.text, v.x, v.y)
    end
    for i, v in ipairs(SNAKE_SPEED_buttons) do
        love.graphics.print(v.text, v.x, v.y)
    end
    for i, v in ipairs(scoreLimit_buttons) do
        love.graphics.print(v.text, v.x, v.y)
    end
    for i, v in ipairs(STONES_buttons) do
        love.graphics.print(v.text, v.x, v.y)
    end
end

function button_clicked(x, y)
    for i, v in ipairs(SNAKE_LEN_buttons) do
        if  x > v.x and x < v.x + Fonts.largeFont:getWidth(v.text) and y > v.y and y < v.y + Fonts.largeFont:getHeight(v.text) then
            SNAKE_LEN = v.id
        end
    end
    for i, v in ipairs(SNAKE_LIVES_buttons) do
        if  x > v.x and x < v.x + Fonts.largeFont:getWidth(v.text) and y > v.y and y < v.y + Fonts.largeFont:getHeight(v.text) then
            SET_LIVES = v.id
        end
    end
    for i, v in ipairs(scoreLimit_buttons) do
        if  x > v.x and x < v.x + Fonts.largeFont:getWidth(v.text) and y > v.y and y < v.y + Fonts.largeFont:getHeight(v.text) then
            scoreLimit = v.id
        end
    end
    for i, v in ipairs(STONES_buttons) do
        if  x > v.x and x < v.x + Fonts.largeFont:getWidth(v.text) and y > v.y and y < v.y + Fonts.largeFont:getHeight(v.text) then
            STONES_MAX_N = v.id
            STONES_txt = v.text
        end
    end
    for i, v in ipairs(SNAKE_SPEED_buttons) do
        if  x > v.x and x < v.x + Fonts.largeFont:getWidth(v.text) and y > v.y and y < v.y + Fonts.largeFont:getHeight(v.text) then
            SNAKE_SPEED = 0.1 - (v.id * 0.005)
            SNAKE_SPEED_txt = v.id
        end
    end
end
