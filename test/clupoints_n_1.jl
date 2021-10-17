# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test clupoints_n_1
@testset "clupoints_n_1" begin

    # Number of line directions to test
    ndirs = 3

    # Number of line centers to test
    ncts = 3

    @testset """
        nd=$nd, tpts=$tpts, seed=$(Int(rng.seed[1])), lat_std=$lat_std,
        length=$length, dir=$dir, ctr=$ctr"
        """ for
        # Only for num_dims > 1
        nd in filter((x) ->  x > 1, num_dims),
        # Avoid too many points, otherwise testing will be very slow
        tpts in filter((x) -> x < 1000, num_points),
        rng in rngs,
        lat_std in lat_stds,
        length in llengths_mus,
        dir in get_unitvecs(rng, ndirs, nd),
        ctr in get_vecs(rng, ncts, nd)

        # Create some point projections
        proj_dist_fn2ctr = length .* rand(rng, tpts) .- length / 2;
        proj = points_on_line(ctr, dir, proj_dist_fn2ctr)

        # Check that the clupoints_n_1 function runs without warnings
        pts = @test_nowarn CluGen.clupoints_n_1(proj, lat_std, length, dir, ctr; rng=rng)

        # Check that number of points is the same as the number of projections
        @test size(pts) == size(proj)

        # The point minus its projection should yield an approximately
        # orthogonal vector to the cluster line
        for u in eachrow(pts - proj)
            @test isapprox(dot(dir, u), 0, atol=1e-7)
        end

    end
end