
# Copyright (c) 2020, 2021 Nuno Fachada and contributors
# Distributed under the MIT License (See accompanying file LICENSE or copy
# at http://opensource.org/licenses/MIT)

"""
    CluGenExtras

Useful extras for documenting and analyzing CluGen. These are not part of the
official CluGen module.
"""
module CluGenExtras

using CluGen
using LinearAlgebra
using Plots
using Printf

export plot2d

"""
    plot2d(d, r)

Create a nice descriptive plot for a `clugen()` run in 2D.

# Arguments
- `d`: main direction passed to `clugen()`.
- `r`: results returned by `clugen()`.
"""
function plot2d(d, r)

    # Normalize direction
    d1 = normalize(d)

    # Angle of d/d1
    d_angl = atan(d1[2] / d1[1])

    # Obtain number of clusters
    nclu = length(r.clusters_length)

    # Get current theme colors
    theme_colors = theme_palette(:auto).colors.colors

    # Plot background
    pltbg = RGB(0.92, 0.92, 0.95) #"whitesmoke"

    # ###### #
    # Plot 1 #
    # ###### #
    p1format = (x) -> x - trunc(x) ≈ 0 ? "$(round(Int,x))" : @sprintf("%.3f", x)

    # Setup plot
    p1 = plot(legend=false, title="1. Normalize direction", ticks=[], grid=false,
        framestyle=:zerolines, xlim=(-1.1,1.1), ylim=(-1.1,1.1))

    # Draw vector
    plot!(p1, [0, d1[1]],[0, d1[2]], label="", color=theme_colors[2], arrow=true,
        linewidth=2)

    # Draw unit circle
    plot!(p1, x->sin(x), x->cos(x), 0, 2π, linewidth = 1, color="grey82")

    # Add 1's to clarify it's the unit circle
    plot!(p1, annotations = (0.05, 1.05, text("1", pointsize=8, color="grey62")))
    plot!(p1, annotations = (1.05, 0.05, text("1", pointsize=8, color="grey62")))

    # ###### #
    # Plot 2 #
    # ###### #

    # Side length of square grid for placing illustrative sized clusters
    gside = ceil(Int, sqrt(nclu))

    # Relative illustrative cluster sizes
    iclusizes = r.clusters_size ./ maximum(r.clusters_size)

    p2 = plot(title="2. Determine cluster sizes", legend=false, showaxis=false,
        foreground_color_axis=ARGB(1,1,1,0), grid=false, ticks=[], aspectratio=1)
    #p2 = plot(title="2. Determine cluster sizes")

    for i in 1:nclu
        g_y = -((i - 1) ÷ gside)
        g_x = (i - 1) % gside
        scal = 0.48 * iclusizes[i]
        an = (g_x, g_y, text("$(r.clusters_size[i]) points", :center,
            pointsize=7, color=:black)) #theme_colors[i])))
        plot!(p2, x->sin(x) * scal + g_x, x->cos(x) * scal + g_y, 0, 2π,
            linewidth = 3, fill = (0, theme_colors[i]), fillalpha = 0.3,
            annotations = an)
    end

    # ###### #
    # Plot 3 #
    # ###### #
    # p3 = plot(r.clusters_center[:,1], r.clusters_center[:,2], seriestype=:scatter,
    #     group=map((x)->"Cluster $x",1:nclu), markersize=5, legend=false,
    #     title="3. Determine cluster centers", framestyle=:zerolines,
    #     formatter=x->"")
    p3 = plot(r.clusters_center[:,1], r.clusters_center[:,2], seriestype=:scatter,
        group=map((x)->"Cluster $x",1:nclu), markersize=5, legend=false,
        title="3. Determine cluster centers", formatter=x->"",
        framestyle=:grid, foreground_color_grid=:white, gridalpha=1,
        background_color_inside = pltbg, gridlinewidth=2, aspectratio=1)

    # ###### #
    # Plot 4 #
    # ###### #
    # p4 = plot(title="4. Determine cluster lengths", framestyle=:zerolines,
    #     formatter=x->"", legend=false)
    p4 = plot(title="4. Determine cluster lengths", formatter=x->"", legend=false,
        framestyle=:grid, foreground_color_grid=:white, gridalpha=1,
        background_color_inside = pltbg, gridlinewidth=2, aspectratio=1)
    for i in 1:length(r.clusters_length)
        l = r.clusters_length[i]
        p = points_on_line(r.clusters_center[i,:], d1, [-l/2,l/2])
        plot!(p4, p[:,1],p[:,2], linewidth=1, color=theme_colors[i])
    end
    for i in 1:length(r.clusters_length)
        plot!(p4, [r.clusters_center[i, 1]], [r.clusters_center[i, 2]],
            seriestype=:scatter, color=theme_colors[i], label="", markersize=5)
    end

    # ###### #
    # Plot 5 #
    # ###### #
    p5 = plot(title="5. Cluster angles w.r.t. direction", formatter=x->"",
        legend=false, framestyle=:grid, foreground_color_grid=:white,
        gridalpha=1, background_color_inside = pltbg, gridlinewidth=2, aspectratio=1)
    for i in 1:length(r.clusters_length)
        l = r.clusters_length[i]
        v1 = [cos(d_angl + r.clusters_angle[i]), sin(d_angl + r.clusters_angle[i])]
        v2 = [cos(d_angl - r.clusters_angle[i]), sin(d_angl - r.clusters_angle[i])]

        p = points_on_line(r.clusters_center[i,:], d1, [-l/2,l/2])
        v1edges = points_on_line(r.clusters_center[i,:], v1, [-l/2,l/2])
        v2edges = points_on_line(r.clusters_center[i,:], v2, [-l/2,l/2])

        poly = Shape([tuple(v1edges[1,:]...), tuple(v1edges[2,:]...),
            tuple(v2edges[2,:]...), tuple(v2edges[1,:]...), tuple(v1edges[1,:]...)])

        plot!(p5, poly, color=theme_colors[i], linecolor=theme_colors[i],
            fillalpha=0.3, linealpha=0.3)

        plot!(p5, p[:,1], p[:,2], linewidth=1, color=theme_colors[i])
    end
    for i in 1:length(r.clusters_length)
        plot!(p5, [r.clusters_center[i, 1]], [r.clusters_center[i, 2]],
            seriestype=:scatter, color=theme_colors[i], label="", markersize=5)
    end

    # ###### #
    # Plot 6 #
    # ###### #
    # p6 = plot(title="6. Determine cluster directions", framestyle=:zerolines,
    #     formatter=x->"", legend=false)
    p6 = plot(title="6. Determine cluster directions", formatter=x->"", legend=false,
        framestyle=:grid, foreground_color_grid=:white, gridalpha=1,
        background_color_inside = pltbg, gridlinewidth=2, aspectratio=1)
    for i in 1:nclu
        l = r.clusters_length[i]
        v1 = [cos(d_angl + r.clusters_angle[i]), sin(d_angl + r.clusters_angle[i])]
        v2 = [cos(d_angl - r.clusters_angle[i]), sin(d_angl - r.clusters_angle[i])]

        p = points_on_line(r.clusters_center[i,:], d1, [-l/2,l/2])
        v1edges = points_on_line(r.clusters_center[i,:], v1, [-l/2,l/2])
        v2edges = points_on_line(r.clusters_center[i,:], v2, [-l/2,l/2])

        poly = Shape([tuple(v1edges[1,:]...), tuple(v1edges[2,:]...),
            tuple(v2edges[2,:]...), tuple(v2edges[1,:]...), tuple(v1edges[1,:]...)])

        plot!(p6, poly, color=theme_colors[i], linecolor=theme_colors[i],
            fillalpha=0.15, linealpha=0.15)

        pf = points_on_line(
            r.clusters_center[i,:], r.clusters_direction[i, :], [-l/2,l/2])
        plot!(p6, pf[:,1],pf[:,2], linewidth=3, linecolor=theme_colors[i])
    end
    for i in 1:nclu
        plot!(p6, [r.clusters_center[i, 1]], [r.clusters_center[i, 2]],
            seriestype=:scatter, color=theme_colors[i], label="", markersize=5)
    end

    # ###### #
    # Plot 7 #
    # ###### #
    # p7 = plot(r.points_projection[:,1], r.points_projection[:,2],
    #     group=r.points_cluster, title="7.1. + 7.2. Point projections",
    #     framestyle=:zerolines, formatter=x->"", legend=false,
    #     seriestype=:scatter, markersize=3, markerstrokewidth=0.2)
    p7 = plot(r.points_projection[:,1], r.points_projection[:,2],
        group=r.points_cluster, title="7.1. + 7.2. Point projections",
        formatter=x->"", legend=false, seriestype=:scatter, markersize=3,
        markerstrokewidth=0.2,
        framestyle=:grid, foreground_color_grid=:white, gridalpha=1,
        background_color_inside = pltbg, gridlinewidth=2, aspectratio=1)

    # ###### #
    # Plot 8 #
    # ###### #

    # p8 = plot(r.points[:,1], r.points[:,2], group=r.points_cluster,
    #     title="7.3. Final points", framestyle=:zerolines, formatter=x->"",
    #     legend=false, seriestype=:scatter, markersize=4, markerstrokewidth=0.2)
    p8 = plot(r.points[:,1], r.points[:,2], group=r.points_cluster,
        title="7.3. Final points", formatter=x->"", legend=false,
        seriestype=:scatter, markersize=4, markerstrokewidth=0.2,
        framestyle=:grid, foreground_color_grid=:white, gridalpha=1,
        background_color_inside = pltbg, gridlinewidth=2, aspectratio=1)

    # ###### #
    # Plot 9 #
    # ###### #
    p9 = plot(framestyle=:none, showaxis=false)

    # ###################################################### #
    # Plot limits adjustment based on existing larger limits #
    # ###################################################### #

    # Initialize limits for cluster plots
    llow, lhigh = Inf, -Inf

    # Relevant plots
    plts = (p3, p4, p5, p6, p7, p8)

    # Obtain limits
    for plt in plts
        xlow_plt, xhigh_plt = xlims(plt)
        ylow_plt, yhigh_plt = ylims(plt)
        llow = min(xlow_plt, ylow_plt, llow)
        lhigh = max(xhigh_plt, yhigh_plt, lhigh)
    end

    # Apply larget limits to all relevant plots
    for plt in plts
        plot!(plt, xlims=(llow, lhigh), ylims=(llow, lhigh))
    end

    # ################## #
    # All plots combined #
    # ################## #
    allplt = plot(p1, p2, p3, p4, p5, p6, p7, p8, p9, layout = (3, 3),
        size=(1200,1200))

    return allplt
end

end # Module