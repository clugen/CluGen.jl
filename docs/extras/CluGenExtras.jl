
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

    # Obtain number of clusters
    nclu = length(r.clusters_length)

    # Get current theme colors
    theme_colors = theme_palette(:auto).colors.colors

    # ###### #
    # Plot 1 #
    # ###### #
    p1format = (x) -> x - trunc(x) ≈ 0 ? "$(round(Int,x))" : @sprintf("%.3f", x)

    # Setup plot
    p1 = plot(legend=false, title="1. Normalize direction", ticks=[-1, 0, 1],
        framestyle=:zerolines, xlim=(-1.1,1.1), ylim=(-1.1,1.1))

    # Draw vector
    plot!(p1, [0, d1[1]],[0, d1[2]], label="", color=theme_colors[2], arrow=true,
        linewidth=2)

    # Draw unit circle
    plot!(p1, x->sin(x), x->cos(x), 0, 2π, linewidth = 1, color="grey82")

    # ###### #
    # Plot 2 #
    # ###### #
    p2 = plot(r.clusters_size, seriestype = :bar, group = 1:nclu,
        ylabel="Number of points", xlabel="Clusters", legend=false,
        title="2. Determine cluster sizes", ylim=(0, 350))

    # ###### #
    # Plot 3 #
    # ###### #
    p3 = plot(r.clusters_center[:,1], r.clusters_center[:,2], seriestype=:scatter,
        group=map((x)->"Cluster $x",1:nclu), markersize=5, legend=false,
        title="3. Determine cluster centers", framestyle=:zerolines,
        formatter=x->"")

    # ###### #
    # Plot 4 #
    # ###### #
    p4 = plot(title="4. Determine cluster lengths", framestyle=:zerolines,
        formatter=x->"", legend=false)
    for i in 1:length(r.clusters_length)
        l = r.clusters_length[i]
        p = points_on_line(r.clusters_center[i,:], d1, [-l/2,l/2])
        plot!(p4, p[:,1],p[:,2], linewidth=2, linestyle=:dot)
    end
    for i in 1:length(r.clusters_length)
        l = r.clusters_length[i]
        p = points_on_line(r.clusters_center[i,:], d1, [-l/2,l/2])
        plot!(p4, [r.clusters_center[i, 1]], [r.clusters_center[i, 2]],
            seriestype=:scatter, color=theme_colors[i], label="", markersize=5)
    end

    # ###### #
    # Plot 5 #
    # ###### #
    p5 = plot(abs.(r.clusters_angle), seriestype = :bar, group = 1:nclu,
        ylabel="Angle diff. to main direction", xlabel="Clusters", legend=false,
        title="5. Cluster angles w.r.t. direction", ylim=(0, 0.33))

    # ###### #
    # Plot 6 #
    # ###### #
    p6 = plot(title="6. Determine cluster directions", framestyle=:zerolines,
        formatter=x->"", legend=false)
    for i in 1:nclu
        l = r.clusters_length[i]
        pf = points_on_line(
            r.clusters_center[i,:], r.clusters_direction[i, :], [-l/2,l/2])
        plot!(p6, pf[:,1],pf[:,2], linewidth=3)
    end
    for i in 1:nclu
        l = r.clusters_length[i]
        po = points_on_line(r.clusters_center[i,:], d1, [-l/2,l/2])
        plot!(p6, po[:,1],po[:,2], label="", linewidth=1, linestyle=:dot, color="black")
        plot!(p6, [r.clusters_center[i, 1]], [r.clusters_center[i, 2]],
            seriestype=:scatter, color=theme_colors[i], label="", markersize=5)
    end

    # ###### #
    # Plot 7 #
    # ###### #
    p7 = plot(r.points_projection[:,1], r.points_projection[:,2],
        group=r.points_cluster, title="7.1. + 7.2. Point projections",
        framestyle=:zerolines, formatter=x->"", legend=false,
        seriestype=:scatter, markersize=3, markerstrokewidth=0.2)

    # ###### #
    # Plot 8 #
    # ###### #

    p8 = plot(r.points[:,1], r.points[:,2], group=r.points_cluster,
        title="7.3. Final points", framestyle=:zerolines, formatter=x->"",
        legend=false, seriestype=:scatter, markersize=4, markerstrokewidth=0.2)

    # ###### #
    # Plot 9 #
    # ###### #
    p9 = plot(framestyle=:none, showaxis=false)

    # ###################################################### #
    # Plot limits adjustment based on existing larger limits #
    # ###################################################### #

    # Initialize limits for cluster plots
    xlow, xhigh, ylow, yhigh = Inf, -Inf, Inf, -Inf

    # Relevant plots
    plts = (p3, p4, p6, p7, p8)

    # Obtain limits
    for plt in plts
        xlow_plt, xhigh_plt = xlims(plt)
        ylow_plt, yhigh_plt = ylims(plt)
        xlow = min(xlow_plt, xlow)
        xhigh = max(xhigh_plt, xhigh)
        ylow = min(ylow_plt, ylow)
        yhigh = max(yhigh_plt, yhigh)
    end

    # Apply larget limits to all relevant plots
    for plt in plts
        plot!(plt, xlims=(xlow, xhigh), ylims=(ylow, yhigh))
    end

    # ################## #
    # All plots combined #
    # ################## #
    allplt = plot(p1, p2, p3, p4, p5, p6, p7, p8, p9, layout = (3, 3),
        size=(1200,1200))

    return allplt
end

end # Module