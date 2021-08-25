# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

# Test clugen
@testset "clugen" begin

    # Number of directions to test
    ndirs = 2

    @testset """Mandatory params:
        seed=$(Int(rng.seed[1])), nd=$nd, tpts=$tpts, dir=$dir, astd=$astd,
        clu_sep=$clu_sep, lmu=$len_mu, lstd=$len_std, lat_std=$lat_std
        """ for
        rng in rngs[1:end-1],
        nd in num_dims[1:end-1],
        nclu in num_clusters,
        tpts in total_points[1:end-1],
        dir in get_vecs(rng, ndirs, nd),
        astd in angles_stds[1:end-1],
        clu_sep in get_clu_seps(nd),
        len_mu in line_lengths_mus,
        len_std in line_lengths_sigmas,
        lat_std in lat_stds[1:end-1]

        # By default, allow_empty is false, so clugen() must be given more points
        # than clusters...
        if tpts >= nclu
            # ...in which case it runs with out problem
            result = @test_nowarn clugen(
                nd, nclu, tpts, dir, astd, clu_sep, len_mu, len_std, lat_std; rng=rng)
        else
            # ...otherwise and ArgumentError will be thrown
            @test_throws ArgumentError clugen(
                nd, nclu, tpts, dir, astd, clu_sep, len_mu, len_std, lat_std; rng=rng)
            continue # In this case, no need for more tests with this parameter set
        end

        # Check dimensions of result variables
        @test size(result.points) == (tpts, nd)
        @test size(result.points_cluster_index) == (tpts, )
        @test size(result.points_projection) == (tpts, nd)
        @test size(result.cluster_number_of_points) == (nclu, )
        @test size(result.cluster_centers) == (nclu, nd)
        @test size(result.cluster_directions) == (nclu, nd)
        @test size(result.line_angles) == (nclu, )
        @test size(result.line_lengths) == (nclu, )

        # Check point cluster indexes
        @test unique(result.points_cluster_index) == 1:nclu

        # Check total points
        @test sum(result.cluster_number_of_points) == tpts

    end

    @testset """Optional params:
        seed=$(Int(rng.seed[1])), nd=$nd, dir=$dir, clu_sep=$clu_sep, ae=$ae,
        clu_off=$clu_off, ptdist_fn=$ptdist_name, ptoff_fn=$ptoff_name,
        csz_fn=$csz_name, cctr_fn=$cctr_name, llen_fn=$llen_name,
        lang_fn=$lang_name
        """ for
        rng in rngs[1:2],
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
        astd = pi/256
        len_mu = 9
        len_std = 1.2
        lat_std = 2

        # Test passes with valid arguments
        @test_nowarn clugen(
            nd, nclu, tpts, dir, astd, clu_sep, len_mu, len_std, lat_std;
            allow_empty=ae, cluster_offset=clu_off, point_dist=ptdist_fn,
            point_offset=ptoff_fn, clusizes_fn=csz_fn, clucenters_fn=cctr_fn,
            line_lengths_fn=llen_fn, line_angles_fn=lang_fn, rng=rng)

    end

    @testset "Exceptions" for rng in rngs

        # Valid arguments
        nd = 3
        nclu = 5
        tpts = 1000
        dir = [1, 0, 0]
        astd = pi/64
        clu_sep = [10, 10, 5]
        len_mu = 5
        len_std = 0.5
        lat_std = 0.3
        ae = true
        clu_off = [-1.5, 0, 2]
        pt_dist = "unif"
        pt_off = "d-1"
        csizes_fn = clusizes
        ccenters_fn = clucenters
        llengths_fn = line_lengths
        langles_fn = line_angles

        # Test passes with valid arguments
        @test_nowarn clugen(
            nd, nclu, tpts, dir, astd, clu_sep, len_mu, len_std, lat_std;
            allow_empty=ae, cluster_offset=clu_off, point_dist=pt_dist,
            point_offset=pt_off, clusizes_fn=csizes_fn, clucenters_fn=ccenters_fn,
            line_lengths_fn=llengths_fn, line_angles_fn=langles_fn, rng=rng)

        # Test passes with zero points since allow_empty is set to true
        @test_nowarn clugen(
            nd, nclu, 0, dir, astd, clu_sep, len_mu, len_std, lat_std;
            allow_empty=ae, cluster_offset=clu_off, point_dist=pt_dist,
            point_offset=pt_off, clusizes_fn=csizes_fn, clucenters_fn=ccenters_fn,
            line_lengths_fn=llengths_fn, line_angles_fn=langles_fn, rng=rng)

        # Invalid number of dimensions
        @test_throws ArgumentError clugen(
            0, nclu, tpts, dir, astd, clu_sep, len_mu, len_std, lat_std;
            allow_empty=ae, cluster_offset=clu_off, point_dist=pt_dist,
            point_offset=pt_off, clusizes_fn=csizes_fn, clucenters_fn=ccenters_fn,
            line_lengths_fn=llengths_fn, line_angles_fn=langles_fn, rng=rng)

        # Invalid number of clusters
        @test_throws ArgumentError clugen(
            nd, 0, tpts, dir, astd, clu_sep, len_mu, len_std, lat_std;
            allow_empty=ae, cluster_offset=clu_off, point_dist=pt_dist,
            point_offset=pt_off, clusizes_fn=csizes_fn, clucenters_fn=ccenters_fn,
            line_lengths_fn=llengths_fn, line_angles_fn=langles_fn, rng=rng)

        # Direction needs to have magnitude > 0
        @test_throws ArgumentError clugen(
            nd, nclu, tpts, [0, 0, 0], astd, clu_sep, len_mu, len_std, lat_std;
            allow_empty=ae, cluster_offset=clu_off, point_dist=pt_dist,
            point_offset=pt_off, clusizes_fn=csizes_fn, clucenters_fn=ccenters_fn,
            line_lengths_fn=llengths_fn, line_angles_fn=langles_fn, rng=rng)

        # Direction needs to have nd dims
        @test_throws ArgumentError clugen(
            nd, nclu, tpts, [1, 1], astd, clu_sep, len_mu, len_std, lat_std;
            allow_empty=ae, cluster_offset=clu_off, point_dist=pt_dist,
            point_offset=pt_off, clusizes_fn=csizes_fn, clucenters_fn=ccenters_fn,
            line_lengths_fn=llengths_fn, line_angles_fn=langles_fn, rng=rng)

        # cluster_sep needs to have nd dims
        @test_throws ArgumentError clugen(
            nd, nclu, tpts, dir, astd, [10, 0, 5, 1.4], len_mu, len_std, lat_std;
            allow_empty=ae, cluster_offset=clu_off, point_dist=pt_dist,
            point_offset=pt_off, clusizes_fn=csizes_fn, clucenters_fn=ccenters_fn,
            line_lengths_fn=llengths_fn, line_angles_fn=langles_fn, rng=rng)

        # cluster_offset needs to have nd dims
        @test_throws ArgumentError clugen(
            nd, nclu, tpts, dir, astd, clu_sep, len_mu, len_std, lat_std;
            allow_empty=ae, cluster_offset=[0, 1], point_dist=pt_dist,
            point_offset=pt_off, clusizes_fn=csizes_fn, clucenters_fn=ccenters_fn,
            line_lengths_fn=llengths_fn, line_angles_fn=langles_fn, rng=rng)

        # Unknown point_dist given as string
        @test_throws ArgumentError clugen(
            nd, nclu, tpts, dir, astd, clu_sep, len_mu, len_std, lat_std;
            allow_empty=ae, cluster_offset=clu_off, point_dist="bad_point_dist",
            point_offset=pt_off, clusizes_fn=csizes_fn, clucenters_fn=ccenters_fn,
            line_lengths_fn=llengths_fn, line_angles_fn=langles_fn, rng=rng)

        # Invalid point_dist given as function
        @test_throws MethodError clugen(
            nd, nclu, tpts, dir, astd, clu_sep, len_mu, len_std, lat_std;
            allow_empty=ae, cluster_offset=clu_off, point_dist=()->nothing,
            point_offset=pt_off, clusizes_fn=csizes_fn, clucenters_fn=ccenters_fn,
            line_lengths_fn=llengths_fn, line_angles_fn=langles_fn, rng=rng)

        # Unknown point_offset given as string
        @test_throws ArgumentError clugen(
            nd, nclu, tpts, dir, astd, clu_sep, len_mu, len_std, lat_std;
            allow_empty=ae, cluster_offset=clu_off, point_dist=pt_dist,
            point_offset="bad_pt_off", clusizes_fn=csizes_fn, clucenters_fn=ccenters_fn,
            line_lengths_fn=llengths_fn, line_angles_fn=langles_fn, rng=rng)

        # Invalid point_offset given as function
        @test_throws MethodError clugen(
            nd, nclu, tpts, dir, astd, clu_sep, len_mu, len_std, lat_std;
            allow_empty=ae, cluster_offset=clu_off, point_dist=pt_dist,
            point_offset=()->nothing, clusizes_fn=csizes_fn, clucenters_fn=ccenters_fn,
            line_lengths_fn=llengths_fn, line_angles_fn=langles_fn, rng=rng)




        # @test_throws ArgumentError clugen(
        #     nd, nclu, tpts, dir, astd, clu_sep, len_mu, len_std, lat_std;
        #     allow_empty=ae, cluster_offset=clu_off, point_dist=pt_dist,
        #     point_offset=pt_off, clusizes_fn=csizes_fn, clucenters_fn=ccenters_fn,
        #     line_lengths_fn=llengths_fn, line_angles_fn=langles_fn, rng=rng)


    end

end