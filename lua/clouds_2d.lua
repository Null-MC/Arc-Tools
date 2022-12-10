local NUM_OCTAVES = 5

function fbm(_st)
    local v = 0.0
    local a = 0.5
    local shift = vec(100.0, 100.0)

    -- Rotate to reduce axial bias
    local rot = mat(vec(cos(0.5), sin(0.5)), vec(-sin(0.5), cos(0.50)))

    for i = 0,NUM_OCTAVES,1
    do
        v = v + a * value_noise(_st)
        _st = rot * _st * 2.0 + shift
        a = a * 0.5
    end

    return v
end

function processTexel(x, y)
    local pos = vec(x, y)

    pos.x = pos.x * (imageWidth / imageHeight)

    return fbm(pos * 10.0) * 0.5 + 0.5
end
