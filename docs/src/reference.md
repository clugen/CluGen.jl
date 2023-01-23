# Reference

* [Module](@ref)
  * [`CluGen`](@ref)
* [Main function](@ref)
  * [`clugen`](@ref)
* [Core functions](@ref)
  * [`points_on_line`](@ref)
  * [`rand_ortho_vector`](@ref)
  * [`rand_unit_vector`](@ref)
  * [`rand_vector_at_angle`](@ref)
* [Algorithm module functions](@ref)
  * [`CluGen.angle_deltas`](@ref)
  * [`CluGen.clucenters`](@ref)
  * [`CluGen.clupoints_n_1`](@ref)
  * [`CluGen.clupoints_n`](@ref)
  * [`CluGen.clusizes`](@ref)
  * [`CluGen.llengths`](@ref)
* [Helper functions](@ref)
  * [`angle_btw`](@ref)
  * [`CluGen.clupoints_n_1_template`](@ref)
  * [`CluGen.fix_empty!`](@ref)
  * [`CluGen.fix_num_points!`](@ref)

## Module

```@docs
CluGen
```

## Main function

```@docs
clugen
```

## Core functions

Core functions perform a number of useful operations during several steps of the
algorithm. These functions may be useful in other contexts, and are thus exported
by the package.

```@docs
points_on_line
rand_ortho_vector
rand_unit_vector
rand_vector_at_angle
```

## Algorithm module functions

The module functions perform a complete step of the cluster generation algorithm,
providing the package's out-of-the-box functionality. Users can swap one or more
of these when invoking [`clugen()`](@ref) in order to customize the algorithm to
their needs.

Since these functions are specific to the cluster generation algorithm, they are
not exported by the package.

```@docs
CluGen.angle_deltas
CluGen.clucenters
CluGen.clupoints_n_1
CluGen.clupoints_n
CluGen.clusizes
CluGen.llengths
```

## Helper functions

The helper functions provide useful or reusable functionality, mainly to the
module functions described in the previous section. This reusable functionality
may be useful for users implementing their own customized module functions.

Except for [`angle_btw()`](@ref), these functions are not exported by the
package since their use is limited to advanced algorithm customization scenarios.

```@docs
angle_btw
CluGen.clupoints_n_1_template
CluGen.fix_empty!
CluGen.fix_num_points!
```
