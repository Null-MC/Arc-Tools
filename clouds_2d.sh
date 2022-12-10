lualut="D:\LuaLUT\LuaLUT\bin\Debug\net6.0\LuaLUT.exe"

$lualut --script "./lua/clouds_2d.lua" --out "preview/" --img "PNG" --format "R" --type HALF_FLOAT -w 256 -h 256 -i "./lua/noise_2d.lua"
$lualut --script "./lua/clouds_2d.lua" --out "../src/shaders/textures/" --img "RAW" --format "R" --type HALF_FLOAT -w 256 -h 256 -i "./lua/noise_2d.lua"
