# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test rand_unit_vector
@testset "rand_unit_vector" begin
    @testset "nd=$nd, seed=$seed" for
        nd in num_dims,
        seed in seeds

        # Check that the rand_unit_vector function runs without warnings
        r = @test_nowarn rand_unit_vector(nd; rng=MersenneTwister(seed))

        # Check that returned vector has the correct dimensions
        @test size(r) == (nd, )

        # Check that returned vector has norm == 1
        @test norm(r) ≈ 1

    end
end