groundRadiusMM = 1.360
atmosphereRadiusMM = 1.385
ozoneAbsorptionBase = vec(0.650, 1.881, 0.085) * 2.0
mieScatteringBase = 3.996
mieAbsorptionBase = 4.4
rayleighScatteringBase = vec(5.802, 13.558, 33.1) * 2.0
rayleighAbsorptionBase = 1.0

-- groundRadiusMM = 2.360
-- atmosphereRadiusMM = 2.370
-- ozoneAbsorptionBase = vec(0.650, 1.881, 0.085)
-- mieScatteringBase = 3.996 * 10
-- mieAbsorptionBase = 4.4 * 10
-- rayleighScatteringBase = vec(5.802, 13.558, 33.1)*2
-- rayleighAbsorptionBase = 4.0

transmittanceSteps = 40


function safeacos(x)
    return acos(clamp(x, -1.0, 1.0))
end

function rayIntersectSphere(pos, dir, radius)
    local NoV = dot(pos, dir)
    local c = dot(pos, pos) - radius^2

    if c > 0.0 and NoV > 0.0 then
        return -1.0
    end

    local discr = NoV^2 - c
    if discr < 0.0 then
        return -1.0
    end

    -- Special case: inside sphere, use far discriminant
    if discr > NoV^2 then
        return -NoV + sqrt(discr)
    end

    return -NoV - sqrt(discr)
end

function getScatteringValues(pos)
    local altitudeKM = (length(pos) - groundRadiusMM) * 1000.0
    -- Note: Paper gets these switched up.
    local rayleighDensity = exp(-altitudeKM / 8.0)
    local mieDensity = exp(-altitudeKM / 1.2)
    
    local rayleighScattering = rayleighScatteringBase * rayleighDensity
    local rayleighAbsorption = rayleighAbsorptionBase * rayleighDensity
    
    local mieScattering = mieScatteringBase * mieDensity
    local mieAbsorption = mieAbsorptionBase * mieDensity
    
    local ozoneAbsorption = ozoneAbsorptionBase * max(0.0, 1.0 - abs(altitudeKM - 25.0) / 15.0)
    
    local extinction = rayleighScattering + rayleighAbsorption + mieScattering + mieAbsorption + ozoneAbsorption

    return rayleighScattering, mieScattering, extinction
end

function getSunTransmittance(pos, sunDir)
    if rayIntersectSphere(pos, sunDir, groundRadiusMM) > 0.0 then
        return vec(0.0, 0.0, 0.0)
    end
    
    local atmoDist = rayIntersectSphere(pos, sunDir, atmosphereRadiusMM)
    local transmittance = vec(1.0, 1.0, 1.0)
    local t = 0.0

    for i = 0,transmittanceSteps-1,1 do
        local newT = ((i + 0.3) / transmittanceSteps) * atmoDist
        local dt = newT - t
        t = newT
        
        local newPos = pos + t*sunDir
        local rayleighScattering, mieScattering, extinction = getScatteringValues(newPos)
        
        transmittance = transmittance * exp(-dt*extinction)
    end

    return transmittance
end
