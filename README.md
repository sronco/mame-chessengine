# mame-chessengine
A MAME Lua plugin for interface emulated chess machine with UCI/XBoard GUI

Requires MAME >= 0.212

# To Install Plugin

Copy the folder chessengine to the plugins folder of your mame installation. Start Mame and enable the plugin. Ensure that you locally have installed lua5.3. "sudo apt-get install lua53" should work in Ubuntu.

# After installing plugin

Anyway after installing the plugin you can play against the emulated Saitek RISC 2500 in XBoard
xboard -fcp "./mame64 -skip_gameinfo -plugin chessengine risc"

or watch a match between two machines
xboard -mm -fcp "./mame64 -skip_gameinfo -plugin chessengine ch2001" -scp "./mame64 -skip_gameinfo -plugin chessengine risc"
