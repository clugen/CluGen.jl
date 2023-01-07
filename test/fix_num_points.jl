# Copyright (c) 2020-2023 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test fix_num_points!
@testset "fix_num_points!" begin

    # No change
    clusts = [10; 100; 42; 0; 12]
    clusts_copy = clusts[:]
    clusts_fixed = CluGen.fix_num_points!(clusts, sum(clusts))
    @test clusts === clusts_fixed
    @test clusts_copy == clusts_fixed

    # Fix due to too many points
    clusts = [55; 12]
    clusts_copy = clusts[:]
    num_pts = sum(clusts) - 14
    clusts_fixed = CluGen.fix_num_points!(clusts, num_pts)
    @test clusts === clusts_fixed
    @test clusts_copy != clusts_fixed
    @test sum(clusts_fixed) == num_pts

    # Fix due to too few points
    clusts = [0; 1; 0; 0]
    clusts_copy = clusts[:]
    num_pts = 15
    clusts_fixed = CluGen.fix_num_points!(clusts, num_pts)
    @test clusts === clusts_fixed
    @test clusts_copy != clusts_fixed
    @test sum(clusts_fixed) == num_pts

    # 1D - No change
    clusts = [10]
    clusts_copy = clusts[:]
    clusts_fixed = CluGen.fix_num_points!(clusts, sum(clusts))
    @test clusts === clusts_fixed
    @test clusts_copy == clusts_fixed

    # 1D - Fix due to too many points
    clusts = [241]
    clusts_copy = clusts[:]
    num_pts = sum(clusts) - 20
    clusts_fixed = CluGen.fix_num_points!(clusts, num_pts)
    @test clusts === clusts_fixed
    @test clusts_copy != clusts_fixed
    @test sum(clusts_fixed) == num_pts

    # 1D - Fix due to too few points
    clusts = [0]
    clusts_copy = clusts[:]
    num_pts = 8
    clusts_fixed = CluGen.fix_num_points!(clusts, num_pts)
    @test clusts === clusts_fixed
    @test clusts_copy != clusts_fixed
    @test sum(clusts_fixed) == num_pts
end