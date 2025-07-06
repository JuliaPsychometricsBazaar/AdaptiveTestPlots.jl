"""
    violin_seq(steps, xs, all_ys)
Draw a violin plot from precomputed likelihoods at different steps.
## Arguments
- `steps`: positions of the step at which the likelihood applies (categories)
- `xs`: points at which the likelihood was evaluated
- `all_ys`: precomputed likelihoods at different steps
"""
@recipe ViolinSeq (steps, xs, all_ys) begin
    "Scale density by area (`:area`) or width (`:width`)."
    scale = :area
    "Orientation of the violins (`:vertical` or `:horizontal`)"
    orientation = :vertical
    "Width of the box before shrinking."
    width = automatic
    dodge = automatic
    n_dodge = automatic
    "Shrinking factor, `width -> width * (1 - gap)`."
    gap = 0.2
    dodge_gap = 0.03
    "Specify values to trim the `violin`. Can be a `Tuple` or a `Function` (e.g. `datalimits=extrema`)."
    datalimits = (-Inf, Inf)
    max_density = automatic
    color = @inherit patchcolor
    strokecolor = @inherit patchstrokecolor
    strokewidth = @inherit patchstrokewidth
    mixin_generic_plot_attributes()...
end

function Makie.plot!(plot::ViolinSeq)
    steps, xs, all_ys = plot[1], plot[2], plot[3]
    args = @extract plot (
        width, scale, color, datalimits, max_density, dodge, n_dodge, gap, dodge_gap, orientation,
    )
    signals = lift(
        plot, steps, xs, all_ys, args...
    ) do steps, xs, all_ys, width, scale_type, color, limits, max_density, dodge, n_dodge, gap, dodge_gap, orientation
        step_bar, violinwidth = compute_x_and_width(steps, width, gap, dodge, n_dodge, dodge_gap)

        # for horizontal violin just flip all components
        point_func = Point2f
        if orientation === :horizontal
            point_func = flip_xy ∘ point_func
        end

        specs = map(eachindex(steps)) do idx
            ys = @view all_ys[:, idx]
            vertices = point_func.(xs, ys)
            return (;
                step = step_bar[idx],
                color = to_color(color),
                xs = xs,
                ys = ys,
            )
        end

        (scale_type ∈ [:area, :width]) || error("Invalid scale type: $(scale_type)")

        max = if max_density === automatic
            maximum(specs) do spec
                if scale_type === :area
                    return extrema_nan(spec.ys) |> last
                elseif scale_type === :width
                    return NaN
                end
            end
        else
            max_density
        end

        vertices = Vector{Point2f}[]
        colors = RGBA{Float32}[]

        for spec in specs
            scale = 0.5 * violinwidth
            if scale_type === :area
                scale = scale / max
            elseif scale_type === :width
                scale = scale / (extrema_nan(spec.ys) |> last)
            end
            xl = reverse(spec.step .- spec.ys .* scale)
            xr = spec.step .+ spec.ys .* scale
            yl = reverse(spec.xs)
            yr = spec.xs

            x_coord = [spec.step; xr; spec.step; xl]
            y_coord = [yr[1]; yr; yl[1]; yl]
            verts = point_func.(x_coord, y_coord)

            push!(vertices, verts)
            push!(colors, spec.color)
        end

        (; vertices, colors)
    end
    poly!(
        plot,
        lift(s -> s.vertices, plot, signals);
        color = lift(s -> s.colors, plot, signals),
        strokecolor = plot[:strokecolor],
        strokewidth = plot[:strokewidth],
    )
end
