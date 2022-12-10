local SEED = 467456

function easeIn(interpolator)
    return interpolator^2
end

function easeOut(interpolator)
    return 1.0 - easeIn(1.0 - interpolator)
end

function easeInOut(interpolator)
    local easeInValue = easeIn(interpolator)
    local easeOutValue = easeOut(interpolator)
    return mix(easeInValue, easeOutValue, interpolator)
end

function rand3dTo1d(value, dotDir)
    local smallValue = sin(value)
    local random = dot(smallValue, dotDir)
    return fract(sin(random) * 143758.5453)
end

function rand3dTo3d(value)
    local v1 = rand3dTo1d(value, vec(12.989, 78.233, 37.719))
    local v2 = rand3dTo1d(value, vec(39.346, 11.135, 83.155))
    local v3 = rand3dTo1d(value, vec(73.156, 52.235, 09.151))

    return vec(v1, v2, v3)
end

function perlinNoise(value)
    local fraction = fract(value)
    local interpolator = easeInOut(fraction)

    local cellNoiseZ = {}

    for z = 0,1 do
        local cellNoiseY = {}

        for y = 0,1 do
            local cellNoiseX = {}

            for x = 0,1 do
                local cell = floor(value) + vec(x, y, z)
                local cellDirection = rand3dTo3d(cell) * 2.0 - 1.0
                local compareVector = fraction - vec(x, y, z)
                cellNoiseX[x] = dot(cellDirection, compareVector)
            end

            cellNoiseY[y] = mix(cellNoiseX[0], cellNoiseX[1], interpolator.x)
        end

        cellNoiseZ[z] = mix(cellNoiseY[0], cellNoiseY[1], interpolator.y)
    end

    return mix(cellNoiseZ[0], cellNoiseZ[1], interpolator.z)
end

function processTexel(x, y, z)
    local pos = vec(x, y, z)
    return tileable3DNoise(pos * 16.0, SEED, vec(16, 16, 16))
end
