
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
    nclu = length(r.cluster_lengths)

    # Get current theme colors
    theme_colors = theme_palette(:auto).colors.colors

    # Plot background
    pltbg = RGB(0.92, 0.92, 0.95) #"whitesmoke"

    # ###### #
    # Plot 1 #
    # ###### #
    p1format = (x) -> x - trunc(x) ≈ 0 ? "$(round(Int,x))" : @sprintf("%.3f", x)

    # Setup plot
    p1 = plot(legend=false, title="1. Normalize `direction`", ticks=[], grid=false,
        framestyle=:zerolines, xlim=(-1.1,1.1), ylim=(-1.1,1.1))

    # Draw vector
    plot!(p1, [0, d1[1]],[0, d1[2]], label="", color=theme_colors[2], arrow=true,
        titlefontsize=8, titlelocation=:left,
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
    iclusizes = r.cluster_sizes ./ maximum(r.cluster_sizes)

    p2 = plot(title="2. Determine cluster sizes", legend=false, showaxis=false,
        titlefontsize=8, titlelocation=:left,
        foreground_color_axis=ARGB(1,1,1,0), grid=false, ticks=[], aspectratio=1)

    for i in 1:nclu
        g_y = -((i - 1) ÷ gside)
        g_x = (i - 1) % gside
        scal = 0.48 * iclusizes[i]
        an = (g_x, g_y, text("$(r.cluster_sizes[i]) points", :center,
            pointsize=7, color=:black)) #theme_colors[i])))
        plot!(p2, x->sin(x) * scal + g_x, x->cos(x) * scal + g_y, 0, 2π,
            linewidth = 3, fill = (0, theme_colors[i]), fillalpha = 0.3,
            annotations = an)
    end

    # ###### #
    # Plot 3 #
    # ###### #
    p3 = plot(r.cluster_centers[:,1], r.cluster_centers[:,2], seriestype=:scatter,
        group=map((x)->"Cluster $x",1:nclu), markersize=5, legend=false,
        title="3. Determine cluster centers", formatter=x->"",
        titlefontsize=8, titlelocation=:left,
        framestyle=:grid, foreground_color_grid=:white, gridalpha=1,
        background_color_inside = pltbg, gridlinewidth=2, aspectratio=1)

    # ###### #
    # Plot 4 #
    # ###### #
    p4 = plot(title="4. Determine lengths of cluster-supporting lines", formatter=x->"",
        legend=false, framestyle=:grid, foreground_color_grid=:white, gridalpha=1,
        titlefontsize=8, titlelocation=:left,
        background_color_inside = pltbg, gridlinewidth=2, aspectratio=1)
    for i in 1:length(r.cluster_lengths)
        l = r.cluster_lengths[i]
        p = points_on_line(r.cluster_centers[i,:], d1, [-l/2,l/2])
        plot!(p4, p[:,1],p[:,2], linewidth=1, color=theme_colors[i])
    end
    for i in 1:length(r.cluster_lengths)
        plot!(p4, [r.cluster_centers[i, 1]], [r.cluster_centers[i, 2]],
            seriestype=:scatter, color=theme_colors[i], label="", markersize=5)
    end

    # ###### #
    # Plot 5 #
    # ###### #
    p5 = plot(title="5. Get angles between `direction` and cluster-supporting lines",
        formatter=x->"",
        legend=false, framestyle=:grid, foreground_color_grid=:white,
        titlefontsize=8, titlelocation=:left,
        gridalpha=1, background_color_inside = pltbg, gridlinewidth=2, aspectratio=1)
    for i in 1:length(r.cluster_lengths)
        l = r.cluster_lengths[i]
        v1 = [cos(d_angl + r.cluster_angles[i]), sin(d_angl + r.cluster_angles[i])]
        v2 = [cos(d_angl - r.cluster_angles[i]), sin(d_angl - r.cluster_angles[i])]

        p = points_on_line(r.cluster_centers[i,:], d1, [-l/2,l/2])
        v1edges = points_on_line(r.cluster_centers[i,:], v1, [-l/2,l/2])
        v2edges = points_on_line(r.cluster_centers[i,:], v2, [-l/2,l/2])

        poly = Shape([tuple(v1edges[1,:]...), tuple(v1edges[2,:]...),
            tuple(v2edges[2,:]...), tuple(v2edges[1,:]...), tuple(v1edges[1,:]...)])

        plot!(p5, poly, color=theme_colors[i], linecolor=theme_colors[i],
            fillalpha=0.3, linealpha=0.3)

        #plot!(p5, p[:,1], p[:,2], linewidth=1, color=theme_colors[i])
    end
    for i in 1:length(r.cluster_lengths)
        plot!(p5, [r.cluster_centers[i, 1]], [r.cluster_centers[i, 2]],
            seriestype=:scatter, color=theme_colors[i], label="", markersize=5)
    end

    # ###### #
    # Plot 6 #
    # ###### #
    p6 = plot(title="6. Determine direction of cluster-supporting lines",
        formatter=x->"", legend=false,
        titlefontsize=8, titlelocation=:left,
        framestyle=:grid, foreground_color_grid=:white, gridalpha=1,
        background_color_inside = pltbg, gridlinewidth=2, aspectratio=1)
    for i in 1:nclu
        l = r.cluster_lengths[i]
        v1 = [cos(d_angl + r.cluster_angles[i]), sin(d_angl + r.cluster_angles[i])]
        v2 = [cos(d_angl - r.cluster_angles[i]), sin(d_angl - r.cluster_angles[i])]

        p = points_on_line(r.cluster_centers[i,:], d1, [-l/2,l/2])
        v1edges = points_on_line(r.cluster_centers[i,:], v1, [-l/2,l/2])
        v2edges = points_on_line(r.cluster_centers[i,:], v2, [-l/2,l/2])

        poly = Shape([tuple(v1edges[1,:]...), tuple(v1edges[2,:]...),
            tuple(v2edges[2,:]...), tuple(v2edges[1,:]...), tuple(v1edges[1,:]...)])

        plot!(p6, poly, color=theme_colors[i], linecolor=theme_colors[i],
            fillalpha=0.15, linealpha=0.15)

        pf = points_on_line(
            r.cluster_centers[i,:], r.cluster_directions[i, :], [-l/2,l/2])
        plot!(p6, pf[:,1],pf[:,2], linewidth=3, linecolor=theme_colors[i])
    end
    for i in 1:nclu
        plot!(p6, [r.cluster_centers[i, 1]], [r.cluster_centers[i, 2]],
            seriestype=:scatter, color=theme_colors[i], label="", markersize=5)
    end

    # ###### #
    # Plot 7 #
    # ###### #
    p7 = plot(titlefontsize=8, titlelocation=:left,
        title="7.1-7.2. Point projections on the cluster-supporting line",
        formatter=x->"", legend=false,
        framestyle=:grid, foreground_color_grid=:white, gridalpha=1,
        background_color_inside = pltbg, gridlinewidth=2, aspectratio=1)

    for i in 1:nclu
        l = r.cluster_lengths[i]
        pf = points_on_line(
            r.cluster_centers[i,:], r.cluster_directions[i, :], [-l/2,l/2])
        plot!(p7, pf[:,1],pf[:,2], linewidth=3, linecolor=theme_colors[i])
    end

    plot!(p7, r.point_projections[:,1], r.point_projections[:,2],
        group=r.point_clusters, seriestype=:scatter, markersize=1,
        markerstrokewidth=0.1, markerstrokealpha=0,color=:black, markeralpha=0.6)

    ol = maximum(r.cluster_lengths) / 9

    for i in 1:nclu
        l = r.cluster_lengths[i]
        d_ortho = rand_ortho_vector(r.cluster_directions[i,:])

        strt = i == 1 ? 0 : cumsum(r.cluster_sizes[1:i-1])[end]
        for j in 1:r.cluster_sizes[i]
            pti = strt + j
            pts = points_on_line(r.point_projections[pti,:], d_ortho, [-ol/2,ol/2])
            plot!(p7, pts[:,1], pts[:,2], linecolor=:black, linewidth=1, linealpha=0.5)
        end
    end

    for i in 1:length(r.cluster_lengths)
        plot!(p7, [r.cluster_centers[i, 1]], [r.cluster_centers[i, 2]],
            seriestype=:scatter, color=theme_colors[i], label="", markersize=5)
    end

    # ###### #
    # Plot 8 #
    # ###### #

    p8 = plot(title="7.3. Get points from projections on the cluster-supporting line",
        formatter=x->"", legend=false,
        titlefontsize=8, titlelocation=:left,
        framestyle=:grid, foreground_color_grid=:white, gridalpha=1,
        background_color_inside = pltbg, gridlinewidth=2, aspectratio=1)

    for i in 1:nclu
        l = r.cluster_lengths[i]

        strt = i == 1 ? 0 : cumsum(r.cluster_sizes[1:i-1])[end]
        for j in 1:r.cluster_sizes[i]
            pti = strt + j
            plot!(p8, [r.point_projections[pti, 1], r.points[pti, 1]],
                [r.point_projections[pti, 2], r.points[pti, 2]],
                linecolor=theme_colors[i])#, linealpha=0.3)
        end

        fnsh = strt + r.cluster_sizes[i]
        strt += 1

        plot!(p8, r.points[strt:fnsh,1], r.points[strt:fnsh,2],
            seriestype=:scatter, markersize=1.5, markerstrokewidth=0.1,
            markeralpha=0.6,color=:black)#theme_colors[i])

        pf = points_on_line(
            r.cluster_centers[i,:], r.cluster_directions[i, :], [-l/2,l/2])
        plot!(p8, pf[:,1],pf[:,2], linewidth=3, linecolor=theme_colors[i], linealpha=0.5)

    end


    # ###### #
    # Plot 9 #
    # ###### #
    p9 = plot(r.points[:,1], r.points[:,2], group=r.point_clusters,
        title="Final points", formatter=x->"", legend=false,
        titlefontsize=8, titlelocation=:left,
        seriestype=:scatter, markersize=3, markerstrokewidth=0.2,
        framestyle=:grid, foreground_color_grid=:white, gridalpha=1,
        background_color_inside = pltbg, gridlinewidth=2, aspectratio=1)

    # ###################################################### #
    # Plot limits adjustment based on existing larger limits #
    # ###################################################### #

    # Initialize limits for cluster plots
    llow, lhigh = Inf, -Inf

    # Relevant plots
    plts = (p3, p4, p5, p6, p7, p8, p9)

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

function clupoints_d_ellipsoid(
    projs::AbstractArray{<:Real, 2},
    lat_std::Real,
    line_len::Real,
    clu_dir::AbstractArray{<:Real, 1},
    clu_ctr::AbstractArray{<:Real, 1};
    rng::AbstractRNG = Random.GLOBAL_RNG
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
        pa_sign = norm(prj - edge1) < norm(prj - edge2) ? 1 : -1
        pa *= pa_sign
        pr = clamp(norm(pa / (line_len / 2)), -1, 1)

        # Determine angle associated with this projection
        a = acos(pr)

        println(pr, " -> ", a, " rad, ", a*180/π, " deg")

        # Get a random vector at this angle
        v = rand_vector_at_angle(clu_dir, a; rng=rng)

        # Point dispersion along vector at angle
        f = (lat_std / 2) * randn(rng) + lat_std

        # Determine two possible points at the edges of vector (line) at angle
        pt1 = prj + f .* v
        pt2 = prj - f .* v

        # Determine the point which is nearer one of the cluster-supporting line
        # edges
        near_dist = Inf
        pt = nothing

        for pt_curr in (pt1, pt2)
            for edge_curr in (edge1, edge2)
                if norm(pt_curr - edge_curr) < near_dist
                    near_dist = norm(pt_curr - edge_curr)
                    pt = pt_curr
                end
            end
        end

        clu_pts[i, :] = pt
    end
    println()
    return clu_pts
end

"""

line_len = 40
clu_ctr = [1, -1]
clu_dir = [-1, 0]
lat_std = 5
pre_projs = [-10, -3, 0.5, 0, 1, 1.5, 19, -0.1]

projs = points_on_line(clu_ctr, clu_dir, pre_projs)

edge1 = clu_ctr + (line_len / 2) .* clu_dir
edge2 = clu_ctr - (line_len / 2) .* clu_dir

pts = clupoints_d_ellipsoid(projs, lat_std, line_len, clu_dir, clu_ctr)

plt = plot(legend=false,size=(900,900))

plot!(plt, [edge1[1], edge2[1]], [edge1[2], edge2[2]], color=:orange)

plot!(plt, [edge1[1], edge2[1]], [edge1[2], edge2[2]], seriestype=:scatter, markershape=:vline, markercolor=:orange,markerstrokewidth=0.1)

plot!(plt, [clu_ctr[1]], [clu_ctr[2]], seriestype=:scatter, markershape=:circle, markercolor=:orange, markersize=5,markerstrokewidth=0.1)

for i in 1:size(projs, 1)
    plot!([pts[i,1], projs[i,1]], [pts[i,2], projs[i,2]],color=:grey,linewidth=0.5)
end

plot!(plt,projs[:,1],projs[:,2],seriestype=:scatter,markersize=2.5,markerstrokewidth=0.1,markercolor=:red)

plot!(plt,pts[:,1],pts[:,2],markershape=:cross,seriestype=:scatter,markersize=2.5,markerstrokewidth=0.1,markercolor=:green)


plot(plt)

"""

end # Module
