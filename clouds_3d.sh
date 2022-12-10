lualut="D:\LuaLUT\LuaLUT\bin\Debug\net6.0\LuaLUT.exe"

$lualut --script "./lua/clouds_3d.lua" --out "preview/" --img "PNG" --format "R" --type HALF_FLOAT -w 256 -h 256 -d 64 -i "./lua/noise_3d.lua" -s 16
$lualut --script "./lua/clouds_3d.lua" --out "../src/shaders/textures/" --img "RAW" --format "R" --type HALF_FLOAT -w 256 -h 256 -d 64 -i "./lua/noise_3d.lua"
