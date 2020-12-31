-- Sounds.lua

return {
    scoreSound = love.audio.newSource("sound/score.wav", "static"),
    winSound = love.audio.newSource("sound/win.wav", "static"),
    musicSound = love.audio.newSource("sound/music.mp3", "static"),
    hitSound = love.audio.newSource("sound/hit.wav", "static"),
    deathSound = love.audio.newSource("sound/death.wav", "static"),
}