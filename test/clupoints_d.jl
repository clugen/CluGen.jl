# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Number of line directions to test
ndirs = 3

# Number of line centers to test
ncts = 3

# Test clupoints_d
@testset "clupoints_d" begin
    @testset """
        nd=$nd, tpts=$tpts, seed=$(Int(rng.seed[1])), lat_std=$lat_std,
        length=$length, dir=$dir, ctr=$ctr
        """ for
        # Only for num_dims > 1
        nd in filter((x) ->  x > 1, num_dims),
        tpts in total_points,
        rng in rngs,
        lat_std in lat_stds,
        length in line_lengths_mus,
        dir in get_vecs(rng, ndirs, nd),
        ctr in get_vecs(rng, ncts, nd)

        # Create some point projections
        proj_dist2ctr = length .* rand(rng, tpts) .- length / 2
        proj = points_from_line(ctr, dir, proj_dist2ctr)

        # Check that the clupoints_d function runs without warnings
        pts = @test_nowarn CluGen.clupoints_d(proj, lat_std, dir, ctr, rng)

        # Check that number of points is the same as the number of projections
        @test size(pts) == size(proj)

    end
end