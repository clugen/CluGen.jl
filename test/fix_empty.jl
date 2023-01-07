# Copyright (c) 2020-2023 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test fix_empty!
@testset "fix_empty!" begin

    # No empty clusters
    clusts = [11; 21; 10]
    clusts_copy = clusts[:]
    clusts_fixed = CluGen.fix_empty!(clusts, false)
    @test clusts === clusts_fixed
    @test clusts_copy == clusts_fixed

    # Empty clusters, no fix
    clusts = [0; 11; 21; 10; 0; 0]
    clusts_copy = clusts[:]
    clusts_fixed = CluGen.fix_empty!(clusts, true)
    @test clusts === clusts_fixed
    @test clusts_copy == clusts_fixed

    # Empty clusters, fix
    clusts = [5; 0; 21; 10; 0; 0; 101]
    clusts_copy = clusts[:]
    clusts_fixed = CluGen.fix_empty!(clusts, false)
    @test clusts === clusts_fixed
    @test sum(clusts_copy) == sum(clusts_fixed)
    @test clusts_copy != clusts_fixed
    @test length(findall(x -> x == 0, clusts_fixed)) == 0

    # Empty clusters, fix, several equal maximums
    clusts = [101; 5; 0; 21; 101; 10; 0; 0; 101; 100; 99; 0; 0; 0; 100]
    clusts_copy = clusts[:]
    clusts_fixed = CluGen.fix_empty!(clusts, false)
    @test clusts === clusts_fixed
    @test sum(clusts_copy) == sum(clusts_fixed)
    @test clusts_copy != clusts_fixed
    @test length(findall(x -> x == 0, clusts_fixed)) == 0

    # Empty clusters, no fix (flag)
    clusts = [0; 10]
    clusts_copy = clusts[:]
    clusts_fixed = CluGen.fix_empty!(clusts, true)
    @test clusts === clusts_fixed
    @test clusts_copy == clusts_fixed

    # Empty clusters, no fix (not enough points)
    clusts = [0; 1; 1; 0; 0; 2; 0; 0]
    clusts_copy = clusts[:]
    clusts_fixed = CluGen.fix_empty!(clusts, false)
    @test clusts === clusts_fixed
    @test clusts_copy == clusts_fixed

    # Works with 1D
    clusts = [100]
    clusts_copy = clusts[:]
    clusts_fixed = CluGen.fix_empty!(clusts, true)
    @test clusts === clusts_fixed
    @test clusts_copy == clusts_fixed
end