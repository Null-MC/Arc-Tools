lualut="D:\LuaLUT\LuaLUT\bin\Debug\net6.0\LuaLUT.exe"
sunTransmissionSampler="../src/shaders/textures/sun_transmission.dat 256 64 5 RGB HALF_FLOAT"

# Generate RAW LUTs
printf "Generating sun transmission LUT\n"
$lualut --script "./lua/sun_transmission.lua" --out "../src/shaders/textures/" --img "RAW" --format "RGB" --type HALF_FLOAT -w 256 -h 64 -d 5

printf "Generating multiple scattering LUT\n"
$lualut --script "./lua/multiple_scattering.lua" --out "../src/shaders/textures/" --img RAW --format RGB --type HALF_FLOAT -w 32 -h 32 -d 5 -s "$sunTransmissionSampler"

# Generate Preview LUTs
printf "Generating sun transmission clear preview\n"
$lualut --script "./lua/sun_transmission.lua" --out "preview/sun_transmission_clear.png" --img "PNG" --format "RGB" --type HALF_FLOAT -w 256 -h 64 -d 5 -z 0

printf "Generating sun transmission rain preview\n"
$lualut --script "./lua/sun_transmission.lua" --out "preview/sun_transmission_rain.png" --img "PNG" --format "RGB" --type HALF_FLOAT -w 256 -h 64 -d 5 -z 1

printf "Generating sun transmission end preview\n"
$lualut --script "./lua/sun_transmission.lua" --out "preview/sun_transmission_end.png" --img "PNG" --format "RGB" --type HALF_FLOAT -w 256 -h 64 -d 5 -z 4

printf "Generating multiple scattering clear preview\n"
$lualut --script "./lua/multiple_scattering.lua" --out "preview/multiple_scattering_clear.png" --img PNG --format RGB --type UNSIGNED_BYTE -w 32 -h 32 -d 5 -z 0 -s "$sunTransmissionSampler"

printf "Generating multiple scattering rain preview\n"
$lualut --script "./lua/multiple_scattering.lua" --out "preview/multiple_scattering_rain.png" --img PNG --format RGB --type UNSIGNED_BYTE -w 32 -h 32 -d 5 -z 1 -s "$sunTransmissionSampler"

printf "Generating multiple scattering end preview\n"
$lualut --script "./lua/multiple_scattering.lua" --out "preview/multiple_scattering_end.png" --img PNG --format RGB --type UNSIGNED_BYTE -w 32 -h 32 -d 5 -z 4 -s "$sunTransmissionSampler"
