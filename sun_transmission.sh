lualut="D:\LuaLUT\LuaLUT\bin\Debug\net6.0\LuaLUT.exe"

$lualut --script "./lua/sun_transmission.lua" --out "preview/" --img "PNG" --format "RGB" --type HALF_FLOAT -w 256 -h 64 -i "./lua/atmosphere.lua"
$lualut --script "./lua/sun_transmission.lua" --out "../src/shaders/textures/" --img "RAW" --format "RGB" --type HALF_FLOAT -w 256 -h 64 -i "./lua/atmosphere.lua"
