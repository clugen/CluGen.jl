# Examples

TODO


```@setup 1
# Setup code for all examples
ENV["GKSwstype"] = "100"
using CluGen, Plots, Random
```

## Plots (temp)

If we plot for `clupoints_d_1()` (default):

```@example 1
projs = points_on_line([5.0,5.0], [1.0,0.0], -4:2:4) # hide
points = CluGen.clupoints_d_1(projs, 0.5, [1,0], [0,0], MersenneTwister(123)) # hide
all = vcat(projs, points)
plot(all[:,1], all[:,2], seriestype=:scatter, group=vcat(ones(5), 2 .* ones(5)), label=["Projections" "Points"], ylims=(3,7), size=(600,400))
savefig("clup_d_1.png"); nothing # hide
```

![](clup_d_1.png)

If we plot for `clupoints_d()`:

```@example 1
projs = points_on_line([5.0,5.0], [1.0,0.0], -4:2:4) # hide
points = CluGen.clupoints_d(projs, 0.5, [1,0], [0,0], MersenneTwister(123)) # hide
all = vcat(projs, points)
plot(all[:,1], all[:,2], seriestype=:scatter, group=vcat(ones(5), 2 .* ones(5)), label=["Projections" "Points"], ylims=(3,7), size=(600,400))
savefig("clup_d.png"); nothing # hide
```

![](clup_d.png)


## Others (check)

Example using clusizes_fn parameter for specifying all equal cluster sizes (note
this does not verify if clusters are empty nor if total points is actually respected)

    clusizes_fn=(nclu,tp,ae;rng=Random.GLOBAL_RNG)-> tp ÷ nclu .* ones(Integer, nclu)

