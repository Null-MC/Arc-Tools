local VALUE_OCTAVES = 6
local VALUE_SEED = 684.513
local VALUE_SCALE = vec(16.0, 16.0, 4.0)

local WORLEY_SCALE = vec(48.0, 48.0, 12.0)
local WORLEY_SEED = 0.64684


function hash14(p4)
    p4 = fract(p4 * vec(0.1031, 0.1030, 0.0973, 0.1099))
    p4 = p4 + dot(p4, p4.wzxy + 33.33)
    return fract((p4.x + p4.y) * (p4.z + p4.w))
end

function hash24(p4)
    p4 = fract(p4 * vec(0.1031, 0.1030, 0.0973, 0.1099))
    p4 = p4 + dot(p4, p4.wzxy + 33.33)
    return fract((p4.x + p4.y) * (p4.z + p4.w));
end

function tileable3DNoise(coord, size, seed)
    local fractCoord  = fract(coord)
    local floorCoord  = mod(coord - fractCoord, size)
    local ceilCoord   = mod(floorCoord + 1.0, size)
    local smoothCoord = smoothstep(0.0, 1.0, fractCoord)
    
    return mix(
        mix(
            mix(
                hash14(vec(floorCoord.x, floorCoord.y, floorCoord.z, seed)),
                hash14(vec(floorCoord.x, floorCoord.y,  ceilCoord.z, seed)),
                smoothCoord.z
            ),
            mix(
                hash14(vec(floorCoord.x,  ceilCoord.y, floorCoord.z, seed)),
                hash14(vec(floorCoord.x,  ceilCoord.y,  ceilCoord.z, seed)),
                smoothCoord.z
            ),
            smoothCoord.y
        ),
        mix(
            mix(
                hash14(vec( ceilCoord.x, floorCoord.y, floorCoord.z, seed)),
                hash14(vec( ceilCoord.x, floorCoord.y,  ceilCoord.z, seed)),
                smoothCoord.z
            ),
            mix(
                hash14(vec( ceilCoord.x,  ceilCoord.y, floorCoord.z, seed)),
                hash14(vec( ceilCoord.x,  ceilCoord.y,  ceilCoord.z, seed)),
                smoothCoord.z
            ),
            smoothCoord.y
        ),
        smoothCoord.x
    )
end

function tileable3DWorleyNoise(coord, size, seed)
    local fractCoord = fract(coord)
    local floorCoord = mod(coord - fractCoord, size)
    local ceilCoord = mod(floorCoord + 1.0, size)
    local min_dist = 1.0

    for z = -1, 1
    do
        for y = -1, 1
        do
            for x = -1, 1
            do
                local neighbor = vec(x, y, z)
                local neighbor_wrapped = mod(floorCoord + neighbor, size)
                local point = hash24(vec(neighbor_wrapped, seed))
                local diff = neighbor + point - fractCoord
                local dist = length(diff)

                min_dist = min(min_dist, dist)
            end
        end
    end

    return min_dist
end

function fbm(coord, scale, octave_count)
    local amplitude = 0.5
    
    local value = 0.0;
    for i = 1, octave_count do
        value = value + amplitude * tileable3DNoise(coord * scale, scale, VALUE_SEED)
        amplitude = amplitude * 0.5
        scale = scale * 2.0
    end

    return value
end

function processTexel(x, y, z)
    local pos = vec(x, y, z)

    local value_fbm = fbm(pos, VALUE_SCALE, VALUE_OCTAVES)
    local worley_noise = tileable3DWorleyNoise(pos * WORLEY_SCALE, WORLEY_SCALE, WORLEY_SEED)

    return vec(value_fbm, worley_noise)
end
