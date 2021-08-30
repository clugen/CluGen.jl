# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test rand_vector_at_angle
@testset "rand_vector_at_angle" begin

    # How many vectors to test?
    nvec = 10

    # How many angles to test?
    nang = 10

    @testset "u=$u, a=$a, seed=$(Int(rng.seed[1]))" for
        nd in num_dims,
        rng in rngs,
        u in get_vecs(rng, nvec, nd),
        a in get_angles(rng, nang)

        # Check that the rand_ortho_vector function runs without warnings
        r = @test_nowarn rand_vector_at_angle(u, a; rng=rng)

        # Check that returned vector has the correct dimensions
        @test size(r) == (nd, )

        # Check that returned vector has norm == 1
        @test norm(r) ≈ 1

        # Check that vectors u and r have an angle of a between them
        if nd > 1 && abs(a) < pi/2
            @test angle(u, r) ≈ abs(a) atol=1e-12
        end

    end
end