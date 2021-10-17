# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test angle_deltas
@testset "angle_deltas" begin
    @testset "seed=$(Int(rng.seed[1])), nclu=$nclu, astd=$astd" for
        rng in rngs,
        nclu in num_clusters,
        astd in angles_stds

        # Check that the angle_deltas function runs without warnings
        angles = @test_nowarn CluGen.angle_deltas(nclu, astd; rng=rng)

        # Check that return value has the correct dimensions
        @test size(angles) == (nclu, )

        # Check that all angles are between -π/2 and π/2
        @test all(-π/2 .<= angles .<= π/2)

    end
end