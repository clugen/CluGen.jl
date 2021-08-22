# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test clusizes
@testset "clusizes" begin
    @testset "seed=$(Int(rng.seed[1])), nclu=$nclu, tot_points=$tpts, dist=$cs_dist_name, allow_empty=$ae" for
        rng in rngs,
        nclu in num_clusters,
        tpts in total_points,
        (cs_dist_name, cs_dist_fn) in clusize_dists,
        ae in allow_empties

        # Don't test if number of points is less than number of
        # clusters and we don't allow empty clusters
        if !ae && tpts < nclu
            continue
        end

        # Get the actual function to use
        dist_fn = cs_dist_fn(rng, nclu)

        # Check that the clusizes function runs without warnings
        clu_sizes = @test_nowarn clusizes(tpts, ae, dist_fn)

        # Check that the output has the correct number of clusters
        @test size(clu_sizes) == (nclu, )

        # Check that the total number of points is correct
        @test sum(clu_sizes) == tpts

        # If empty clusters are not allowed, check that all of them have points
        ae || @test minimum(clu_sizes) > 0
    end
end