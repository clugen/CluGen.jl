# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test points_on_line
@testset "points_on_line" begin

    # Number of line directions to test
    ndirs = 3

    # Number of line centers to test
    ncts = 3

    @testset """
        nd=$nd, tpts=$tpts, seed=$(Int(rng.seed[1])), length=$length, dir=$dir, ctr=$ctr
        """ for
        nd in num_dims,
        # Avoid too many points, otherwise testing will be very slow
        tpts in filter((x) -> x < 1000, num_points),
        rng in rngs,
        length in line_lengths_mus,
        dir in get_unitvecs(rng, ndirs, nd),
        ctr in get_vecs(rng, ncts, nd)

        # Create some random distances from center
        dist2ctr = length .* rand(rng, tpts) .- length / 2

        # Check that the points_on_line function runs without warnings
        pts = @test_nowarn points_on_line(ctr, dir, dist2ctr)

        # Check that the dimensions agree
        @test size(pts) == (tpts, nd)

        # Check that distance of points to the line is approximately zero
        for pt in eachrow(pts)
            # Get distance from current point to line
            d = norm((pt - ctr) - dot(pt - ctr, dir) .* dir)
            # Check that it is approximately zero
            @test isapprox(d, 0, atol=1e-14)
        end

    end
end