# Snake VS

Snake VS is a two player snake game written in Lua to work with [LÖVE framework](https://love2d.org/).

The project is based on trivvz's code of CS50 youtube videos: [part 1](https://youtu.be/ld_xcXdRez4), [part 2](https://youtu.be/UOzRK3p26Dw)

snake50 is a Snake demo taught during [CS50tv Twitch](https://www.twitch.tv/cs50tv) livestream.

Original snake50 project files are available in [Colton Ogden's repository](https://github.com/coltonoscopy/snake50).

Snake Game is an enhanced version of snake50 that added some options and nicer graphics.

Original Snake Game project files are available in [Tomasz Wojdat's repository](https://github.com/trivvz/Snake-Game).

Original Snake VS project files are available in [Bahaa Gomaa's repository](https://github.com/BahaaGomaa/Snake-VS).

Game settings buttons idea from Sockmunkee Dev.

## List of changes in comparison to trivvz's version:

* Converted the game to 2 player mode.

* Added the ability to pause gameplay.

* Added the option to display FPS.

* Added a settings tap where you can change the following settings:
    * Snake speed (defaulted to 2)
    * Snake length (defaulted to 5)
    * Score needed to win (defaulted to 10)
    * Snakes "Players" lives (defaulted to 3)
    * Number of stones generated (defaulted to a random value between 2 and 8)

## How to play

There is a Blue snake and a Red snake fighting for score points.

If your snake head bumped into a stone or the rest of your body or the other snake you lose a life.

If the two snakes bumped head to head both players lose a life.

The goal is to reach the score limit while avoiding rocks and trying to block the other player from scoring.

Unless you are evil and your goal is to kill the other snake by cornering and forcing it to lose a life which also works.

Blue snake is controlled with WASD and Red snake is controlled with arrow keys.

If you reach the edge of the screen your snake will loop from the other side of it.

## Note that

* There is a known bug where fast player input could result in player death, 
e.g. making a quick turn from moving `LEFT` to `UP` and then to `RIGHT` before snake even moves by one tile which will result in instant collision with the rest of snake body and thus losing a life.

* Switching the option of drawing grid lines to off increases FPS by a good margin because it's treated as a tile grid object. (give it a try if you have a potato pc like me)

* You can change the variable TILE_SIZE to 20 in [main.lua](https://github.com/BahaaGomaa/Snake-VS/blob/main/main.lua). to play the game in a smaller version.

* Snake VS is made with a bit of creativity and some research plus a lot of copying and pasting =)

## To-Do list

* Fix the known bug which is most likely to be related to the core mechanics of the game aka Tile Grid.

* Add the ability to change default settings from a file (hopefully a .txt file).

* Add a setting to change game size aka Tile Size. (already prepared the assets)
