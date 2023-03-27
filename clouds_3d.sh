lualut="D:\LuaLUT\LuaLUT\bin\Release\net6.0\LuaLUT.exe"

$lualut --script "./lua/clouds_3d.lua" --out "preview/" --img "PNG" --format "RG" --type HALF_FLOAT -w 256 -h 256 -d 64 -z 32
$lualut --script "./lua/clouds_3d.lua" --out "../src/shaders/textures/" --img "RAW" --format "RG" --type HALF_FLOAT -w 256 -h 256 -d 64
