﻿require "lua.atmosphere"

-- Buffer A generates the Transmittance LUT. Each pixel coordinate corresponds to a height and sun zenith angle, and
-- the value is the transmittance from that point to sun, through the atmosphere.

function processTexel(x, y, z)
    local sunCosTheta = 2.0*x - 1.0
    local sunTheta = safeacos(sunCosTheta)
    local height = mix(groundRadiusMM, atmosphereRadiusMM, y)
    
    local pos = vec(0.0, height, 0.0)
    local sunDir = normalize(vec(0.0, sunCosTheta, -sin(sunTheta)))

    local rain = 0.0
    if imageDepth > 1 then
        rain = z - (0.5 / imageDepth)
        rain = rain * imageDepth
        rain = rain / (imageDepth - 1)
    end
    
    return getSunTransmittance(pos, sunDir, rain)
end
