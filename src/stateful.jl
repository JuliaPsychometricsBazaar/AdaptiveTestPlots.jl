using ComputerAdaptiveTesting: Stateful


function stateful_plot_item_response_cb(ax, stateful_cat, item, lim_lo, lim_hi, grid_points, item_label, item_lines)
    xs = range(lim_lo, lim_hi, length = grid_points)
    ys = stack(Stateful.item_response_functions.(Ref(stateful_cat), item, xs); dims=1)

    for out in [1, 2]
        item_lines[out] = lines!(ax,
            xs,
            (@view ys[:, out]),
            label = "Item $item_label Outcome $out")
    end
end

function stateful_2d_plot_item_response_cb(ax, stateful_cat, item, lim_lo, lim_hi, grid_points, item_label, item_lines)
    prod = Iterators.product((
        range(lo, hi, length = grid_points)
        for (lo, hi)
        in zip(lim_lo, lim_hi)
    )...)
    xs = reshape(collect.(prod), :)
    @info "billy" xs

    ys = stack(Stateful.item_response_functions.(Ref(stateful_cat), item, xs); dims=1)

    dim1 = [x[1] for x in xs]
    dim2 = [x[2] for x in xs]

    for out in [1, 2]
        item_lines[out] = heatmap!(ax,
            dim1,
            dim2,
            (@view ys[:, out]),
            label = "Item $item_label; Outcome $out")
    end
end