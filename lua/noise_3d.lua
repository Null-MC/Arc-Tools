function hash14(p4)
    p4 = fract(p4 * vec(0.1031, 0.1030, 0.0973, 0.1099))
    p4 = p4 + dot(p4, p4.wzxy + 33.33)
    return fract((p4.x + p4.y) * (p4.z + p4.w))
end

function smoothify(x)
    return x^2 * (3.0 - 2.0 * x)
end

function tileable3DNoise(coord, seed, wrap)
    local fractCoord  = fract(coord)
    local floorCoord  = mod(coord - fractCoord, wrap)
    local ceilCoord   = mod(floorCoord + 1.0, wrap)
    local smoothCoord = smoothify(fractCoord)
    
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
