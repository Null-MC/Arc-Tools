lualut="D:\LuaLUT\LuaLUT\bin\Debug\net6.0\LuaLUT.exe"

$lualut --script "./lua/multiple_scattering.lua" --out "../src/shaders/textures/" --img PNG --format RGB --type UNSIGNED_BYTE -w 32 -h 32 -i "./lua/atmosphere.lua"
$lualut --script "./lua/multiple_scattering.lua" --out "../src/shaders/textures/" --img RAW --format RGB --type HALF_FLOAT -w 32 -h 32 -i "./lua/atmosphere.lua"
