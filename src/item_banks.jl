struct LabelVecLabeller
    arr::Vector{String}
end

function (lv::LabelVecLabeller)(index::Int)
    lv.arr[index]
end

function index_labeller(index::Int)
    "Item $index"
end

function toggle_grid_observables(grid, len; default = true)
    if grid === nothing
        fill(Observable(default), len)
    else
        (toggle.active for toggle in grid.toggles)
    end
end

function draw_outcome_toggles!(ax, outcomes)
    outcome_toggles = []
    for out in [1, 2]
        push!(outcome_toggles,
            (off_label = "Show $out", on_label = "Hide $out", active = true))
    end
    LabelledToggleGrid(ax,
        outcome_toggles...,
        width = 100)
end

function draw_item_toggles!(ax, items, labeller)
    item_toggles = []
    for item in items
        item_label = labeller(item)
        push!(item_toggles,
            (off_label = "Show $item_label", on_label = "Hide $item_label", active = true))
    end
    LabelledToggleGrid(ax,
        item_toggles...,
        width = 350,
        tellheight = false)
end

#=
function plot_item_responses(
        item_bank;
        ax = Axis(),
        items = eachindex(item_bank),
        zero_symmetric = false
)
    lim_lo, lim_hi = item_bank_domain(
        item_bank,
        items;
        zero_symmetric = zero_symmetric)
    xlims!(lim_lo, lim_hi)
    xs = range(lim_lo, lim_hi, length = 100)
    ys = Array{Float64}(undef, length(xs), 2)
    outcomes = Array{Makie.Lines}(undef, 2, length(items))
    for (ii, item) in enumerate(items)
        ir = ItemResponse(item_bank, item)
        for (i, x) in enumerate(xs)
            ys[i, :] .= resp_vec(ir, x)
        end

        for out in [1, 2]
            outcomes[out, ii] = lines!(ax,
                xs,
                (@view ys[:, out]),
                label = "Item $item Outcome $out")
        end
    end
    return outcomes
end
=#

function plot_item_responses(
        item_bank;
        ax = Axis(),
        items = eachindex(item_bank),
        zero_symmetric = false
)
    lim_lo, lim_hi = item_bank_domain(
        item_bank;
        items = items,
        zero_symmetric = zero_symmetric)
    xs = make_grid(item_bank, lim_lo, lim_hi, 100)
    outcomes = Array{Union{Makie.Lines, Makie.Heatmap}}(undef, 2, length(items))

    for (ii, item) in enumerate(items)
        ir = ItemResponse(item_bank, item)
        item_label = "Item $item"
        item_outcomes = @view outcomes[:, ii]
        plot_item_response(ir, ax, xs, item_label, item_outcomes)
    end

    return outcomes
end

"""
$(TYPEDSIGNATURES)

Plot an item bank `item_bank` with items `items` using the labeller `labeller`
to label the items.

Lines are drawn for each item and each outcome. The domain of the item bank is
used to determine the x-axis limits. You can use `zero_symmetric` to
force the domain to be symmetric about zero.

If `include_outcome_toggles` is true, then a toggle grid is drawn to show/hide
the outcomes. If `item_selection` is :toggles, then a toggle grid is drawn to
show/hide the items, for :menu a menu is used allowing a single item to be choseshowenn.
"""
function plot_item_bank(item_bank::AbstractItemBank;
        fig = Figure(),
        items = eachindex(item_bank),
        labeller = index_labeller,
        zero_symmetric = false,
        include_outcome_toggles = true,
        item_selection = nothing,
        include_legend = true)
    # Default value of observables
    display_all_obs = false
    outcome_show_obs_arr = Fill(true, 2)
    item_show_obs_arr = Fill(true, length(items))

    # Left panel
    left_panel = fig[1, 1] = GridLayout()
    lim_lo, lim_hi = item_bank_domain(
        item_bank;
        items = items,
        zero_symmetric = zero_symmetric)
    #ax = Axis(left_panel[1, 1], limits = ((lim_lo, lim_hi), nothing))
    ax = Axis(left_panel[1, 1])
    rowsize!(fig.layout, 1, Auto(false))
    colsize!(fig.layout, 1, Auto(false))
    outcomes = plot_item_responses(
        item_bank, ax = ax, items = items, zero_symmetric = zero_symmetric)
    if include_legend
        left_panel[2, 1] = Legend(fig, ax, "Legend", framevisible = false)
    end

    # Right panel
    right_panel = fig[1, 2] = GridLayout()
    if include_outcome_toggles
        outcome_grid = draw_outcome_toggles!(right_panel[1, 1], [1, 2])
        outcome_show_obs_arr = [toggle.active for toggle in outcome_grid.toggles]
    end
    item_grid = nothing

    if item_selection == :toggles
        item_grid = draw_item_toggles!(right_panel[2, 1], items, labeller)
        item_show_obs_arr = [toggle.active for toggle in grid.toggles]
    elseif item_selection in (:menu, :menu_with_all)
        if item_selection == :menu_with_all
            display_all_panel = right_panel[3, 1] = GridLayout()
            display_all_toggle = Toggle(display_all_panel[1, 2], active = false)
            display_all_obs = display_all_toggle.active
            Label(display_all_panel[1, 1], "Show all items")
        end
        menu = Menu(right_panel[2, 1], options = items, width = 100)
        item_show_obs_arr[i] = [@lift $(menu.selection) == item for item in items]
    end
    trim!(right_panel)

    # Hook up the observables
    for (i, outcome) in enumerate(outcome_show_obs_arr)
        for (j, item) in enumerate(item_show_obs_arr)
            connect!(
                outcomes[i, j].visible,
                @lift $(outcome) && ($(item) || $(display_all_obs))
            )
        end
    end
    fig
end

function plot_item_response(::OneDimContinuousDomain,
        ir,
        ax,
        xs,
        item_label,
        outcomes;
        ys_buf = Array{Float64}(undef, length(xs), 2))
    for (i, x) in enumerate(xs)
        ys_buf[i, :] .= resp_vec(ir, x)
    end

    for out in [1, 2]
        outcomes[out] = lines!(ax,
            xs,
            (@view ys_buf[:, out]),
            label = "Item $item_label Outcome $out")
    end
end

function plot_item_response(::VectorContinuousDomain,
        ir,
        ax,
        xs,
        item_label,
        outcomes;
        ys_buf = Array{Float64}(undef, length(xs), 2))
    for (i, x) in enumerate(xs)
        ys_buf[i, :] .= resp_vec(ir, x)
    end

    dim1 = [x[1] for x in xs]
    dim2 = [x[2] for x in xs]
    for out in [1, 2]
        outcomes[out] = heatmap!(ax,
            dim1,
            dim2,
            (@view ys_buf[:, out]),
            label = "Item $item_label; Outcome $out")
    end
end

function plot_item_response(ir::ItemResponse, args...; kwargs...)
    plot_item_response(DomainType(ir.item_bank), ir, args...; kwargs...)
end

function make_grid(::OneDimContinuousDomain, item_bank, lim_lo, lim_hi, num_points)
    range(lim_lo, lim_hi, length = num_points)
end

function make_grid(::VectorContinuousDomain, item_bank,
        lim_lo::AbstractVector, lim_hi::AbstractVector, num_points)
    prod = Iterators.product((
        range(lo, hi, length = num_points)
    for (lo, hi)
    in zip(lim_lo, lim_hi)
    )...)
    reshape(collect.(prod), :)
end

function make_grid(dom::VectorContinuousDomain, item_bank, lim_lo, lim_hi, num_points)
    ndim = domdims(item_bank)
    make_grid(dom, item_bank, Fill(lim_lo, ndim), Fill(lim_hi, ndim), num_points)
end

function make_grid(item_bank, lim_lo, lim_hi, num_points)
    make_grid(DomainType(item_bank), item_bank, lim_lo, lim_hi, num_points)
end

"""
$(TYPEDSIGNATURES)

Plot a comparison of multiple item banks `item_banks`. For an explanation of
the options, see: `plot_item_bank`.
"""
function plot_item_bank_comparison(item_banks::AbstractVector;
        items = eachindex(item_bank),
        labeller = index_labeller,
        include_outcome_toggles = true,
        include_item_toggles = false,
        ignore_domain_indices = [])
    fig = Figure()
    ax = Axis(fig[1, 1])
    # Get limits
    lim_lo = Inf
    lim_hi = -Inf
    for (idx, item_bank) in enumerate(item_banks)
        if idx in ignore_domain_indices
            continue
        end
        ib_lim_lo, ib_lim_hi = item_bank_domain(item_bank; items = items)
        lim_lo = min(lim_lo, ib_lim_lo)
        lim_hi = max(lim_hi, ib_lim_hi)
    end
    # Plot lines
    outcomes = Array{Union{Makie.Lines, Makie.Heatmap}}(
        undef, length(item_banks), 2, length(items))
    some_heatmap = nothing
    for (ibi, item_bank) in enumerate(item_banks)
        ax = Axis(fig[ibi, 1])
        xlims!(ax, lim_lo, lim_hi)
        for (ii, item) in enumerate(items)
            ir = ItemResponse(item_bank, item)
            xs = make_grid(ir.item_bank, lim_lo, lim_hi, 100)
            item_label = labeller(item)
            item_lines = @view outcomes[ibi, :, ii]
            plot_item_response(ir, ax, xs, item_label, item_lines)
            for line in item_lines
                if isa(line, Makie.Heatmap)
                    some_heatmap = line
                end
            end
        end
    end
    if some_heatmap !== nothing
        Colorbar(fig[2, 2], some_heatmap)
    end
    # Draw widgets
    outcome_grid = include_outcome_toggles ? draw_outcome_toggles!(fig[1, 2], [1, 2]) :
                   nothing
    item_grid = include_item_toggles ?
                draw_item_toggles!(
        fig[include_outcome_toggles ? length(item_banks) : 1, 2],
        items,
        labeller) : nothing
    # Connect widgets
    for (i, outcome_toggle) in enumerate(toggle_grid_observables(outcome_grid, 2))
        for (j, item_toggle) in enumerate(toggle_grid_observables(item_grid, items))
            for ibi in eachindex(item_banks)
                connect!(outcomes[ibi, i, j].visible,
                    @lift $(outcome_toggle) && $(item_toggle))
            end
        end
    end
    fig
end

function plot_item_bank(item_bank::DichotomousPointsItemBank;
        items = eachindex(item_bank),
        labeller = index_labeller,
        zero_symmetric = false)
    fig = Figure()
    ax = Axis(fig[1, 1])
    #lo = item_bank.xs[1]
    #hi = item_bank.xs[end]
    for item in items
        scatter!(ax,
            item_bank.xs,
            @view item_bank.ys[item, :];
            markersize = 5,
            marker = :cross)
    end
    fig
end
