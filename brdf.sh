lualut="D:\LuaLUT\LuaLUT\bin\Release\net6.0\LuaLUT.exe"
sampleCount=16

$lualut --script "./lua/BRDF.lua" --out "preview/" --img PNG --format RG --type UNSIGNED_BYTE -w 128 -h 128 -v "SAMPLE_COUNT=$sampleCount"
$lualut --script "./lua/BRDF.lua" --out "../src/shaders/textures/" --img RAW --format RG --type HALF_FLOAT -w 128 -h 128 -v "SAMPLE_COUNT=$sampleCount"
