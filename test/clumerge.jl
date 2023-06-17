# Copyright (c) 2020-2023 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test the clumerge() function
@testset "clumerge" begin

    # Test clumerge with default parameters and various data sources
    @testset """seed=$(Int(rng.seed[1])), nd=$nd,
        ds_cg_n=$ds_cg_n, ds_ot_n=$ds_ot_n, ds_od_n=$ds_od_n""" for rng in rngs[1:end],
        nd in num_dims[1:end],
        ds_cg_n in 0:4, # Number of data sets created with clugen()
        ds_ot_n in 0:2, # Number of other data sets in the form of tuples
        ds_od_n in 0:2, # Number of other data sets in the form of dictionaries
        out_type in (:NamedTuple, :Dict, nothing)

        # Only test if there are at least one data set to merge
        # (when there is only one, the function will just use that one)
        if ds_cg_n + ds_ot_n + ds_od_n > 0
            datasets::Set{Union{NamedTuple,Dict}} = Set()
            tclu::Integer = 0
            tpts::Integer = 0

            # Create data sets with clugen()
            for _ in 1:ds_cg_n
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

            # Create non-clugen() data sets as tuples
            for _ in 1:ds_ot_n
                npts = rand(rng, 1:100)
                nclu = rand(rng, 1:min(3, npts))
                ds = (points=rand(rng, npts, nd), clusters=rand(rng, 1:nclu, npts))
                tclu += length(unique(ds.clusters))
                tpts += npts
                push!(datasets, ds)
            end

            # Create non-clugen() data sets as dictionaries
            for _ in 1:ds_od_n
                npts = rand(rng, 1:100)
                nclu = rand(rng, 1:min(3, npts))
                ds = Dict(
                    :points => rand(rng, npts, nd), :clusters => rand(rng, 1:nclu, npts)
                )
                tclu += length(unique(ds[:clusters]))
                tpts += npts
                push!(datasets, ds)
            end

            # Check that clumerge() is able to merge data sets without warnings
            mds = if out_type === nothing
                @test_nowarn clumerge(datasets...)
            else
                @test_nowarn clumerge(datasets...; output_type=out_type)
            end

            # Check that the output is of the correct type
            if out_type == :Dict
                @test typeof(mds) <: Dict
            else
                @test typeof(mds) <: NamedTuple
            end

            # Check that the number of clusters and points is correct
            @test length(unique(getindex(mds, :clusters))) == tclu
            @test size(getindex(mds, :points), 1) == tpts
        end
    end
end