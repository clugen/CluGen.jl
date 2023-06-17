# Copyright (c) 2020-2023 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test the clumerge() function
@testset "clumerge" begin

    # Test clumerge with several parameters and various data sources
    @testset """seed=$(Int(rng.seed[1])), nd=$nd,
        ds_cg_n=$ds_cg_n, ds_ot_n=$ds_ot_n, ds_od_n=$ds_od_n,
        out_type=$show(out_type),
        no_clusters_field=$no_clusters_field""" for rng in rngs[1:end],
        nd in num_dims[1:end],
        ds_cg_n in 0:4, # Number of data sets created with clugen()
        ds_ot_n in 0:2, # Number of other data sets in the form of tuples
        ds_od_n in 0:2, # Number of other data sets in the form of dictionaries
        out_type in (:NamedTuple, :Dict, nothing),
        no_clusters_field in (false, true)

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
                tclu = if no_clusters_field
                    max(tclu, maximum(getindex(ds, :clusters)))
                else
                    tclu + length(unique(getindex(ds, :clusters)))
                end
                tpts += size(ds.points, 1)
                push!(datasets, ds)
            end

            # Create non-clugen() data sets as tuples
            for _ in 1:ds_ot_n
                npts = rand(rng, 1:100)
                nclu = rand(rng, 1:min(3, npts))
                ds = (points=rand(rng, npts, nd), clusters=rand(rng, 1:nclu, npts))
                tclu = if no_clusters_field
                    max(tclu, maximum(getindex(ds, :clusters)))
                else
                    tclu + length(unique(getindex(ds, :clusters)))
                end
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
                tclu = if no_clusters_field
                    max(tclu, maximum(getindex(ds, :clusters)))
                else
                    tclu + length(unique(getindex(ds, :clusters)))
                end
                tpts += npts
                push!(datasets, ds)
            end

            # Prepare optional keywords parameters
            kwargs = Dict()
            if out_type !== nothing
                kwargs[:output_type] = out_type
            end
            if no_clusters_field
                kwargs[:clusters_field] = nothing
            end

            # Check that clumerge() is able to merge data sets without warnings
            mds = @test_nowarn clumerge(datasets...; kwargs...)

            # Check that the output is of the correct type
            if out_type == :Dict
                @test typeof(mds) <: Dict
            else
                @test typeof(mds) <: NamedTuple
            end

            # Check that the number of points and clusters is correct
            expect_size = if nd == 1
                (tpts,)
            else
                (tpts, nd)
            end
            @test size(getindex(mds, :points)) == expect_size
            @test maximum(getindex(mds, :clusters)) == tclu
            @test eltype(getindex(mds, :clusters)) <: Integer
        end
    end

    # Test clumerge with data from clugen() and merging more fields
    @testset """seed=$(Int(rng.seed[1])), nd=$nd, ds_cg_n=$ds_n""" for rng in rngs[1:end],
        nd in num_dims[1:end],
        ds_n in 2:4

        datasets::Set{Union{NamedTuple,Dict}} = Set()
        tclu::Integer = 0
        tclu_i::Integer = 0
        tpts::Integer = 0

        # Create data sets with clugen()
        for _ in 1:ds_n
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
            tpts += size(ds.points, 1)
            tclu += length(unique(getindex(ds, :clusters)))
            tclu_i += length(getindex(ds, :sizes))
            push!(datasets, ds)
        end

        # Check that clumerge() is able to merge data set fields related to points
        # without warnings
        mds = @test_nowarn clumerge(datasets...; fields=(:points, :clusters, :projections))

        # Check that the number of clusters and points is correct
        expect_size = if nd == 1
            (tpts,)
        else
            (tpts, nd)
        end
        @test size(getindex(mds, :points)) == expect_size
        @test size(getindex(mds, :projections)) == expect_size
        @test maximum(getindex(mds, :clusters)) == tclu
        @test eltype(getindex(mds, :clusters)) <: Integer

        # Check that clumerge() is able to merge data set fields related to clusters
        # without warnings
        mds = @test_nowarn clumerge(
            datasets...;
            fields=(:sizes, :centers, :directions, :angles, :lengths),
            clusters_field=nothing,
        )

        # Check that the cluster-related fields have the correct sizes
        expect_size = if nd == 1
            (tclu_i,)
        else
            (tclu_i, nd)
        end
        @test length(getindex(mds, :sizes)) == tclu_i
        @test eltype(getindex(mds, :sizes)) <: Integer
        @test size(getindex(mds, :centers)) == expect_size
        @test size(getindex(mds, :directions)) == expect_size
        @test length(getindex(mds, :angles)) == tclu_i
        @test length(getindex(mds, :lengths)) == tclu_i
    end


    # Test clumerge() exceptions
    @testset "Exceptions" for rng in rngs

        # `output_type` must be :NamedTuple or :Dict
        nd = 3
        npts = rand(rng, 10:100)
        ds = (points=rand(rng, npts, nd), clusters=rand(rng, 1:5, npts))
        @test_throws ArgumentError clumerge(ds; output_type=:Invalid)

        # Data item does not contain required field `unknown`
        @test_throws ArgumentError clumerge(ds; fields=(:clusters, :unknown))

        # "`clusters_field` must contain integer types
        nd = 4
        npts = rand(rng, 10:100)
        ds = (points=rand(rng, npts, nd), clusters=rand(rng, npts))
        @test_throws ArgumentError clumerge(ds)

        # Data item contains fields with different sizes (npts != npts / 2)
        nd = 2
        npts = rand(rng, 10:100)
        ds = (points=rand(rng, npts, nd), clusters=rand(rng, 1:10, npts ÷ 2))
        @test_throws ArgumentError clumerge(ds)

        # Dimension mismatch in field `points`
        nd1 = 2
        nd2 = 3
        npts1 = rand(rng, 10:100)
        npts2 = rand(rng, 10:100)
        ds1 = (points=rand(rng, npts1, nd1), clusters=rand(rng, 1:10, npts1))
        ds2 = (points=rand(rng, npts2, nd2), clusters=rand(rng, 1:10, npts2))
        @test_throws ArgumentError clumerge(ds1, ds2)

    end

end