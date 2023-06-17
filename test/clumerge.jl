# Copyright (c) 2020-2023 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test clumerge with clugen-generated data
@testset "clumerge" begin
    @testset """seed=$(Int(rng.seed[1])), nd=$nd, ds_count=$ds_count""" for
        rng in rngs[1:end], nd in num_dims[1:end], ds_count in 2:5

        datasets::Array{NamedTuple} = []
        tclu::Integer = 0
        tpts::Integer = 0

        for nds in ds_count

            ds = @test_nowarn clugen(
                nd,
                rand(rng, 1:10),
                rand(rng, 1:100),
                rand(rng, nd),
                rand(rng),
                rand(rng, nd),
                rand(rng),
                rand(rng),
                rand(rng);
                allow_empty=true,
                rng=rng,
            )
            tclu += length(unique(ds.clusters))
            tpts += size(ds.points, 1)
            push!(datasets, ds)
        end

        mds = @test_nowarn clumerge(datasets...)

        @test length(unique(mds.clusters)) == tclu
        @test size(mds.points, 1) == tpts
    end
end