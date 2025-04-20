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