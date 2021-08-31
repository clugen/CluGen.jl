# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test line_angles
@testset "line_angles" begin
    @testset "seed=$(Int(rng.seed[1])), nclu=$nclu, astd=$astd" for
        rng in rngs,
        nclu in num_clusters,
        astd in angles_stds

        # Check that the line_angles function runs without warnings
        angles = @test_nowarn line_angles(nclu, astd; rng=rng)

        # Check that return value has the correct dimensions
        @test size(angles) == (nclu, )

        # Check that all angles are between -π/2 and π/2
        @test all(-π/2 .<= angles .<= π/2)

    end
end