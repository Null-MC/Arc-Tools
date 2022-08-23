﻿-- Buffer A generates the Transmittance LUT. Each pixel coordinate corresponds to a height and sun zenith angle, and
-- the value is the transmittance from that point to sun, through the atmosphere.

function processPixel(x, y)
    local u = x / imageWidth
    local v = y / imageHeight

    local sunCosTheta = 2.0*u - 1.0
    local sunTheta = safeacos(sunCosTheta)
    local height = mix(groundRadiusMM, atmosphereRadiusMM, v)
    
    local pos = vec(0.0, height, 0.0)
    local sunDir = normalize(vec(0.0, sunCosTheta, -sin(sunTheta)))
    
    return getSunTransmittance(pos, sunDir)
end
