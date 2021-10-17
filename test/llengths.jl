# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test llengths
@testset "llengths" begin
    @testset """
        nd=$nd, seed=$(Int(rng.seed[1])), nclu=$nclu, llength_mu=$llength_mu,
        llength_sigma=$llength_sigma
        """ for
        rng in rngs,
        nd in num_dims,
        nclu in num_clusters,
        llength_mu in llengths_mus,
        llength_sigma = llengths_sigmas

        # Check that the llengths function runs without warnings
        lens = @test_nowarn CluGen.llengths(nclu, llength_mu, llength_sigma; rng=rng)

        # Check that return value has the correct dimensions
        @test size(lens) == (nclu, )

        # Check that all lengths are >= 0
        @test all(map((x) ->  x >= 0, lens))

    end
end