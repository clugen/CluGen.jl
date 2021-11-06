# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test clupoints_n_1_template
@testset "clupoints_n_1_template" begin

    # Number of line directions to test
    ndirs = 3

    # Number of line centers to test
    ncts = 3

    # Distance from points to projections will be 10
    dist_pt = 10

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
        proj_dist_fn2ctr = length .* rand(rng, tpts) .- length / 2
        proj = points_on_line(ctr, dir, proj_dist_fn2ctr)

        # Very simple dist_fn, always puts points at a distance of dist_pt
        dist_fn = (clu_num_points, ldisp) ->
            rand(rng, [-dist_pt, dist_pt], clu_num_points, 1)

        # Check that the clupoints_n_1_template function runs without warnings
        pts = @test_nowarn CluGen.clupoints_n_1_template(
            proj, lat_std, dir, dist_fn; rng=rng)

        # Check that number of points is the same as the number of projections
        @test size(pts) == size(proj)

        # For each vector from projection to point...
        for u in eachrow(pts - proj)
            # Vector should be approximately orthogonal to the cluster line
            @test isapprox(dot(dir, u), 0, atol=1e-7)
            # Vector should of a magnitude of approximately dist_pt
            @test norm(u) ≈ dist_pt
        end

    end
end