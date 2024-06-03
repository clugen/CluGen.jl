# Copyright (c) 2020-2024 Nuno Fachada, Diogo de Andrade, and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

"""
    angle_btw(v1::AbstractArray{<:Real,1}, v2::AbstractArray{<:Real,1}) -> Real

Angle between two ``n``-dimensional vectors.

Typically, the angle between two vectors `v1` and `v2` can be obtained with:

```julia
acos(dot(v1, v2) / (norm(v1) * norm(v2)))
```

However, this approach is numerically unstable. The version provided here is
numerically stable and based on the
[AngleBetweenVectors.jl](https://github.com/JeffreySarnoff/AngleBetweenVectors.jl/blob/master/src/AngleBetweenVectors.jl)
package by Jeffrey Sarnoff (MIT license), implementing an algorithm provided
by Prof. W. Kahan in [these notes](https://people.eecs.berkeley.edu/~wkahan/MathH110/Cross.pdf)
(see page 15).

# Examples
```jldoctest
julia> rad2deg(angle_btw([1.0, 1.0, 1.0, 1.0], [1.0, 0.0, 0.0, 0.0]))
60.00000000000001
```
"""
function angle_btw(v1::AbstractArray{<:Real,1}, v2::AbstractArray{<:Real,1})::Real
    u1 = normalize(v1)
    u2 = normalize(v2)

    y = u1 .- u2
    x = u1 .+ u2

    a = 2 * atan(norm(y) / norm(x))

    return !(signbit(a) || signbit(pi - a)) ? a : (signbit(a) ? 0.0 : pi)
end

"""
    CluGen.clupoints_n_1_template(
        projs::AbstractArray{<:Real,2},
        lat_disp::Real,
        clu_dir::AbstractArray{<:Real,1},
        dist_fn::Function;
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) -> AbstractArray{<:Real}

Generate points from their ``n``-dimensional projections on a cluster-supporting
line, placing each point on a hyperplane orthogonal to that line and centered at
the point's projection. The function specified in `dist_fn` is used to perform
the actual placement.

This function is used internally by [`CluGen.clupoints_n_1()`](@ref) and may be
useful for constructing user-defined final point placement strategies for the
`point_dist_fn` parameter of the main [`clugen()`](@ref) function.

This function is not exported by the package and must be prefixed with `CluGen`
if invoked by user code.

# Arguments
- `projs`: Point projections on the cluster-supporting line.
- `lat_disp`: Dispersion of points from their projection.
- `clu_dir`: Direction of the cluster-supporting line (unit vector).
- `dist_fn`: Function to place points on a second line, orthogonal to the first.
  The functions accepts as parameters the number of points in the current
  cluster, the `lateral_disp` parameter (the same passed to the
  [`clugen()`](@ref) function), and a random number generator, returning a
  vector containing the distance of each point to its projection on the
  cluster-supporting line.
- `rng`: An optional pseudo-random number generator for reproducible executions.
"""
function clupoints_n_1_template(
    projs::AbstractArray{<:Real,2},
    lat_disp::Real,
    clu_dir::AbstractArray{<:Real,1},
    dist_fn::Function;
    rng::AbstractRNG=Random.GLOBAL_RNG,
)::AbstractArray{<:Real}

    # Number of dimensions
    num_dims = length(clu_dir)

    # Number of points in this cluster
    clu_num_points = size(projs, 1)

    # Get distances from points to their projections on the line
    points_dist = dist_fn(clu_num_points, lat_disp, rng)

    # Get normalized vectors, orthogonal to the current line, for each point
    orth_vecs = zeros(clu_num_points, num_dims)
    for j in 1:clu_num_points
        orth_vecs[j, :] = rand_ortho_vector(clu_dir; rng=rng)
    end

    # Set vector magnitudes
    orth_vecs = abs.(points_dist) .* orth_vecs

    # Add perpendicular vectors to point projections on the line,
    # yielding final cluster points
    points = projs + orth_vecs

    return points
end

"""
    fix_empty!(
        clu_num_points::AbstractArray{<:Integer,1},
        allow_empty::Bool=false
    ) -> AbstractArray{<:Integer,1}

Certifies that, given enough points, no clusters are left empty. This is done by
removing a point from the largest cluster and adding it to an empty cluster while
there are empty clusters. If the total number of points is smaller than the number
of clusters (or if the `allow_empty` parameter is set to `true`), this function
does nothing.

This function is used internally by [`CluGen.clusizes()`](@ref) and might be
useful for custom cluster sizing implementations given as the `clusizes_fn`
parameter of the main [`clugen()`](@ref) function.

This function is not exported by the package and must be prefixed with `CluGen`
if invoked by user code.
"""
function fix_empty!(
    clu_num_points::AbstractArray{<:Integer,1}, allow_empty::Bool=false
)::AbstractArray{<:Integer,1}

    # If the allow_empty parameter is set to true, don't do anything and return
    # immediately; this is useful for quick `clusizes_fn` one-liners
    allow_empty && return clu_num_points

    # Find empty clusters
    empty_clusts = findall(x -> x == 0, clu_num_points)

    # If there are empty clusters and enough points for all clusters...
    if length(empty_clusts) > 0 && sum(clu_num_points) >= length(clu_num_points)

        # Go through the empty clusters...
        for i0 in empty_clusts

            # ...get a point from the largest cluster and assign it to the
            # current empty cluster
            imax = argmax(clu_num_points)
            clu_num_points[imax] -= 1
            clu_num_points[i0] += 1
        end
    end

    return clu_num_points
end

"""
    fix_num_points!(
        clu_num_points::AbstractArray{<:Integer,1},
        num_points::Integer
    ) -> AbstractArray{<:Integer,1}

Certifies that the values in the `clu_num_points` array, i.e. the number of
points in each cluster, add up to `num_points`. If this is not the case, the
`clu_num_points` array is modified in-place, incrementing the value corresponding
to the smallest cluster while `sum(clu_num_points) < num_points`, or decrementing
the value corresponding to the largest cluster while
`sum(clu_num_points) > num_points`.

This function is used internally by [`CluGen.clusizes()`](@ref) and might be
useful for custom cluster sizing implementations given as the `clusizes_fn`
parameter of the main [`clugen()`](@ref) function.

This function is not exported by the package and must be prefixed with `CluGen`
if invoked by user code.
"""
function fix_num_points!(
    clu_num_points::AbstractArray{<:Integer,1}, num_points::Integer
)::AbstractArray{<:Integer,1}
    while sum(clu_num_points) < num_points
        imin = argmin(clu_num_points)
        clu_num_points[imin] += 1
    end
    while sum(clu_num_points) > num_points
        imax = argmax(clu_num_points)
        clu_num_points[imax] -= 1
    end

    return clu_num_points
end
