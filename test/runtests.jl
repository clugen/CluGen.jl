# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

using CluGen
using Documenter
using LinearAlgebra
using Random
using Test

# ######################## #
# Parameters for all tests #
# ######################## #

seeds = (0, 123, 9999, 9876543)
rngs = MersenneTwister.(seeds)
num_dims = (1, 2, 3, 4, 30)
total_points = (1, 10, 500, 10000)
num_clusters = (1, 2, 5, 10, 100)
lat_stds = (0.0, 5.0, 500)
line_lengths_mus = (0, 10)
line_lengths_sigmas = (0, 15)
angles_stds = (0, pi/256, pi/32, pi/4, pi/2, pi, 2*pi)

allow_empties = (true, false)
get_clu_offsets = (ndims) -> (
    zeros(ndims),
    ones(ndims),
    [1000 .* randn(rng, ndims) for rng in rngs]...
)
get_clu_seps = get_clu_offsets

get_vecs = (rng, n, nd) -> [normalize(v) for v in eachcol(rand(rng, nd, n))]
get_angles = (rng, n) -> [a for a in 2 * pi .* rand(rng, n) .- pi]

ptdist_fns = Dict(
    "norm" => "norm",
    "unif" => "unif",
    "equidistant" =>  (len, n) -> (-len/2:len/n:len/2)[1:n]
)
ptoff_fns = Dict(
    "d-1" => "d-1",
    "d" => "d",
    "proj+1" => (projs, lstd, cdir, cctr) -> projs + ones(size(projs))
)
csz_fns = Dict(
    "default" => clusizes,
    "equi_size" =>
        function (nclu, tpts, ae; rng=nothing)
            cs = zeros(Integer, nclu)
            for i in 1:tpts
                cs[i % nclu + 1] += 1
            end
            return cs
        end
)
cctr_fns = Dict(
    "default" => clucenters,
    "on_a_line" =>
        (nclu, csep, coff; rng=nothing) -> ones(nclu, length(csep)) .* (1:nclu)
)
llen_fns = Dict(
    "default" => line_lengths,
    "unif_btw10-20" =>
        (nclu, llen, llenstd; rng = Random.GLOBAL_RNG) -> 10 .+ 10 * rand(rng, nclu)
)
lang_fns = Dict(
    "default" => line_angles,
    "same_angle" => (nclu, astd; rng=nothing) -> zeros(nclu)
)

# For compatibility with Julia 1.0, from Compat.jl by Stefan Karpinski and other
# contributors (MIT license)
# https://github.com/JuliaLang/Compat.jl/blob/master/src/Compat.jl
if VERSION < v"1.1.0-DEV.792"
    eachrow(A::AbstractVecOrMat) = (view(A, i, :) for i in axes(A, 1))
    eachcol(A::AbstractVecOrMat) = (view(A, :, i) for i in axes(A, 2))
end

# Angle between two vectors, useful for checking correctness of results
# Previous version was unstable: angle(u, v) = acos(dot(u, v) / (norm(u) * norm(v)))
# Version below is based on AngleBetweenVectors.jl by Jeffrey Sarnoff (MIT license),
# in turn based on these notes by Prof. W. Kahan, see page 15:
# https://people.eecs.berkeley.edu/~wkahan/MathH110/Cross.pdf
# https://github.com/JeffreySarnoff/AngleBetweenVectors.jl/blob/master/src/AngleBetweenVectors.jl
function angle(v1, v2)

    u1 = normalize(v1)
    u2 = normalize(v2)

    y = u1 .- u2
    x = u1 .+ u2

    a = 2 * atan(norm(y) / norm(x))

    return !(signbit(a) || signbit(pi - a)) ? a : (signbit(a) ? 0.0 : pi)
end

# ############################################# #
# Perform test for each function in the package #
# ############################################# #

include("clusizes.jl")
include("clucenters.jl")
include("line_lengths.jl")
include("line_angles.jl")
include("points_on_line.jl")
include("rand_unit_vector.jl")
include("rand_ortho_vector.jl")
include("rand_vector_at_angle.jl")
include("clupoints_d_1.jl")
include("clupoints_d.jl")
include("clugen.jl")

# Run doctests
DocMeta.setdocmeta!(CluGen, :DocTestSetup, :(using CluGen, LinearAlgebra, Random); recursive=true)
doctest(CluGen)
