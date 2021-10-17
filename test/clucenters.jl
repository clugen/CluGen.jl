# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test clucenters
@testset "clucenters" begin
    @testset """
        nd=$nd, seed=$(Int(rng.seed[1])), nclu=$nclu, sep=$clu_sep, off=$clu_off
        """ for
        nd in num_dims,
        rng in rngs,
        nclu in num_clusters,
        clu_sep in get_clu_seps(nd),
        clu_off in get_clu_offsets(nd)

        # Check that the clucenters function runs without warnings
        clu_ctrs = @test_nowarn CluGen.clucenters(nclu, clu_sep, clu_off; rng=rng)

        # Check that return value has the correct dimensions
        @test size(clu_ctrs) == (nclu, nd)

    end
end