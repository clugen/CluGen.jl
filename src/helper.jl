# Copyright (c) 2020-2023 Nuno Fachada, Diogo de Andrade, and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

"""
    angle_btw(v1::AbstractArray{<:Real, 1}, v2::AbstractArray{<:Real, 1}) -> Real

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
        projs::AbstractArray{<:Real, 2},
        lat_disp::Real,
        clu_dir::AbstractArray{<:Real, 1},
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
        clu_num_points::AbstractArray{<:Integer, 1},
        allow_empty::Bool = false
    ) -> AbstractArray{<:Integer, 1}

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
        clu_num_points::AbstractArray{<:Integer, 1},
        num_points::Integer
    ) -> AbstractArray{<:Integer, 1}

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


mutable struct FieldInfo
    type::Type
    ncol::Integer
end

"""
    clumerge()

In progress.

* out can be "namedtuple" or "dict"
* join can be "intersect" or "union"
"""
function clumerge(
    data::Union{NamedTuple,Dict}...;
    out::Symbol=:NamedTuple,
    fields::AbstractSet{Symbol}=Set((:points, :clusters)),
    clusters_field::Union{Symbol,Nothing} = :clusters
)::Union{NamedTuple,Dict}

    numel::Integer = 0
    fields_info::Dict{Symbol,FieldInfo} = Dict()
    output::Dict{Symbol, Any} = Dict()

    # If a clusters field is given, it must exist in the fields to merge
    if clusters_field !== nothing && !(clusters_field in fields)
        throw(
            ArgumentError(
                "`fields` parameter does not contain `$clusters_field`"
            ),
        )
    end

    # Cycle through data items
    for dt in data

        # Number of elements in the current item
        numel_i::Union{Integer, Nothing} = nothing

        # Cycle through fields for the current item
        for field in fields

            if !haskey(dt, field)
                throw(
                    ArgumentError(
                        "Data item does not contain required field `$field`"
                    ),
                )
            elseif field == clusters_field && !(eltype(dt[clusters_field]) <: Integer)
                throw(
                    ArgumentError(
                        "`$clusters_field` must contain integer types"
                    ),
                )
            end

            # Get the field value
            value = getindex(dt, field)

            # Number of elements in field value
            numel_tmp = size(value, 1)

            # Check the number of elements in the field value
            if numel_i === nothing

                # First field: get number of elements in value (must be the same
                # for the remaining field values)
                numel_i = numel_tmp

            elseif numel_tmp != numel_i

                # Fields values after the first must have the same number of
                # elements
                throw(
                    ArgumentError(
                        "Data item contains fields with different sizes ($numel_tmp != $numel_i)"
                    ),
                )
            end

            # Get/check info about the field value type
            if !haskey(fields_info, field)

                # If it's the first time this field appears, just get the info
                fields_info[field] = FieldInfo(eltype(value), size(value, 2))

            else

                # If this field already appeared in previous data items, get the
                # info and check/determine its compatibility with respect to
                # previous data items
                if size(value, 2) != fields_info[field].ncol
                    # Number of columns must be the same
                    throw(
                        ArgumentError(
                            "Dimension mismatch in field `$field`"
                        ),
                    )
                end

                # Get the common supertype
                fields_info[field].type = promote_type(eltype(value), fields_info[field].type)
            end
        end

        # Update total number of elements
        numel += numel_i
    end

    # Initialize output dictionary fields with room for all items
    for ifield in fields_info
        output[ifield.first] = Array{ifield.second.type}(undef, numel, ifield.second.ncol)
    end

    # Copy items from input data to output dictionary, field-wise
    copied::Integer = 0
    last_cluster::Integer = 0

    for dt in data

        tocopy::Integer = size(getindex(dt, first(fields)), 1)

        for ifield in fields_info
            output[ifield.first][(copied + 1):(copied + tocopy), :] =
            if ifield.first == clusters_field

                old_clusters = unique(getindex(dt, clusters_field))
                new_clusters = (last_cluster + 1):(last_cluster + length(old_clusters))
                mapping = Dict(zip(old_clusters, new_clusters))
                last_cluster = new_clusters[end]
                [mapping[val] for val in getindex(dt, clusters_field)]

            else
                getindex(dt, ifield.first)
            end

        end

        copied += tocopy

    end

    return if out == :NamedTuple
        (; output...)
    else
        output
    end

end

# Test 1:
# o=clumerge((points=[3 3 3; 1 3 3; 0 0 -1.5], clusters=[1 1 2], stufff="fe"), Dict(:points => [1 -1 3; 10 1 2], :clusters=>[1 2]))

# Test 2:
# o0 = (points = 35 * rand(100,2) .- 20, clusters=ones(Int32, 100,1))
# o1 = clugen(2, 5, 1000, [0 1; 0.25 0.75; 0.5 0.5; 0.75 0.25; 1 0], 0, [0, 0], 5, 0, 0.2; proj_dist_fn = "unif", point_dist_fn = "n", clusizes_fn = 500 * ones(Int32,5), clucenters_fn = [0 0; 2 -0.3; 4 -0.8; 6 -1.6; 8 -2.5])
# o2 = clugen(2, 3, 500, [1,1], 0.1, [10,10], 23, 1, 0.2)
# o3 = clumerge(o1, o2)
# plot(o3.points[:, 1], o3.points[:, 2], seriestype = :scatter, group=o3.clusters, aspect_ratio = :equal )




        # if !(haskey(dt, :points) && haskey(dt, :clusters))
        #     throw(
        #         ArgumentError(
        #             "Input named tuples / dictionaries must have at least :points and :clusters keys"
        #         ),
        #     )
        # end

        # tpts_i, nd_i = size(getindex(dt, :points))

        # if firstrun
        #     nd = nd_i
        # elseif nd != nd_i
        #     throw(
        #         ArgumentError(
        #             "Dimension mismatch"
        #         ),
        #     )
        # end

        # tpts += tpts_i

        # if length(getindex(dt, :clusters)) != tpts_i
        #     throw(
        #         ArgumentError(
        #             "Number of points does not match length of :clusters column"
        #         ),
        #     )
        # end

        # if join != "minimal"
        # end