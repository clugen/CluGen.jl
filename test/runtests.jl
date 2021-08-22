# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

using CluGen
using Random
using Test

# General parameters for all tests
seeds = (0, 123)
total_points = (1, 10, 500, 10000)
num_clusters = (1, 2, 5, 10, 100)
allow_empty = (true, false)

# Perform test for each function in the package
include("clusizes.jl")

