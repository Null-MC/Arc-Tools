function mod289(x)
    return x - floor(x * rcp(289.0)) * 289.0
end

function permute(x)
    return mod289(((x * 34.0) + 1.0) * x)
end

function random2(st)
    local x = dot(st, vec(127.1, 311.7))
    local y = dot(st, vec(269.5, 183.3))

    return -1.0 + 2.0 * fract(sin(vec(x, y)) * 43758.5453123)
end

function value_noise(st)
    local i = floor(st)
    local f = fract(st)
    local u = f^2 * (3.0 - 2.0 * f)

    local a = random2(i + vec(0.0, 0.0))
    local b = random2(i + vec(1.0, 0.0))
    local c = random2(i + vec(0.0, 1.0))
    local d = random2(i + vec(1.0, 1.0))

    local x1 = mix(a, b, u.x)
    local x2 = mix(c, d, u.x)
    return mix(x1, x2, u.y)
end

function gradient_noise(st)
    local i = floor(st)
    local f = fract(st)
    local u = f^2 * (3.0 - 2.0 * f)

    local a = dot(random2(i + vec(0.0, 0.0)), f - vec(0.0, 0.0))
    local b = dot(random2(i + vec(1.0, 0.0)), f - vec(1.0, 0.0))
    local c = dot(random2(i + vec(0.0, 1.0)), f - vec(0.0, 1.0))
    local d = dot(random2(i + vec(1.0, 1.0)), f - vec(1.0, 1.0))

    local x1 = mix(a, b, u.x)
    local x2 = mix(c, d, u.x)
    return mix(x1, x2, u.y)
end

function simplex_noise(v)
    -- Precompute values for skewed triangular grid
    local C <const> = vec(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439)

    -- First corner (x0)
    local i  = floor(v + dot(v, C.yy))
    local x0 = v - i + dot(i, C.xx)

    -- Other two corners (x1, x2)
    --local i1 = vec2(0.0)
    local i1 = vec(0.0, 0.0)

    if x0.x > x0.y then
        i1.x = 1.0
    else
        i1.y = 1.0
    end

    local x1 = x0.xy + C.xx - i1
    local x2 = x0.xy + C.zz

    -- Do some permutations to avoid
    -- truncation effects in permutation
    i = mod289(i)
    local p1 = permute( i.y + vec(0.0, i1.y, 1.0))
    local p2 = permute(p1 + i.x + vec(0.0, i1.x, 1.0))

    local m = max(0.5 - vec(dot(x0, x0), dot(x1, x1), dot(x2, x2)), 0.0)

    m = m^4

    -- Gradients:
    --  41 pts uniformly over a line, mapped onto a diamond
    --  The ring size 17*17 = 289 is close to a multiple
    --      of 41 (41*7 = 287)

    local x = 2.0 * fract(p2 * C.www) - 1.0
    local h = abs(x) - 0.5
    local ox = floor(x + 0.5)
    local a0 = x - ox

    -- Normalise gradients implicitly by scaling m
    -- Approximation of: m *= inversesqrt(a0*a0 + h*h);
    m = m * (1.79284291400159 - 0.85373472095314 * (a0^2 + h^2))

    -- Compute final noise value at P
    local g = vec(0.0, 0.0, 0.0)
    g.x  = a0.x  * x0.x  + h.x  * x0.y
    g.yz = a0.yz * vec(x1.x, x2.x) + h.yz * vec(x1.y, x2.y)
    return 130.0 * dot(m, g)
end
