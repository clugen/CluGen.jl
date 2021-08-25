# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test rand_ortho_vector
@testset "rand_ortho_vector" begin

    # How many vectors to test?
    nvec = 10

    @testset "u=$u, seed=$(Int(rng.seed[1]))" for
        nd in num_dims,
        rng in rngs,
        u in get_vecs(rng, nvec, nd)

        # Check that the rand_ortho_vector function runs without warnings
        r = @test_nowarn rand_ortho_vector(u; rng=rng)

        # Check that returned vector has the correct dimensions
        @test size(r) == (nd, )

        # Check that returned vector has norm == 1
        @test norm(r) ≈ 1

        # Check that vectors u and r are orthogonal (only for nd > 1)
        if nd > 1
            # The dot product of orthogonal vectors must be (approximately) zero
            @test dot(u, r) ≈ 0 atol=1e-13
        end

    end
end