-- Fonts.lua

-- Restora is an of old-style roman serif font family from Nasir Udin.

--[[ This function (love.graphics.newFont) can be slow if it is called repeatedly, 
    such as from love.update or love.draw. If you need to use a specific resource often, 
    create it once and store it somewhere it can be reused! ]]

return {
    smallFont = love.graphics.newFont("font/RestoraExtraLight.otf", 16),
    medFont = love.graphics.newFont("font/RestoraExtraLight.otf", 24),
    largeFont = love.graphics.newFont("font/RestoraExtraLight.otf", 32),
    XlargeFont = love.graphics.newFont("font/RestoraExtraLight.otf", 48),
    hugeFont = love.graphics.newFont("font/RestoraExtraLight.otf", 192),
}