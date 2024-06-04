
# Copyright (c) 2020-2024 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

"""
    CluGenExtras

Useful extras for documenting and analyzing CluGen. These are not part of the
official CluGen module.
"""
module CluGenExtras

using CluGen
using LaTeXStrings
using LinearAlgebra
using Plots
using Random
using StatsPlots

export clupoints_n_hollow
export plot_clusizes!
export plot_examples_1d
export plot_examples_2d
export plot_examples_3d
export plot_examples_nd
export plot_point_placement_2d
export plot_story_2d

"""
    plot_story_2d(d, r)

Create a nice descriptive plot for a `clugen()` run in 2D.

# Arguments
- `d`: main direction passed to `clugen()`.
- `r`: results returned by `clugen()`.
- `cs_args`: extra arguments to pass to plot_clusizes!()
"""
function plot_story_2d(d, r; cs_args=Dict())

    # Normalize direction
    d1 = normalize(d)

    # Angle of d/d1
    d_angl = atan(d1[2] / d1[1])

    # Obtain number of clusters
    nclu = length(r.lengths)

    # Get current theme colors
    theme_colors = theme_palette(:auto).colors.colors

    # Plot background
    pltbg = RGB(0.92, 0.92, 0.95) #"whitesmoke"

    # ###### #
    # Plot 1 #
    # ###### #

    # Setup plot
    p1 = plot(;
        legend=false,
        ticks=[],
        grid=false,
        framestyle=:zerolines,
        background_color_inside=pltbg,
        xlim=(-1.2, 1.2),
        ylim=(-1.2, 1.2),
    )

    # Draw original vector
    plot!(
        p1,
        [0, d[1]],
        [0, d[2] .- 0.01];
        label="",
        color=theme_colors[1],
        arrow=true,
        linewidth=5,
    )
    plot!(
        p1; annotations=(0.7, 0.9, text(L"\mathbf{d}"; pointsize=15, color=theme_colors[1]))
    )

    # Draw dashed lines
    plot!(p1, [0, 1], [1, 1]; color=theme_colors[1], linewidth=1, linestyle=:dot)
    plot!(p1, [1, 1], [0, 1]; color=theme_colors[1], linewidth=1, linestyle=:dot)

    # Draw normalized vector
    plot!(
        p1,
        [0, d1[1]],
        [0, d1[2]] .+ 0.01;
        label="",
        color=theme_colors[2],
        arrow=true,
        linewidth=3,
        linealpha=1,
    )
    plot!(
        p1;
        annotations=(
            0.3, 0.55, text(L"\mathbf{\widehat{d}}"; pointsize=15, color=theme_colors[2])
        ),
    )

    # Draw unit circle
    plot!(p1, x -> sin(x), x -> cos(x), 0, 2π; linewidth=1, color=color = theme_colors[2])

    # Add 1's to clarify it's the unit circle
    plot!(p1; annotations=(0.05, 1.10, text("1"; pointsize=12)))
    plot!(p1; annotations=(1.05, 0.10, text("1"; pointsize=12)))

    # ###### #
    # Plot 2 #
    # ###### #

    p2 = plot(;
        title="2. Cluster sizes",
        legend=false,
        showaxis=false,
        titlefontsize=8,
        titlelocation=:left,
        background_color_inside=pltbg,
        foreground_color_axis=ARGB(1, 1, 1, 0),
        grid=false,
        ticks=[],
        aspectratio=1,
    )

    # Use auxiliary function to perform plotting
    plot_clusizes!(p2, r.sizes; cs_args...)

    # ###### #
    # Plot 3 #
    # ###### #
    p3 = plot(
        r.centers[:, 1],
        r.centers[:, 2];
        seriestype=:scatter,
        group=map((x) -> "Cluster $x", 1:nclu),
        markersize=5,
        legend=false,
        title="3. Cluster centers",
        formatter=x -> "",
        titlefontsize=8,
        titlelocation=:left,
        framestyle=:grid,
        foreground_color_grid=:white,
        gridalpha=1,
        background_color_inside=pltbg,
        gridlinewidth=2,
        aspectratio=1,
    )

    # ###### #
    # Plot 4 #
    # ###### #
    p4 = plot(;
        title="4. Lengths of cluster-supporting lines",
        formatter=x -> "",
        legend=false,
        framestyle=:grid,
        foreground_color_grid=:white,
        gridalpha=1,
        titlefontsize=8,
        titlelocation=:left,
        background_color_inside=pltbg,
        gridlinewidth=2,
        aspectratio=1,
    )
    for i in 1:length(r.lengths)
        l = r.lengths[i]
        p = points_on_line(r.centers[i, :], d1, [-l / 2, l / 2])
        plot!(p4, p[:, 1], p[:, 2]; linewidth=1, color=theme_colors[i])
    end
    for i in 1:length(r.lengths)
        plot!(
            p4,
            [r.centers[i, 1]],
            [r.centers[i, 2]];
            seriestype=:scatter,
            color=theme_colors[i],
            label="",
            markersize=5,
        )
    end

    # ###### #
    # Plot 5 #
    # ###### #
    p5 = plot(;
        title="5. Angles between direction and cluster-supporting lines",
        formatter=x -> "",
        legend=false,
        framestyle=:grid,
        foreground_color_grid=:white,
        titlefontsize=8,
        titlelocation=:left,
        gridalpha=1,
        background_color_inside=pltbg,
        gridlinewidth=2,
        aspectratio=1,
    )
    for i in 1:length(r.lengths)
        l = r.lengths[i]
        v1 = [cos(d_angl + r.angles[i]), sin(d_angl + r.angles[i])]
        v2 = [cos(d_angl - r.angles[i]), sin(d_angl - r.angles[i])]

        p = points_on_line(r.centers[i, :], d1, [-l / 2, l / 2])
        v1edges = points_on_line(r.centers[i, :], v1, [-l / 2, l / 2])
        v2edges = points_on_line(r.centers[i, :], v2, [-l / 2, l / 2])

        poly = Shape([
            tuple(v1edges[1, :]...),
            tuple(v1edges[2, :]...),
            tuple(v2edges[2, :]...),
            tuple(v2edges[1, :]...),
            tuple(v1edges[1, :]...),
        ])

        plot!(
            p5,
            poly;
            color=theme_colors[i],
            linecolor=theme_colors[i],
            fillalpha=0.3,
            linealpha=0.3,
        )

        #plot!(p5, p[:,1], p[:,2], linewidth=1, color=theme_colors[i])
    end
    for i in 1:length(r.lengths)
        plot!(
            p5,
            [r.centers[i, 1]],
            [r.centers[i, 2]];
            seriestype=:scatter,
            color=theme_colors[i],
            label="",
            markersize=5,
        )
    end

    # ###### #
    # Plot 6 #
    # ###### #
    p6 = plot(;
        title="6.1. Direction of cluster-supporting lines",
        formatter=x -> "",
        legend=false,
        titlefontsize=8,
        titlelocation=:left,
        framestyle=:grid,
        foreground_color_grid=:white,
        gridalpha=1,
        background_color_inside=pltbg,
        gridlinewidth=2,
        aspectratio=1,
    )
    for i in 1:nclu
        l = r.lengths[i]
        v1 = [cos(d_angl + r.angles[i]), sin(d_angl + r.angles[i])]
        v2 = [cos(d_angl - r.angles[i]), sin(d_angl - r.angles[i])]

        p = points_on_line(r.centers[i, :], d1, [-l / 2, l / 2])
        v1edges = points_on_line(r.centers[i, :], v1, [-l / 2, l / 2])
        v2edges = points_on_line(r.centers[i, :], v2, [-l / 2, l / 2])

        poly = Shape([
            tuple(v1edges[1, :]...),
            tuple(v1edges[2, :]...),
            tuple(v2edges[2, :]...),
            tuple(v2edges[1, :]...),
            tuple(v1edges[1, :]...),
        ])

        plot!(
            p6,
            poly;
            color=theme_colors[i],
            linecolor=theme_colors[i],
            fillalpha=0.15,
            linealpha=0.15,
        )

        pf = points_on_line(r.centers[i, :], r.directions[i, :], [-l / 2, l / 2])
        plot!(p6, pf[:, 1], pf[:, 2]; linewidth=3, linecolor=theme_colors[i])
    end
    for i in 1:nclu
        plot!(
            p6,
            [r.centers[i, 1]],
            [r.centers[i, 2]];
            seriestype=:scatter,
            color=theme_colors[i],
            label="",
            markersize=5,
        )
    end

    # ###### #
    # Plot 7 #
    # ###### #
    p7 = plot(;
        titlefontsize=8,
        titlelocation=:left,
        title="6.2-6.3. Point projections on cluster-supporting lines",
        formatter=x -> "",
        legend=false,
        framestyle=:grid,
        foreground_color_grid=:white,
        gridalpha=1,
        background_color_inside=pltbg,
        gridlinewidth=2,
        aspectratio=1,
    )

    # Lines
    for i in 1:nclu
        l = r.lengths[i]
        pf = points_on_line(r.centers[i, :], r.directions[i, :], [-l / 2, l / 2])
        plot!(p7, pf[:, 1], pf[:, 2]; linewidth=3, linecolor=theme_colors[i], linealpha=0.3)
    end

    # Line markers along cluster-supporting lines
    ol = 2.2
    for i in 1:nclu
        l = r.lengths[i]
        d_ortho = rand_ortho_vector(r.directions[i, :])

        strt = i == 1 ? 0 : cumsum(r.sizes[1:(i - 1)])[end]
        for j in 1:r.sizes[i]
            pti = strt + j
            pts = points_on_line(r.projections[pti, :], d_ortho, [-ol / 2, ol / 2])
            plot!(p7, pts[:, 1], pts[:, 2]; linecolor=theme_colors[i], linewidth=0.3)
        end
    end

    # Line centers
    for i in 1:length(r.lengths)
        plot!(
            p7,
            [r.centers[i, 1]],
            [r.centers[i, 2]];
            seriestype=:scatter,
            color=theme_colors[i],
            label="",
            markersize=5,
        )
    end

    # ###### #
    # Plot 8 #
    # ###### #
    p8 = plot(;
        titlefontsize=8,
        titlelocation=:left,
        title="6.2-6.3. Point projections on cluster-supporting lines",
        formatter=x -> "",
        legend=false,
        framestyle=:grid,
        foreground_color_grid=:white,
        gridalpha=1,
        background_color_inside=pltbg,
        gridlinewidth=2,
        aspectratio=1,
    )

    # Lines
    for i in 1:nclu
        l = r.lengths[i]
        pf = points_on_line(r.centers[i, :], r.directions[i, :], [-l / 2, l / 2])
        plot!(p8, pf[:, 1], pf[:, 2]; linewidth=3, linecolor=theme_colors[i], linealpha=0.3)
    end

    # Projections
    plot!(
        p8,
        r.projections[:, 1],
        r.projections[:, 2];
        group=r.clusters,
        seriestype=:scatter,
        markersize=0.8,
        markerstrokewidth=0.1,
        markerstrokealpha=0,
        color=:black,
        markeralpha=0.6,
    )

    # ###### #
    # Plot 9 #
    # ###### #

    p9 = plot(;
        title="6.4. Final points from their projections",
        formatter=x -> "",
        legend=false,
        titlefontsize=8,
        titlelocation=:left,
        framestyle=:grid,
        foreground_color_grid=:white,
        gridalpha=1,
        background_color_inside=pltbg,
        gridlinewidth=2,
        aspectratio=1,
    )

    for i in 1:nclu
        l = r.lengths[i]

        strt = i == 1 ? 0 : cumsum(r.sizes[1:(i - 1)])[end]
        for j in 1:r.sizes[i]
            pti = strt + j
            plot!(
                p9,
                [r.projections[pti, 1], r.points[pti, 1]],
                [r.projections[pti, 2], r.points[pti, 2]];
                linecolor=theme_colors[i],
            )#, linealpha=0.3)
        end

        fnsh = strt + r.sizes[i]
        strt += 1

        plot!(
            p9,
            r.points[strt:fnsh, 1],
            r.points[strt:fnsh, 2];
            seriestype=:scatter,
            markersize=1.5,
            markerstrokewidth=0.1,
            markeralpha=0.6,
            color=:black,
        )#theme_colors[i])

        pf = points_on_line(r.centers[i, :], r.directions[i, :], [-l / 2, l / 2])
        plot!(p9, pf[:, 1], pf[:, 2]; linewidth=3, linecolor=theme_colors[i], linealpha=0.5)
    end

    # ####### #
    # Plot 10 #
    # ####### #
    p10 = plot(
        r.points[:, 1],
        r.points[:, 2];
        group=r.clusters,
        title="End result",
        formatter=x -> "",
        legend=false,
        titlefontsize=8,
        titlelocation=:left,
        seriestype=:scatter,
        markersize=1.5,
        markerstrokewidth=0,
        markerstrokealpha=0,
        framestyle=:grid,
        foreground_color_grid=:white,
        gridalpha=1,
        background_color_inside=pltbg,
        gridlinewidth=2,
        aspectratio=1,
    )

    # ###################################################### #
    # Plot limits adjustment based on existing larger limits #
    # ###################################################### #

    # Initialize limits for cluster plots
    llow, lhigh = Inf, -Inf

    # Relevant plots
    plts = (p3, p4, p5, p6, p7, p8, p9, p10)

    # Obtain limits
    for plt in plts
        xlow_plt, xhigh_plt = xlims(plt)
        ylow_plt, yhigh_plt = ylims(plt)
        llow = min(xlow_plt, ylow_plt, llow)
        lhigh = max(xhigh_plt, yhigh_plt, lhigh)
    end

    # Apply larget limits to all relevant plots
    for plt in plts
        plot!(plt; xlims=(llow, lhigh), ylims=(llow, lhigh))
    end

    # ################## #
    # All plots combined #
    # ################## #
    allplt = plot(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10; layout=(2, 5), size=(1500, 600))

    return allplt, (p1, p2, p3, p4, p5, p6, p7, p8, p9, p10)
end

"""
    plot_clusizes!(
        plt::Plots.Plot,
        clusizes::AbstractArray{<:Integer, 1},
    ) ->  Plots.Plot

Plots cluster sizes within circles which are themselves sized accordingly.
"""
function plot_clusizes!(
    plt::Plots.Plot,
    clusizes::AbstractArray{<:Integer,1};
    maxsize::Union{Nothing,Integer}=nothing,
    fontsize::Integer=8,
    pt_str::AbstractString="<POINTS> points",
    total_str::Union{Nothing,AbstractString}=nothing,
)::Plots.Plot

    # Get current theme colors
    theme_colors = theme_palette(:auto).colors.colors

    # Number of clusters
    nclu = length(clusizes)

    # Side length of square grid for placing illustrative sized clusters
    gside = ceil(Int, sqrt(nclu))

    # If no reference maximum size was given, get maximum size from the largest
    # cluster
    if maxsize === nothing
        maxsize = maximum(clusizes)
    end

    # Relative illustrative cluster sizes
    iclusizes = clusizes ./ maxsize

    # Draw circles with cluster sizes
    for i in 1:nclu
        g_y = -((i - 1) ÷ gside)
        g_x = (i - 1) % gside
        scal = 0.48 * iclusizes[i]
        txt = replace(pt_str, "<POINTS>" => "$(clusizes[i])")
        if pt_str isa LaTeXString
            txt = LaTeXString(txt)
        end
        an = (g_x, g_y, text(txt, :center; pointsize=fontsize, color=:black))
        plot!(
            plt,
            x -> sin(x) * scal + g_x,
            x -> cos(x) * scal + g_y,
            0,
            2π;
            linewidth=3,
            fill=(0, theme_colors[i]),
            fillalpha=0.3,
            annotations=an,
        )
    end

    # Add annotation with total points?
    if total_str !== nothing
        txt = replace(total_str, "<POINTS>" => "$(sum(clusizes))")
        if total_str isa LaTeXString
            txt = LaTeXString(txt)
        end
        an = (
            gside / 4,
            -gside / 3.7,
            text(LaTeXString(txt), :center; pointsize=fontsize, color=:black),
        )
        plot!(plt; annotations=an)
    end

    return plt
end

"""
    clupoints_n_hollow(
        projs::AbstractArray{<:Real,2},
        lat_disp::Real,
        line_len::Real,
        clu_dir::AbstractArray{<:Real,1},
        clu_ctr::AbstractArray{<:Real,1};
        rng::AbstractRNG=Random.GLOBAL_RNG
    ) -> AbstractArray{<:Real}

Alternative function for the `point_dist_fn` parameter of the `clugen()` function
for creating hollow clusters.

# Arguments
- `projs`: point projections on the cluster-supporting line.
- `lat_disp`: standard deviation for the normal distribution, i.e., cluster lateral
  dispersion.
- `line_len`: length of cluster-supporting line.
- `clu_dir`: direction of the cluster-supporting line (unit vector).
- `clu_ctr`: center position of the cluster-supporting line center position.
- `rng`: an optional pseudo-random number generator for reproducible executions.
"""
function clupoints_n_hollow(
    projs::AbstractArray{<:Real,2},
    lat_disp::Real,
    line_len::Real,
    clu_dir::AbstractArray{<:Real,1},
    clu_ctr::AbstractArray{<:Real,1};
    rng::AbstractRNG=Random.GLOBAL_RNG,
)::AbstractArray{<:Real}

    # Number of dimensions
    num_dims = length(clu_dir)

    # Number of points in this cluster
    clu_num_points = size(projs, 1)

    clu_pts = zeros(clu_num_points, num_dims)

    # Edges of cluster-supporting line
    edge1 = clu_ctr + (line_len / 2) .* clu_dir
    edge2 = clu_ctr - (line_len / 2) .* clu_dir

    for i in 1:clu_num_points
        prj = projs[i, :]

        # Absolute and relative positions of projection w.r.t. the center
        pa = norm(prj - clu_ctr)
        pr = clamp(pa / (line_len / 2), 0, 1)

        # Determine angle associated with this projection
        a = -pi / 2 * (pr - 1) # linear

        # Alternatives:
        #a = acos(pr)                                       # arccos
        #a = pi / 2 * (pr - 1)^2                            # quadratic
        #a = pi / 2 * (1 - 1 / (1 + exp(-10 * (pr - 0.5)))) # logistic
        #a = pi / 2 * sqrt(1 - pr^2)                        # half-circle

        # Get a random vector at this angle
        v = rand_vector_at_angle(clu_dir, a; rng=rng)

        # Point dispersion along vector at angle
        f = (lat_disp / 6) * randn(rng) + lat_disp

        # Determine two possible points at the edges of vector (line) at angle
        pt1 = prj + f .* v
        pt2 = prj - f .* v

        # Determine the point which is farther from the center of the cluster-supporting line
        ctr_dist = -Inf
        pt = nothing

        for pt_curr in (pt1, pt2)
            for edge_curr in (edge1, edge2)
                curr_norm = norm(pt_curr - edge_curr)
                if curr_norm > ctr_dist
                    ctr_dist = curr_norm
                    pt = pt_curr
                end
            end
        end

        clu_pts[i, :] = pt
    end
    return clu_pts
end

"""
    plot_point_placement_2d(
        pre_projs::AbstractArray{<:Real, 1},
        line_len::Integer,
        clu_ctr::AbstractArray{<:Real, 1},
        clu_dir::AbstractArray{<:Real, 1},
        lat_disp::Real,
        clupoints_fn::Function
    ) -> Plots.Plot

Helper/visual debugging function which plots a 2D cluster connecting the point
projections on the cluster-supporting line to the respective final cluster points.

# Arguments
- `pre_projs`: distribution of points along the line, with values generally
   between -1 and 1 (though this function will work even if some points are
   outside the line); values close to -1 or -1 correspond to points near the
   edges, while values close to zero correspond to points near the center of the
   line.
- `line_len`: length of cluster-supporting line.
- `clu_ctr`: center position of the cluster-supporting line center position.
- `clu_dir`: direction of the cluster-supporting line (unit vector).
- `lat_disp`: standard deviation for the normal distribution, i.e., cluster lateral
  dispersion.
- `clupoints_fn`: function to place the final points given their projections on
  the cluster-supporting line.
- `rng`: an optional pseudo-random number generator for reproducible executions.

# Examples
```julia-repl
julia> include("docs/CluGenExtras.jl")
Main.CluGenExtras

julia> using Main.GluGenExtras

julia> plot_point_placement_2d(rand(800) .* 40 .- 20, 40, [0,0],
           normalize([1,1]), 5, clupoints_n_hollow)
```
"""
function plot_point_placement_2d(
    pre_projs::AbstractArray{<:Real,1},
    line_len::Integer,
    clu_ctr::AbstractArray{<:Real,1},
    clu_dir::AbstractArray{<:Real,1},
    lat_disp::Real,
    clupoints_fn::Function;
    rng::AbstractRNG=Random.GLOBAL_RNG,
)::Plots.Plot

    # Plot background
    pltbg = RGB(0.92, 0.92, 0.95) #"whitesmoke"

    # Determine point projections on the line
    projs = points_on_line(clu_ctr, clu_dir, pre_projs)

    # Determine line edges
    edge1 = clu_ctr + (line_len / 2) .* clu_dir
    edge2 = clu_ctr - (line_len / 2) .* clu_dir

    # Obtain final points from their projections on the line
    pts = clupoints_fn(projs, lat_disp, line_len, clu_dir, clu_ctr; rng=rng)

    # Create plot
    plt = plot(;
        legend=false,
        formatter=x -> "",
        framestyle=:grid,
        foreground_color_grid=:white,
        gridalpha=1,
        background_color_inside=pltbg,
        gridlinewidth=2,
        aspectratio=1,
    )

    # Draw line
    plot!(plt, [edge1[1], edge2[1]], [edge1[2], edge2[2]]; color=:orange, linewidth=4)

    # Draw edeges
    plot!(
        plt,
        [edge1[1], edge2[1]],
        [edge1[2], edge2[2]];
        seriestype=:scatter,
        markershape=:vline,
        markercolor=:orange,
        markerstrokewidth=0.1,
        markersize=20,
    )

    # Draw center
    plot!(
        plt,
        [clu_ctr[1]],
        [clu_ctr[2]];
        seriestype=:scatter,
        markershape=:circle,
        markercolor=:orange,
        markersize=8,
        markerstrokewidth=0.1,
    )

    # Draw line from projection to respective point
    for i in 1:size(projs, 1)
        plot!(
            [pts[i, 1], projs[i, 1]], [pts[i, 2], projs[i, 2]]; color=:grey, linewidth=0.5
        )
    end

    # Draw projections
    plot!(
        plt,
        projs[:, 1],
        projs[:, 2];
        seriestype=:scatter,
        markersize=2.5,
        markerstrokewidth=0.1,
        markercolor=:red,
    )

    # Draw final points
    plot!(
        plt,
        pts[:, 1],
        pts[:, 2];
        markershape=:cross,
        seriestype=:scatter,
        markersize=4,
        markerstrokewidth=0.1,
        markercolor=:green,
    )

    # Return plot
    return plt
end

"""
    plot_examples_1d(
        ets...;
        ymax::Real = 0.85,
        pmargin::Real = 0.1,
        ncols::Integer = 3,
        side::Integer = 300,
        clusters_field = :clusters
    ) -> Plots.Plot

Plot a set of 1D examples.
"""
function plot_examples_1d(
    ets...; ymax::Real=0.85, pmargin::Real=0.1, ncols::Integer=3, side::Integer=300,
    clusters_field=:clusters
)::Plots.Plot

    # Get examples
    ex = ets[1:2:end]
    # Get titles
    et = ets[2:2:end]

    # Number of plots and number of rows in combined plot
    num_plots = length(ets) ÷ 2
    nrows = max(1, ceil(Integer, num_plots / ncols))
    blank_plots = nrows * ncols - num_plots

    # Get limits in each dimension (just one in this case)
    (xmaxs, xmins) = get_plot_lims(ex, pmargin)

    # Create individual plots
    plts = map(
        # Density plots
        ((e, t),) -> plot(
            getindex(e, :points);
            seriestype=:density,
            group=getindex(e, clusters_field),
            fill=true,
            fillalpha=0.35,
            legend=nothing,
            title=t,
            titlefontsize=9,
            xlabel="\$x\$",
            color=theme_palette(:auto).colors.colors',
            aspectratio=12,
            grid=false,
            showaxis=:x,
            framestyle=:zerolines,
            yticks=false,
            xlim=(xmins[1], xmaxs[1]),
            ylim=(-0.09, ymax),
        ),
        zip(ex, et),
    )
    map(
        # Scatter plots on y ≈ 0
        ((e, p),) -> plot!(
            p,
            getindex(e, :points),
            -0.04 .* ones(sum(e.sizes));
            group=getindex(e, clusters_field),
            seriestype=:scatter,
            markersize=2.5,
            markerstrokewidth=0.1,
            legend=nothing,
            color=theme_palette(:auto).colors.colors',
        ),
        zip(ex, plts),
    )

    # Remaining plots are left blank
    for _ in 1:blank_plots
        push!(plts, plot(; grid=false, showaxis=false, ticks=false))
    end

    # Return plots combined as subplots
    return plot(plts...; size=(side * ncols, side * nrows), layout=(nrows, ncols))
end

"""
    plot_examples_2d(
        ets...;
        pmargin::Real = 0.1,
        ncols::Integer = 3,
        side::Integer = 300,
        clusters_field = :clusters
    ) -> Plots.Plot

Plot a set of 2D examples.
"""
function plot_examples_2d(
    ets...; pmargin::Real=0.1, ncols::Integer=3, side::Integer=300,
    clusters_field=:clusters
)::Plots.Plot

    # Get examples
    ex = ets[1:2:end]
    # Get titles
    et = ets[2:2:end]

    # Number of plots and number of rows in combined plot
    num_plots = length(ets) ÷ 2
    nrows = max(1, ceil(Integer, num_plots / ncols))
    blank_plots = nrows * ncols - num_plots

    # Get limits in each dimension
    (xmaxs, xmins) = get_plot_lims(ex, pmargin)

    # Create individual plots
    plts = map(
        ((e, t),) -> plot(
            getindex(e, :points)[:, 1],
            getindex(e, :points)[:, 2];
            seriestype=:scatter,
            group=getindex(e, clusters_field),
            markersize=2.5,
            markerstrokewidth=0.2,
            markerstrokecolor=:white,
            markerstrokealpha=0.8,
            aspectratio=1,
            legend=nothing,
            title=t,
            titlefontsize=9,
            xlim=(xmins[1], xmaxs[1]),
            ylim=(xmins[2], xmaxs[2]),
        ),
        zip(ex, et),
    )

    # Remaining plots are left blank
    for _ in 1:blank_plots
        push!(plts, plot(; grid=false, showaxis=false, ticks=false))
    end

    # Return plots combined as subplots
    return plot(plts...; size=(side * ncols, side * nrows), layout=(nrows, ncols))
end

"""
    plot_examples_3d(
        ets...;
        pmargin::Real = 0.1,
        ncols::Integer = 3,
        side::Integer = 300,
        clusters_field = :clusters
    ) -> Plots.Plot

Plot a set of 3D examples.
"""
function plot_examples_3d(
    ets...; pmargin::Real=0.02, ncols::Integer=3, side::Integer=300,
    clusters_field=:clusters
)::Plots.Plot

    # Get examples
    ex = ets[1:2:end]
    # Get titles
    et = ets[2:2:end]

    # Number of plots and number of rows in combined plot
    num_plots = length(ets) ÷ 2
    nrows = max(1, ceil(Integer, num_plots / ncols))
    blank_plots = nrows * ncols - num_plots

    # Get limits in each dimension
    (xmaxs, xmins) = get_plot_lims(ex, pmargin)

    # Create individual plots
    plts = map(
        ((e, t),) -> plot(
            getindex(e, :points)[:, 1],
            getindex(e, :points)[:, 2],
            getindex(e, :points)[:, 3];
            seriestype=:scatter,
            group=getindex(e, clusters_field),
            markersize=2.5,
            markerstrokewidth=0.2,
            markerstrokecolor=:white,
            markerstrokealpha=0.8,
            aspectratio=1,
            legend=nothing,
            title=t,
            titlefontsize=9,
            xlim=(xmins[1], xmaxs[1]),
            ylim=(xmins[2], xmaxs[2]),
            zlim=(xmins[3], xmaxs[3]),
            xlabel="\$x\$",
            ylabel="\$y\$",
            zlabel="\$z\$",
        ),
        zip(ex, et),
    )

    # Remaining plots are left blank
    for _ in 1:blank_plots
        push!(plts, plot(; grid=false, showaxis=false, ticks=false))
    end

    # Return plots combined as subplots
    return plot(plts...; size=(side * ncols, side * nrows), layout=(nrows, ncols))
end

"""
    plot_examples_nd(
        e,
        title;
        pmargin::Real = 0.1,
        side::Integer = 200,
        clusters_field = :clusters
    ) -> Plots.Plot

Plot one nD example.
"""
function plot_examples_nd(
    e, title;
    pmargin::Real=0.1, side::Integer=200, clusters_field=:clusters
)::Plots.Plot

    # How many dimensions?
    nd = size(e.points, 2)

    # Get limits in each dimension
    (xmaxs, xmins) = get_plot_lims((e,), pmargin)

    # All possible combinations
    idxs = Iterators.product(1:nd, 1:nd)

    # Create individual plots
    plts = map(
        ei -> if ei[1] == ei[2]
            plot(;
                grid=false,
                showaxis=false,
                ticks=false,
                annotations=(0.5, 0.5, Plots.text("\$x_$(ei[1])\$", 30, :center)),
            )
        else
            plot(
                getindex(e, :points)[:, ei[1]],
                getindex(e, :points)[:, ei[2]];
                group=getindex(e, clusters_field),
                seriestype=:scatter,
                markersize=2,
                markerstrokewidth=0.1,
                markerstrokecolor=:white,
                markerstrokealpha=0.8,
                aspectratio=1,
                legend=nothing,
                tickfontsize=5,
                xlim=(xmins[ei[1]], xmaxs[ei[1]]),
                ylim=(xmins[ei[2]], xmaxs[ei[2]]),
            )
        end,
        idxs,
    )

    # Return plots combined as subplots
    return plot(
        plts...;
        size=(side * nd, side * nd),
        layout=(nd, nd),
        plot_title=title,
        plot_titlefontsize=10,
    )
end

"""
    get_plot_lims(ex::Tuple, pmargin::Real) -> Tuple

Determine the plot limits for the clugen results given in `ex`.
"""
function get_plot_lims(ex::Tuple, pmargin::Real)::Tuple

    # Get maximum and minimum points in each dimension
    xmaxs = maximum(vcat(map(e -> maximum(getindex(e, :points); dims=1), ex)...); dims=1)
    xmins = minimum(vcat(map(e -> minimum(getindex(e, :points); dims=1), ex)...); dims=1)

    # Determine plots centers in each dimension
    xcenters = (xmaxs + xmins) / 2

    # Determine plots span for all dimensions
    sidespan = (1 + pmargin) * maximum(abs.(xmaxs - xmins)) / 2

    # Determine final plots limits
    xmaxs = xcenters .+ sidespan
    xmins = xcenters .- sidespan

    return (xmaxs, xmins)
end

end # Module
