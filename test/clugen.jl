# Copyright (c) 2020-2023 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test clugen
@testset "clugen" begin

    # Number of directions to test
    ndirs = 2

    @testset """Mandatory params:
        seed=$(Int(rng.seed[1])), nd=$nd, nclu=$nclu, tpts=$tpts, dir=$dir,
        astd=$astd, clu_sep=$clu_sep, lmu=$len_mu, lstd=$len_std, lat_std=$lat_std
        """ for rng in rngs[1:(end - 1)],
        nd in num_dims[1:(end - 1)],
        nclu in num_clusters,
        tpts in num_points[1:(end - 1)],
        dir in tuple(get_vecs(rng, ndirs, nd)..., rand(nclu, nd)),
        astd in angles_stds[1:(end - 1)],
        clu_sep in get_clu_seps(nd),
        len_mu in llengths_mus,
        len_std in llengths_sigmas,
        lat_std in lat_stds[1:(end - 1)]

        # By default, allow_empty is false, so clugen() must be given more points
        # than clusters...
        if tpts >= nclu
            # ...in which case it runs without problem
            result = @test_nowarn clugen(
                nd, nclu, tpts, dir, astd, clu_sep, len_mu, len_std, lat_std; rng=rng
            )
        else
            # ...otherwise an ArgumentError will be thrown
            @test_throws ArgumentError clugen(
                nd, nclu, tpts, dir, astd, clu_sep, len_mu, len_std, lat_std; rng=rng
            )
            continue # In this case, no need for more tests with this parameter set
        end

        # Check dimensions of result variables
        @test size(result.points) == (tpts, nd)
        @test size(result.clusters) == (tpts,)
        @test size(result.projections) == (tpts, nd)
        @test size(result.sizes) == (nclu,)
        @test size(result.centers) == (nclu, nd)
        @test size(result.directions) == (nclu, nd)
        @test size(result.angles) == (nclu,)
        @test size(result.lengths) == (nclu,)

        # Check point cluster indexes
        @test unique(result.clusters) == 1:nclu

        # Check total points
        @test sum(result.sizes) == tpts

        # Check that cluster directions have the correct angles with the main direction
        if nd > 1
            if ndims(dir) == 1
                dir = repeat(dir', nclu, 1)
            end
            for i in 1:nclu
                @test angle_btw(dir[i, :], result.directions[i, :]) ≈ abs(result.angles[i]) atol =
                    1e-11
            end
        end
    end

    @testset """Optional params:
        seed=$(Int(rng.seed[1])), nd=$nd, dir=$dir, clu_sep=$clu_sep, ae=$ae,
        clu_off=$clu_off, ptdist_fn=$ptdist_name, ptoff_fn=$ptoff_name,
        csz_fn=$csz_name, cctr_fn=$cctr_name, llen_fn=$llen_name,
        lang_fn=$lang_name
        """ for rng in rngs[1:2],
        nd in (2, 7),
        dir in get_vecs(rng, 1, nd),
        clu_sep in get_clu_seps(nd),
        ae in allow_empties,
        clu_off in get_clu_offsets(nd),
        (ptdist_name, ptdist_fn) in ptdist_fns,
        (ptoff_name, ptoff_fn) in ptoff_fns,
        (csz_name, csz_fn) in csz_fns,
        (cctr_name, cctr_fn) in cctr_fns,
        (llen_name, llen_fn) in llen_fns,
        (lang_name, lang_fn) in lang_fns

        # Valid arguments
        nclu = 7
        tpts = 500
        astd = pi / 256
        len_mu = 9
        len_std = 1.2
        lat_std = 2

        # Test passes with valid arguments
        result = @test_nowarn clugen(
            nd,
            nclu,
            tpts,
            dir,
            astd,
            clu_sep,
            len_mu,
            len_std,
            lat_std;
            allow_empty=ae,
            cluster_offset=clu_off,
            proj_dist_fn=ptdist_fn,
            point_dist_fn=ptoff_fn,
            clusizes_fn=csz_fn,
            clucenters_fn=cctr_fn,
            llengths_fn=llen_fn,
            angle_deltas_fn=lang_fn,
            rng=rng,
        )

        # Check dimensions of result variables
        @test size(result.points) == (tpts, nd)
        @test size(result.clusters) == (tpts,)
        @test size(result.projections) == (tpts, nd)
        @test size(result.sizes) == (nclu,)
        @test size(result.centers) == (nclu, nd)
        @test size(result.directions) == (nclu, nd)
        @test size(result.angles) == (nclu,)
        @test size(result.lengths) == (nclu,)

        # Check point cluster indexes
        if !ae
            @test unique(result.clusters) == 1:nclu
        else
            @test all(map((x) -> x <= nclu, result.clusters))
        end

        # Check total points
        @test sum(result.sizes) == tpts
        # This might not be the case if the specified clusize_fn does not obey
        # the total number of points

        # Check that cluster directions have the correct angles with the main direction
        if nd > 1
            for i in 1:nclu
                @test angle_btw(dir, result.directions[i, :]) ≈ abs(result.angles[i]) atol =
                    1e-11
            end
        end
    end

    @testset "Exceptions" for rng in rngs

        # Valid arguments
        nd = 3
        nclu = 5
        tpts = 1000
        dir = [1, 0, 0]
        astd = pi / 64
        clu_sep = [10, 10, 5]
        len_mu = 5
        len_std = 0.5
        lat_std = 0.3
        ae = true
        clu_off = [-1.5, 0, 2]
        pt_dist = "unif"
        pt_off = "n-1"
        csizes_fn = CluGen.clusizes
        ccenters_fn = CluGen.clucenters
        llengths_fn = CluGen.llengths
        langles_fn = CluGen.angle_deltas

        # Test passes with valid arguments
        @test_nowarn clugen(
            nd,
            nclu,
            tpts,
            dir,
            astd,
            clu_sep,
            len_mu,
            len_std,
            lat_std;
            allow_empty=ae,
            cluster_offset=clu_off,
            proj_dist_fn=pt_dist,
            point_dist_fn=pt_off,
            clusizes_fn=csizes_fn,
            clucenters_fn=ccenters_fn,
            llengths_fn=llengths_fn,
            angle_deltas_fn=langles_fn,
            rng=rng,
        )

        # Test passes with zero points since allow_empty is set to true
        @test_nowarn clugen(
            nd,
            nclu,
            0,
            dir,
            astd,
            clu_sep,
            len_mu,
            len_std,
            lat_std;
            allow_empty=ae,
            cluster_offset=clu_off,
            proj_dist_fn=pt_dist,
            point_dist_fn=pt_off,
            clusizes_fn=csizes_fn,
            clucenters_fn=ccenters_fn,
            llengths_fn=llengths_fn,
            angle_deltas_fn=langles_fn,
            rng=rng,
        )

        # Invalid number of dimensions
        @test_throws ArgumentError clugen(
            0,
            nclu,
            tpts,
            dir,
            astd,
            clu_sep,
            len_mu,
            len_std,
            lat_std;
            allow_empty=ae,
            cluster_offset=clu_off,
            proj_dist_fn=pt_dist,
            point_dist_fn=pt_off,
            clusizes_fn=csizes_fn,
            clucenters_fn=ccenters_fn,
            llengths_fn=llengths_fn,
            angle_deltas_fn=langles_fn,
            rng=rng,
        )

        # Invalid number of clusters
        @test_throws ArgumentError clugen(
            nd,
            0,
            tpts,
            dir,
            astd,
            clu_sep,
            len_mu,
            len_std,
            lat_std;
            allow_empty=ae,
            cluster_offset=clu_off,
            proj_dist_fn=pt_dist,
            point_dist_fn=pt_off,
            clusizes_fn=csizes_fn,
            clucenters_fn=ccenters_fn,
            llengths_fn=llengths_fn,
            angle_deltas_fn=langles_fn,
            rng=rng,
        )

        # Direction needs to have magnitude > 0
        @test_throws ArgumentError clugen(
            nd,
            nclu,
            tpts,
            zeros(nd),
            astd,
            clu_sep,
            len_mu,
            len_std,
            lat_std;
            allow_empty=ae,
            cluster_offset=clu_off,
            proj_dist_fn=pt_dist,
            point_dist_fn=pt_off,
            clusizes_fn=csizes_fn,
            clucenters_fn=ccenters_fn,
            llengths_fn=llengths_fn,
            angle_deltas_fn=langles_fn,
            rng=rng,
        )

        # Direction needs to have nd dims
        @test_throws ArgumentError clugen(
            nd,
            nclu,
            tpts,
            ones(nd + 1),
            astd,
            clu_sep,
            len_mu,
            len_std,
            lat_std;
            allow_empty=ae,
            cluster_offset=clu_off,
            proj_dist_fn=pt_dist,
            point_dist_fn=pt_off,
            clusizes_fn=csizes_fn,
            clucenters_fn=ccenters_fn,
            llengths_fn=llengths_fn,
            angle_deltas_fn=langles_fn,
            rng=rng,
        )

        # Direction needs to be a 1D array (vector) or 2D array (matrix)
        @test_throws ArgumentError clugen(
            nd,
            nclu,
            tpts,
            ones(nclu, nd, nd),
            astd,
            clu_sep,
            len_mu,
            len_std,
            lat_std;
            allow_empty=ae,
            cluster_offset=clu_off,
            proj_dist_fn=pt_dist,
            point_dist_fn=pt_off,
            clusizes_fn=csizes_fn,
            clucenters_fn=ccenters_fn,
            llengths_fn=llengths_fn,
            angle_deltas_fn=langles_fn,
            rng=rng,
        )

        # cluster_sep needs to have nd dims
        @test_throws ArgumentError clugen(
            nd,
            nclu,
            tpts,
            dir,
            astd,
            rand(rng, nd + 1),
            len_mu,
            len_std,
            lat_std;
            allow_empty=ae,
            cluster_offset=clu_off,
            proj_dist_fn=pt_dist,
            point_dist_fn=pt_off,
            clusizes_fn=csizes_fn,
            clucenters_fn=ccenters_fn,
            llengths_fn=llengths_fn,
            angle_deltas_fn=langles_fn,
            rng=rng,
        )

        # cluster_offset needs to have nd dims
        @test_throws ArgumentError clugen(
            nd,
            nclu,
            tpts,
            dir,
            astd,
            clu_sep,
            len_mu,
            len_std,
            lat_std;
            allow_empty=ae,
            cluster_offset=rand(rng, nd + 1),
            proj_dist_fn=pt_dist,
            point_dist_fn=pt_off,
            clusizes_fn=csizes_fn,
            clucenters_fn=ccenters_fn,
            llengths_fn=llengths_fn,
            angle_deltas_fn=langles_fn,
            rng=rng,
        )

        # Unknown proj_dist_fn given as string
        @test_throws ArgumentError clugen(
            nd,
            nclu,
            tpts,
            dir,
            astd,
            clu_sep,
            len_mu,
            len_std,
            lat_std;
            allow_empty=ae,
            cluster_offset=clu_off,
            proj_dist_fn="bad_proj_dist_fn",
            point_dist_fn=pt_off,
            clusizes_fn=csizes_fn,
            clucenters_fn=ccenters_fn,
            llengths_fn=llengths_fn,
            angle_deltas_fn=langles_fn,
            rng=rng,
        )

        # Invalid proj_dist_fn given as function
        @test_throws MethodError clugen(
            nd,
            nclu,
            tpts,
            dir,
            astd,
            clu_sep,
            len_mu,
            len_std,
            lat_std;
            allow_empty=ae,
            cluster_offset=clu_off,
            proj_dist_fn=() -> nothing,
            point_dist_fn=pt_off,
            clusizes_fn=csizes_fn,
            clucenters_fn=ccenters_fn,
            llengths_fn=llengths_fn,
            angle_deltas_fn=langles_fn,
            rng=rng,
        )

        # Unknown point_dist_fn given as string
        @test_throws ArgumentError clugen(
            nd,
            nclu,
            tpts,
            dir,
            astd,
            clu_sep,
            len_mu,
            len_std,
            lat_std;
            allow_empty=ae,
            cluster_offset=clu_off,
            proj_dist_fn=pt_dist,
            point_dist_fn="bad_pt_off",
            clusizes_fn=csizes_fn,
            clucenters_fn=ccenters_fn,
            llengths_fn=llengths_fn,
            angle_deltas_fn=langles_fn,
            rng=rng,
        )

        # Invalid point_dist_fn given as function
        function fn_to_test()
            return clugen(
                nd,
                nclu,
                tpts,
                dir,
                astd,
                clu_sep,
                len_mu,
                len_std,
                lat_std;
                allow_empty=ae,
                cluster_offset=clu_off,
                proj_dist_fn=pt_dist,
                point_dist_fn=() -> nothing,
                clusizes_fn=csizes_fn,
                clucenters_fn=ccenters_fn,
                llengths_fn=llengths_fn,
                angle_deltas_fn=langles_fn,
                rng=rng,
            )
        end
        @static if VERSION < v"1.4"
            @test_throws ErrorException fn_to_test()
        else
            @test_throws MethodError fn_to_test()
        end
    end
end
