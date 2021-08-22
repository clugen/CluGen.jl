# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

using CluGen
using Random
using Test

# ######################## #
# Parameters for all tests #
# ######################## #

num_dims = (1, 2, 3, 4, 30)
seeds = (0, 123)
total_points = (1, 10, 500, 10000)
num_clusters = (1, 2, 5, 10, 100)
allow_empties = (true, false)
clu_offsets = (ndims) -> (
    zeros(ndims),
    ones(ndims),
    [1000 .* randn(MersenneTwister(s), ndims) for s in seeds]...
)
clu_seps = clu_offsets

clusize_dists = Dict(
    "half_normal" => (rng, nclu) -> () -> abs.(randn(rng, nclu)),
    "unif" => (rng, nclu) -> () -> rand(rng, nclu),
    "equal" => (rng, nclu) -> () -> (1.0 / nclu) .* ones(nclu)
)

clucenter_dists = Dict(
    "unif" => (rng, nclu, ndim) -> () -> rand(rng, nclu, ndim) .- 0.5,
    "normal" => (rng, nclu, ndim) -> () -> randn(rng, nclu, ndim),
    "fixed" =>  (rng, nclu, ndim) -> () -> collect(1:ndim)' .* ones(nclu, ndim)
)

# ############################################# #
# Perform test for each function in the package #
# ############################################# #

include("clusizes.jl")
include("clucenters.jl")
include("rand_unit_vector.jl")
include("rand_ortho_vector.jl")
include("rand_vector_at_angle.jl")
include("clupoints_d_1.jl")
include("clupoints_d.jl")
include("clugen.jl")

