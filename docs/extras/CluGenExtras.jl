
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

    # Create clusters
    d1 = normalize(d)
    nclu = length(r.clusters_length)

    # Get current theme colors
    theme_colors = theme_palette(:auto).colors.colors

    # Plot 1
    p1format = (x) -> x ≈ 1 ? "1" : @sprintf("%.3f", x)

    p1 = plot([0,0], [0,0], label="User-specified direction",
        legend=:topleft, xlabel="x", ylabel="y", title="Step 1",
        color=theme_colors[2], linewidth=2, grid=false,xlim=(0, 1.1),
        ylim=(0, 1.1), ticks=[d[1], d1[1]], formatter=p1format)

    plot!(p1, [0, d[1]], [d[2], d[2]], linewidth=1, linestyle=:dot, label="",
        color=theme_colors[2])
    plot!(p1, [d[1], d[1]], [0, d[2]], linewidth=1, linestyle=:dot, label="",
        color=theme_colors[2])

    plot!(p1, [0, d1[1]], [d1[2], d1[2]], linewidth=1, linestyle=:dot, label="",
        color=theme_colors[1])
    plot!(p1, [d1[1], d1[1]], [0, d1[2]], linewidth=1, linestyle=:dot, label="",
        color=theme_colors[1])

    plot!(p1, d1, d1, label="Normalized direction", color=theme_colors[1],
        linestyle=:dash,linewidth=2)
    plot!(p1, [0, d[1]], [0, d[2]], label="", color=theme_colors[2], arrow=true,
        linewidth=2)
    plot!(p1, [0, d1[1]],[0, d1[2]], label="", color=theme_colors[1], arrow=true,
        linestyle=:dash,linewidth=2)

    # Plot 2
    p2 = plot(r.clusters_size, seriestype = :bar, group = 1:nclu,
        ylabel="Number of points", xlabel="Clusters", legend=false,
        title="Step 2", ylim=(0, 350))

    # Plot 3
    p3 = plot(r.clusters_center[:,1], r.clusters_center[:,2], seriestype=:scatter,
        group=map((x)->"Cluster $x",1:nclu), markersize=5, xlim=(-25,30),
        ylim=(-30,30), legend=:bottomleft, xlabel="x", ylabel="y", title="Step 3")

    # Plot 4
    p4 = plot(title="Step 4",xlim=(-25,30), ylim=(-30,30), legend=:bottomleft,
        xlabel="x", ylabel="y")
    for i in 1:length(r.clusters_length)
        l = r.clusters_length[i]
        p = points_on_line(r.clusters_center[i,:], d1, [-l/2,l/2])
        plot!(p4, p[:,1],p[:,2], label="Cluster $i", linewidth=2, linestyle=:dot)
    end
    for i in 1:length(r.clusters_length)
        l = r.clusters_length[i]
        p = points_on_line(r.clusters_center[i,:], d1, [-l/2,l/2])
        plot!(p4, [r.clusters_center[i, 1]], [r.clusters_center[i, 2]],
            seriestype=:scatter, color=theme_colors[i], label="", markersize=5)
    end

    # Plot 5
    p5 = plot(abs.(r.clusters_angle), seriestype = :bar, group = 1:nclu,
        ylabel="Angle diff. to main direction", xlabel="Clusters", legend=false,
        title="Step 5", ylim=(0, 0.33))

    # Plot 6
    p6 = plot(title="Step 6",xlim=(-25,30), ylim=(-30,30), legend=:bottomleft,
        xlabel="x", ylabel="y")
    for i in 1:nclu
        l = r.clusters_length[i]
        pf = points_on_line(
            r.clusters_center[i,:], r.clusters_direction[i, :], [-l/2,l/2])
        plot!(p6, pf[:,1],pf[:,2], label="Cluster $i", linewidth=3)
    end
    for i in 1:nclu
        l = r.clusters_length[i]
        po = points_on_line(r.clusters_center[i,:], d1, [-l/2,l/2])
        plot!(p6, po[:,1],po[:,2], label="", linewidth=1, linestyle=:dot, color="black")
        plot!(p6, [r.clusters_center[i, 1]], [r.clusters_center[i, 2]],
            seriestype=:scatter, color=theme_colors[i], label="", markersize=5)
    end

    # Plot 7.1
    p71 = plot(title="Step 7.1")

    # Plot 7.2
    p72 = plot(title="Step 7.2")

    # Plot 7.3
    p73 = plot(title="Step 7.3")

    # All plots
    allplt = plot(p1, p2, p3, p4, p5, p6, p71, p72, p73, layout = (3, 3), size=(1200,1200))

    return allplt
end

end # Module