# Touch Lua Emulator
**NOTE: This project is no longer in development. Although I can provide some support there will be no more releases.**

With this tool, you can run your Touch Lua programs on your computer, with little or no changes made to them. Right now it supports programs using draw and system library dating to Touch Lua 1.2 (before image and audio support were added) Lua SQLite3, Lua Matrix and Lua Complex are not included.

# Installation and use
- [Download](https://github.com/Croutonix/touch-lua-emulator/releases) the emulator and save it in any directory (you don't need to have lua installed)
- You can run example program by double-clicking on `run.bat`
- Open `config.lua` and adjust the settings (eg: screen size)
- To run your program, you can:
    - Drag and drop your file to `run.bat`
    - Edit `config.lua` and change file run by default and then run `run.bat`
    - Open command line in the emulator directory and do `run <filename>`
- Press ESC to exit, +/- to change zoom, 0 to reset zoom and ENTER to change screen orientation

## Screenshots
<img src="/example.png" width="300px" alt="Example program"/>

## Usage notes
- Your program might be accessing or writing files, and they are going to be written in the main directory. If you want them to be in another directory, you'll have to change the path in your code.
- If it has a main game loop which does not contain draw.doevents(), you won't be able to zoom, change orientation or close your program with ESC. (only by closing with console or killing the task) This is because draw.doevents() is used to do the emulator events too. If you don't want to do your program events, just the emulator's, add draw.doevents(false)
- I recommend adding a short delay (10ms) between each frame to prevent CPU overload.

## Fonts and alerts
Some fonts from your device are matched with equivalent fonts found on computers. There are only 6 matched fonts by default and only Helvetica supports text with styles (bold, italic...). If you need to add new fonts, add the font file in `res/font/` (needs to be .ttf) Then add a new match in config.lua: `["<device font>"] = "<filename.ttf>"`. If you need to add alerts, add the mp3 file in `res/sound/`. Could be useful to replace audio library for now?

# License
- Licensed under Apache 2.0
- Sounds are licensed under CC0 1.0 Universal
- I should not be using Helvetica but I am
