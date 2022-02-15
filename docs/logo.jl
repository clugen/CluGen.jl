# Copyright (c) 2020-2022 Nuno Fachada, Diogo de Andrade, and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)
using CluGen, Plots, StableRNGs

# Script to create CluGen's logo
# Invoke from it's current folder with `julia logo.jl`

# Custom clusizes_fn: clusters all have the same size, no correction for total points
clusizes_equal(nclu, npts, ae; rng = nothing) = (npts ÷ nclu) .* ones(Integer, nclu)

# Custom clucenters_fn: yields fixed positions for the clusters
centers_fixed(nclu, csep, coff; rng=nothing) = [-csep[1] -csep[2] -csep[3];
    csep[1] -csep[2] -csep[3]; -csep[1] csep[2] csep[3];
    csep[1] csep[2] csep[3]]

r = clugen(3, 4, 5000, [1, 1, 1], 0, [15, 5, 10], 10, 0, 3.5;
    clucenters_fn = centers_fixed,
    clusizes_fn = clusizes_equal,
    point_dist_fn = "n",
    rng = StableRNG(9))

p = plot(r.points[:, 1], r.points[:, 2], r.points[:, 3], seriestype = :scatter,
    group=r.point_clusters, markersize = 2, markerstrokewidth = 0.2, aspectratio=1,
    legend = nothing, grid = false, framestyle = :none, ticks = false,
    background_color = :transparent,
    xlim = (-20, 29), ylim = (-20, 18), zlim = (-23, 20))

logo_path = (@__DIR__) * "/src/assets"
mkpath(logo_path)
savefig(p, logo_path * "/logo.svg")