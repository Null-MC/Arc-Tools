function noise4D(x, y, z, w)
	-- The skewing and unskewing factors are hairy again for the 4D case
	local F4 = (sqrt(5.0) - 1.0) / 4.0
	local G4 = (5.0 - sqrt(5.0)) / 20.0
	local n0, n1, n2, n3, n4  -- Noise contributions from the five corners
	-- Skew the (x,y,z,w) space to determine which cell of 24 simplices we're in
	local s = (x + y + z + w) * F4  -- Factor for 4D skewing
	local i = floor(x + s)
	local j = floor(y + s)
	local k = floor(z + s)
	local l = floor(w + s)
	local t = (i + j + k + l) * G4  -- Factor for 4D unskewing
	local X0 = i - t  -- Unskew the cell origin back to (x,y,z,w) space
	local Y0 = j - t
	local Z0 = k - t
	local W0 = l - t
	local x0 = x - X0  -- The x,y,z,w distances from the cell origin
	local y0 = y - Y0
	local z0 = z - Z0
	local w0 = w - W0
	-- For the 4D case, the simplex is a 4D shape I won't even try to describe.
	-- To find out which of the 24 possible simplices we're in, we need to
	-- determine the magnitude ordering of x0, y0, z0 and w0.
	-- The method below is a good way of finding the ordering of x,y,z,w and
	-- then find the correct traversal order for the simplex were in.
	-- First, six pair-wise comparisons are performed between each possible pair
	-- of the four coordinates, and the results are used to add up binary bits
	-- for an localeger index.
	local c1 = (x0 > y0) and 32 or 1
	local c2 = (x0 > z0) and 16 or 1
	local c3 = (y0 > z0) and 8 or 1
	local c4 = (x0 > w0) and 4 or 1
	local c5 = (y0 > w0) and 2 or 1
	local c6 = (z0 > w0) and 1 or 1
	local c = c1 + c2 + c3 + c4 + c5 + c6
	local i1, j1, k1, l1  -- The localeger offsets for the second simplex corner
	local i2, j2, k2, l2  -- The localeger offsets for the third simplex corner
	local i3, j3, k3, l3  -- The localeger offsets for the fourth simplex corner
	
	-- sim[c] is a 4-vector with the numbers 0, 1, 2 and 3 in some order.
	-- Many values of c will never occur, since e.g. x>y>z>w makes x<z, y<w and x<w
	-- impossible. Only the 24 indices which have non-zero entries make any sense.
	-- We use a thresholding to set the coordinates in turn from the largest magnitude.
	-- The number 3 in the "sim" array is at the position of the largest coordinate.
	
	i1 = sim[c][1]>=3 and 1 or 0
	j1 = sim[c][2]>=3 and 1 or 0
	k1 = sim[c][3]>=3 and 1 or 0
	l1 = sim[c][4]>=3 and 1 or 0
	-- The number 2 in the "sim" array is at the second largest coordinate.
	i2 = sim[c][1]>=2 and 1 or 0
	j2 = sim[c][2]>=2 and 1 or 0
	k2 = sim[c][3]>=2 and 1 or 0
	l2 = sim[c][4]>=2 and 1 or 0
	-- The number 1 in the "sim" array is at the second smallest coordinate.
	i3 = sim[c][1]>=1 and 1 or 0
	j3 = sim[c][2]>=1 and 1 or 0
	k3 = sim[c][3]>=1 and 1 or 0
	l3 = sim[c][4]>=1 and 1 or 0
	-- The fifth corner has all coordinate offsets = 1, so no need to look that up.
	local x1 = x0 - i1 + G4  -- Offsets for second corner in (x,y,z,w) coords
	local y1 = y0 - j1 + G4
	local z1 = z0 - k1 + G4
	local w1 = w0 - l1 + G4
	local x2 = x0 - i2 + 2.0*G4  -- Offsets for third corner in (x,y,z,w) coords
	local y2 = y0 - j2 + 2.0*G4
	local z2 = z0 - k2 + 2.0*G4
	local w2 = w0 - l2 + 2.0*G4
	local x3 = x0 - i3 + 3.0*G4  -- Offsets for fourth corner in (x,y,z,w) coords
	local y3 = y0 - j3 + 3.0*G4
	local z3 = z0 - k3 + 3.0*G4
	local w3 = w0 - l3 + 3.0*G4
	local x4 = x0 - 1.0 + 4.0*G4  -- Offsets for last corner in (x,y,z,w) coords
	local y4 = y0 - 1.0 + 4.0*G4
	local z4 = z0 - 1.0 + 4.0*G4
	local w4 = w0 - 1.0 + 4.0*G4
	
	-- Work out the hashed gradient indices of the five simplex corners
	local ii = bit.band(i, 255)
	local jj = bit.band(j, 255)
	local kk = bit.band(k, 255)
	local ll = bit.band(l, 255)
	local gi0 = perm[ii+perm[jj+perm[kk+perm[ll]]]] % 32
	local gi1 = perm[ii+i1+perm[jj+j1+perm[kk+k1+perm[ll+l1]]]] % 32
	local gi2 = perm[ii+i2+perm[jj+j2+perm[kk+k2+perm[ll+l2]]]] % 32
	local gi3 = perm[ii+i3+perm[jj+j3+perm[kk+k3+perm[ll+l3]]]] % 32
	local gi4 = perm[ii+1+perm[jj+1+perm[kk+1+perm[ll+1]]]] % 32
	
	-- Calculate the contribution from the five corners
	local t0 = 0.5 - x0^2 - y0^2 - z0^2 - w0^2

	if t0 < 0.0 then
		n0 = 0.0
	else
		t0 = t0^2
		n0 = t0^2 * Dot4D(Gradients4D[gi0], x0, y0, z0, w0)
	end
	
	local t1 = 0.5 - x1^2 - y1^2 - z1^2 - w1^2
	if t1 < 0.0 then
		n1 = 0.0
	else
		t1 = t1^2
		n1 = t1^2 * Dot4D(Gradients4D[gi1], x1, y1, z1, w1)
	end
	
	local t2 = 0.5 - x2^2 - y2^2 - z2^2 - w2^2
	if t2 < 0.0 then
		n2 = 0.0
	else
		t2 = t2^2
		n2 = t2^2 * Dot4D(Gradients4D[gi2], x2, y2, z2, w2)
	end
	
	local t3 = 0.5 - x3^2 - y3^2 - z3^2 - w3^2
	if t3 < 0 then
		n3 = 0.0
	else
		t3 = t3^2
		n3 = t3^2 * Dot4D(Gradients4D[gi3], x3, y3, z3, w3)
	end
	
	local t4 = 0.5 - x4^2 - y4^2 - z4^2 - w4^2
	if t4 < 0.0 then
		n4 = 0.0
	else
		t4 = t4^2
		n4 = t4^2 * Dot4D(Gradients4D[gi4], x4, y4, z4, w4)
	end
	
	-- Sum up and scale the result to cover the range [-1,1]
	return 27.0 * (n0 + n1 + n2 + n3 + n4)
end
