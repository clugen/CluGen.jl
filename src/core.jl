# Copyright (c) 2020-2023 Nuno Fachada, Diogo de Andrade, and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

"""
    points_on_line(
        center::AbstractArray{<:Real, 1},
        direction::AbstractArray{<:Real, 1},
        dist_center::AbstractArray{<:Real, 1}
    ) -> AbstractArray{<:Real, 2}

Determine coordinates of points on a line with `center` and `direction`, based
on the distances from the center given in `dist_center`.

This works by using the vector formulation of the line equation assuming
`direction` is a ``n``-dimensional unit vector. In other words, considering
``\\mathbf{d}=`` `direction` (``n \\times 1``), ``\\mathbf{c}=`` `center` (``
n \\times 1``), and ``\\mathbf{w}=`` `dist_center` (``p \\times 1``), the
coordinates of points on the line are given by:

```math
\\mathbf{P}=\\mathbf{1}\\,\\mathbf{c}^T + \\mathbf{w}\\mathbf{d}^T
```

where ``\\mathbf{P}`` is the ``p \\times n`` matrix of point coordinates on the
line, and ``\\mathbf{1}`` is a ``p \\times 1`` vector with all entries equal to 1.

# Examples
```jldoctest
julia> points_on_line([5.0,5.0], [1.0,0.0], -4:2:4) # 2D, 5 points
5×2 Matrix{Float64}:
 1.0  5.0
 3.0  5.0
 5.0  5.0
 7.0  5.0
 9.0  5.0

julia> points_on_line([-2.0,0,0,2.0], [0,0,-1.0,0], [10,-10]) # 4D, 2 points
2×4 Matrix{Float64}:
 -2.0  0.0  -10.0  2.0
 -2.0  0.0   10.0  2.0
```
"""
function points_on_line(
    center::AbstractArray{<:Real,1},
    direction::AbstractArray{<:Real,1},
    dist_center::AbstractArray{<:Real,1},
)::AbstractArray{<:Real,2}
    return center' .+ dist_center * direction'
end

"""
    rand_ortho_vector(
        u::AbstractArray{<:Real, 1};
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) -> AbstractArray{<:Real, 1}

Get a random unit vector orthogonal to `u`.

Note that `u` is expected to be a unit vector itself.

# Examples
```jldoctest; setup = :(using LinearAlgebra, Random; Random.seed!(111))
julia> u = normalize([1,2,5.0,-3,-0.2]); # Define a 5D unit vector

julia> v = rand_ortho_vector(u);

julia> ≈(dot(u, v), 0; atol=1e-15) # Vectors orthogonal? (needs LinearAlgebra package)
true

julia> rand_ortho_vector([1,0,0]; rng=MersenneTwister(567)) # 3D, reproducible
3-element Vector{Float64}:
  0.0
 -0.717797705156548
  0.6962517177515569
```
"""
function rand_ortho_vector(
    u::AbstractArray{<:Real,1}; rng::AbstractRNG=Random.GLOBAL_RNG
)::AbstractArray{<:Real,1}

    # If 1D, just return a random unit vector
    length(u) == 1 && return rand_unit_vector(1; rng=rng)

    # Variable for placing random non-parallel vector
    r = nothing

    # Find a random, non-parallel vector to u
    while true

        # Find normalized random vector
        r = rand_unit_vector(length(u); rng=rng)

        # If not parallel to u we can keep it and break the loop
        if abs(dot(u, r)) ≉ 1
            break
        end
    end

    # Get vector orthogonal to u using 1st iteration of Gram-Schmidt process
    v = r - dot(u, r) / dot(u, u) .* u

    # Normalize it
    normalize!(v)

    # And return it
    return v
end

"""
    rand_unit_vector(
        num_dims::Integer;
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) ->  AbstractArray{<:Real, 1}

Get a random unit vector with `num_dims` dimensions.

# Examples
```jldoctest; setup = :(using LinearAlgebra, Random; Random.seed!(111))
julia> v = rand_unit_vector(4) # 4D
4-element Vector{Float64}:
 -0.24033021128704707
 -0.032103799230189585
  0.04223910709972599
 -0.9692402145232775

julia> norm(v) # Check vector magnitude is 1 (needs LinearAlgebra package)
1.0

julia> rand_unit_vector(2; rng=MersenneTwister(33)) # 2D, reproducible
2-element Vector{Float64}:
  0.8429232717309576
 -0.5380337888779647
```
"""
function rand_unit_vector(
    num_dims::Integer; rng::AbstractRNG=Random.GLOBAL_RNG
)::AbstractArray{<:Real,1}
    r = rand(rng, num_dims) .- 0.5
    normalize!(r)
    return r
end

"""
    rand_vector_at_angle(
        u::AbstractArray{<:Real, 1},
        angle::Real;
        rng::AbstractRNG = Random.GLOBAL_RNG
    ) ->  AbstractArray{<:Real, 1}

Get a random unit vector which is at `angle` radians of vector `u`.

Note that `u` is expected to be a unit vector itself.

# Examples
```jldoctest; setup = :(using LinearAlgebra, Random; Random.seed!(111))
julia> u = normalize([1,0.5,0.3,-0.1]); # Define a 4D unit vector

julia> v = rand_vector_at_angle(u, pi/4); # pi/4 = 0.7853981... radians = 45 degrees

julia> a = acos(dot(u, v) / (norm(u) * norm(v))) # Angle (radians) between u and v?
0.7853981633974483

julia> rand_vector_at_angle([0, 1], pi/6; rng=MersenneTwister(456)) # 2D, reproducible
2-element Vector{Float64}:
 -0.4999999999999999
  0.8660254037844387
```
"""
function rand_vector_at_angle(
    u::AbstractArray{<:Real,1}, angle::Real; rng::AbstractRNG=Random.GLOBAL_RNG
)::AbstractArray{<:Real,1}
    if abs(angle) < eps()
        return copy(u)
    elseif abs(angle) ≈ pi / 2 && length(u) > 1
        return rand_ortho_vector(u; rng=rng)
    elseif -pi / 2 < angle < pi / 2 && length(u) > 1
        return normalize(u + rand_ortho_vector(u; rng=rng) * tan(angle))
    else
        # For |θ| > π/2 or the 1D case, simply return a random vector
        return rand_unit_vector(length(u); rng=rng)
    end
end
