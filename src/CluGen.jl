# Copyright (c) 2020-2023 Nuno Fachada, Diogo de Andrade, and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

"""
    CluGen

A Julia package for generating multidimensional clusters. Provides the
[`clugen`](@ref) function for this purpose, as well as a number of auxiliary
functions, used internally and modularly by [`clugen`](@ref). Users can swap
these auxiliary functions by their own customized versions, fine-tuning their
cluster generation strategies, or even use them as the basis for their own
generation algorithms.
"""
module CluGen

using LinearAlgebra
using Random

export angle_btw
export clugen
export clumerge
export points_on_line
export rand_unit_vector
export rand_ortho_vector
export rand_vector_at_angle

include("main.jl")
include("core.jl")
include("module.jl")
include("helper.jl")

end # Module
