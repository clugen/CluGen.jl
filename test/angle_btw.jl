# Copyright (c) 2020-2023 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test angle_btw
@testset "angle_btw" begin

    # Commonly used function for determining the angle between two vectors
    common_angle_btw(u, v) = acos(dot(u, v) / (norm(u) * norm(v)))

    # 2D
    u = [1.5, 0]
    v = [0.1, -0.4]
    @test angle_btw(u, v) ≈ common_angle_btw(u, v)

    # 3D
    u = [-1.5, 10, 0]
    v = [0.99, 4.4, -1.1]
    @test angle_btw(u, v) ≈ common_angle_btw(u, v)

    # 8D
    u = [1.5, 0, 0, 0, 0, 0, 0, -0.5]
    v = [7.5, -0.4, 0, 0, 0, -16.4, 0.1, -0.01]
    @test angle_btw(u, v) ≈ common_angle_btw(u, v)
end