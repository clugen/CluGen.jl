# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test clupoints_n
@testset "clupoints_n" begin

    # Number of line directions to test
    ndirs = 3

    # Number of line centers to test
    ncts = 3

    @testset """
        nd=$nd, tpts=$tpts, seed=$(Int(rng.seed[1])), lat_std=$lat_std,
        length=$length, dir=$dir, ctr=$ctr
        """ for
        nd in num_dims,
        tpts in num_points,
        rng in rngs,
        lat_std in lat_stds,
        length in llengths_mus,
        dir in get_unitvecs(rng, ndirs, nd),
        ctr in get_vecs(rng, ncts, nd)

        # Create some point projections
        proj_dist_fn2ctr = length .* rand(rng, tpts) .- length / 2
        proj = points_on_line(ctr, dir, proj_dist_fn2ctr)

        # Check that the clupoints_n function runs without warnings
        pts = @test_nowarn CluGen.clupoints_n(proj, lat_std, length, dir, ctr; rng=rng)

        # Check that number of points is the same as the number of projections
        @test size(pts) == size(proj)

    end
end