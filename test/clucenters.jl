# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test clucenters
@testset "clucenters" begin
    @testset "nd=$nd, seed=$seed, nclu=$nclu, sep=$clu_sep, off=$clu_off, dist=$cc_dist_name" for
        nd in num_dims,
        seed in seeds,
        nclu in num_clusters,
        clu_sep in clu_seps(nd),
        clu_off in clu_offsets(nd),
        (cc_dist_name, cc_dist_fn) in clucenter_dists

        # Get the actual function to use
        dist_fn = cc_dist_fn(MersenneTwister(seed), nclu, nd)

        # Check that the clucenters function runs without warnings
        clu_ctrs = @test_nowarn clucenters(nclu, clu_sep, clu_off, dist_fn)

        # Check that return value has the correct dimensions
        @test size(clu_ctrs) == (nclu, nd)

    end
end