-- Img.lua

-- load spriteSheet
if TILE_SIZE == 20 then
    spriteSheet = love.graphics.newImage("image/small tiles.png")
else
    spriteSheet = love.graphics.newImage("image/large tiles.png")
end

local function genQuad(x, y, quadSize)
    quadSize = quadSize or TILE_SIZE -- TILE_SIZE is default
    return love.graphics.newQuad(x * TILE_SIZE, y * TILE_SIZE, quadSize, quadSize, spriteSheet:getDimensions())
end

return {
    spriteSheet = spriteSheet,
    musicOffImg = genQuad(3, 1, 2 * TILE_SIZE),
    musicOnImg = genQuad(3, 3, 2 * TILE_SIZE),
    oobaImg = genQuad(0, 5),
    BheartImg = genQuad(4, 0),
    RheartImg = genQuad(3, 0),
    BLsnake1headImg = genQuad(0, 0),
    BLsnake1bodyImg = genQuad(0, 1),
    BLsnake1tailImg = genQuad(0, 2),
    BLsnake1turn1Img = genQuad(1, 0),
    BLsnake1turn2Img = genQuad(1, 2),
    BLsnake1turn3Img = genQuad(1, 1),
    BLsnake1turn4Img = genQuad(1, 3),
    stoneImg = genQuad(2, 4),
    RDsnake2headImg = genQuad(0, 3),
    RDsnake2bodyImg = genQuad(0, 4),
    RDsnake2tailImg = genQuad(1, 4),
    RDsnake2turn1Img = genQuad(2, 0),
    RDsnake2turn2Img = genQuad(2, 2),
    RDsnake2turn3Img = genQuad(2, 1),
    RDsnake2turn4Img = genQuad(2, 3),
}