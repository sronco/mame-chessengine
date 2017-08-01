# mame-chessengine
A MAME Lua plugin for interface emulated chess machine with UCI/XBoard GUI

Requires MAME >= 0.183

Anyway after installing the plugin you can play against the emulated Saitek RISC 2500 in XBoard
xboard -fcp "./mame64 -skip_gameinfo -plugin chessengine risc"

or watch a match between two machines
xboard -mm -fcp "./mame64 -skip_gameinfo -plugin chessengine ch2001" -scp "./mame64 -skip_gameinfo -plugin chessengine risc"
