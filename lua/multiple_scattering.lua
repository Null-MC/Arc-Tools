require "lua.atmosphere"

-- Buffer B is the multiple-scattering LUT. Each pixel coordinate corresponds to a height and sun zenith angle, and
-- the value is the multiple scattering approximation (Psi_ms from the paper, Eq. 10).
local groundAlbedo = vec(0.3, 0.3, 0.3)
local mulScattSteps = 20
local sqrtSamples = 8.0


function getSphericalDir(theta, phi)
    local cosPhi = cos(phi)
    local sinPhi = sin(phi)
    local cosTheta = cos(theta)
    local sinTheta = sin(theta)
    return vec(sinPhi * sinTheta, cosPhi, sinPhi * cosTheta)
end

function getMiePhase(cosTheta)
    local g = 0.8
    local scale = 3.0 / (8.0 * PI)
    
    local num = (1.0 - g^2) * (1.0 + cosTheta^2)
    local denom = (2.0 + g^2) * (1.0 + g^2 - 2.0*g*cosTheta)^1.5
    
    return scale * num / denom
end

function getRayleighPhase(cosTheta)
    local k = 3.0 / (16.0 * PI)
    return k * (1.0 + cosTheta^2)
end

function getValFromTLUT(pos, sunDir, rain)
    local height = length(pos);
    local up = pos / height;
    local sunCosZenithAngle = dot(sunDir, up);

    local u = clamp(0.5 + 0.5*sunCosZenithAngle, 0.0, 1.0)
    local v = max(0.0, min(1.0, (height - groundRadiusMM) / (atmosphereRadiusMM - groundRadiusMM)))

    return texture('sun_transmission', vec(u, v, rain)).rgb;
end

-- Calculates Equation (5) and (7) from the paper.
function getMulScattValues(pos, sunDir, rain)
    local lumTotal = vec(0.0, 0.0, 0.0)
    local fms = vec(0.0, 0.0, 0.0)
    
    local invSamples = 1.0 / sqrtSamples^2
    for i = 0.0,sqrtSamples-1.0,1.0 do
        for j = 0.0,sqrtSamples-1.0,1.0 do
            -- This integral is symmetric about theta = 0 (or theta = PI), so we
            -- only need to integrate from zero to PI, not zero to 2*PI.
            local theta = PI * (i + 0.5) / sqrtSamples
            local phi = safeacos(1.0 - 2.0*(j + 0.5) / sqrtSamples)
            local rayDir = getSphericalDir(theta, phi)
            
            local atmoDist = rayIntersectSphere(pos, rayDir, atmosphereRadiusMM)
            local groundDist = rayIntersectSphere(pos, rayDir, groundRadiusMM)

            local tMax = atmoDist
            if groundDist > 0.0 then
                tMax = groundDist
            end
            
            local cosTheta = dot(rayDir, sunDir)
    
            local miePhaseValue = getMiePhase(cosTheta)
            local rayleighPhaseValue = getRayleighPhase(-cosTheta)
            
            local lum = vec(0.0, 0.0, 0.0)
            local lumFactor = vec(0.0, 0.0, 0.0)
            local transmittance = vec(1.0, 1.0, 1.0)
            local t = 0.0

            for stepI = 0.0,mulScattSteps-1,1.0 do
                local newT = ((stepI + 0.3) / mulScattSteps) * tMax
                local dt = newT - t
                t = newT

                local newPos = pos + t*rayDir
                local rayleighScattering, mieScattering, extinction = getScatteringValues(newPos, rain)
                local sampleTransmittance = exp(-dt*extinction)
                
                -- Integrate within each segment.
                local scatteringNoPhase = rayleighScattering + mieScattering
                local scatteringF = (scatteringNoPhase - scatteringNoPhase * sampleTransmittance) / extinction
                lumFactor = lumFactor + transmittance * scatteringF
                
                -- This is slightly different from the paper, but I think the paper has a mistake?
                -- In equation (6), I think S(x,w_s) should be S(x-tv,w_s).
                local sunTransmittance = getValFromTLUT(newPos, sunDir, rain)

                local rayleighInScattering = rayleighScattering * rayleighPhaseValue
                local mieInScattering = mieScattering * miePhaseValue
                local inScattering = (rayleighInScattering + mieInScattering) * sunTransmittance

                -- Integrated scattering within path segment.
                local scatteringIntegral = (inScattering - inScattering * sampleTransmittance) / extinction

                lum = lum + scatteringIntegral * transmittance
                transmittance = transmittance * sampleTransmittance
            end
            
            if groundDist > 0.0 then
                local hitPos = pos + groundDist*rayDir
                if dot(pos, sunDir) > 0.0 then
                    hitPos = normalize(hitPos) * groundRadiusMM
                    lum = lum + transmittance * groundAlbedo * getValFromTLUT(hitPos, sunDir, rain)
                end
            end
            
            fms = fms + lumFactor * invSamples
            lumTotal = lumTotal + lum * invSamples
        end
    end

    return lumTotal, fms
end

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
    
    local lum, f_ms = getMulScattValues(pos, sunDir, rain)
    
    -- Equation 10 from the paper.
    local result = lum / (1.0 - f_ms)
    --result = result^(1.0/2.2)
    return result
end
