struct LabelVecLabeller
    arr::Vector{String}
end

function (lv::LabelVecLabeller)(index::Int)
    lv.arr[index]
end

function index_labeller(index::Int)
    "Item $index"
end
#=
	toggles = Array{Toggle}(undef, length(item_bank))
	for idx in eachindex(item_bank)
		label = labeller(idx)
		toggles[idx] = (off_label = "Show $name", on_label="Hide $name", active = true)
	end
	#ir = ItemResponse(item_bank, idx)
	ltgrid = LabelledToggleGrid(
		fig[1, 2],
		toggles...,
		width = 350,
		tellheight = false
	)
	#GridLayout()
	ltgrid
=#

function _item_bank_domain(::OneDimContinuousDomain,
        item_bank,
        items;
        zero_symmetric = false)
    item_bank_domain(item_bank; items = items, zero_symmetric = zero_symmetric)
end

function _item_bank_domain(::VectorContinuousDomain,
        item_bank,
        items;
        zero_symmetric = false)
    nd = domdims(item_bank)
    item_bank_domain(item_bank; items = items, zero_symmetric = zero_symmetric)
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
        width = 350,
        tellheight = false)
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

"""
$(TYPEDSIGNATURES)

Plot an item bank `item_bank` with items `items` using the labeller `labeller`
to label the items.

Lines are drawn for each item and each outcome. The domain of the item bank is
used to determine the x-axis limits. You can use `zero_symmetric` to
force the domain to be symmetric about zero.

If `include_outcome_toggles` is true, then a toggle grid is drawn to show/hide
the outcomes. If `include_item_toggles` is true, then a toggle grid is drawn to
show/hide the items.
"""
function plot_item_bank(item_bank::AbstractItemBank;
        items = eachindex(item_bank),
        labeller = index_labeller,
        zero_symmetric = false,
        include_outcome_toggles = true,
        include_item_toggles = false,)
    fig = Figure()
    ax = Axis(fig[1, 1])
    lim_lo, lim_hi = _item_bank_domain(DomainType(item_bank),
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
    outcome_grid = include_outcome_toggles ? draw_outcome_toggles!(fig[1, 2], [1, 2]) :
                   nothing
    item_grid = include_item_toggles ?
                draw_item_toggles!(fig[include_outcome_toggles ? 2 : 1, 2],
        items,
        labeller) : nothing
    for (i, outcome_toggle) in enumerate(toggle_grid_observables(outcome_grid, 2))
        for (j, item_toggle) in enumerate(toggle_grid_observables(item_grid, length(items)))
            connect!(outcomes[i, j].visible, @lift $(outcome_toggle) && $(item_toggle))
        end
    end
    fig[2, 1] = Legend(fig, ax, "Legend", framevisible = false)
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
        ys_buf = Array{Float64}(undef, length(xs), domdims(ir.item_bank)))
    for (i, x) in enumerate(xs)
        ys_buf[i, :] .= resp_vec(ir, x)
    end

    for out in [1, 2]
        outcomes[out] = lines!(ax,
            xs,
            (@view ys_buf[:, out]),
            label = "Item $item_label; Outcome $out")
    end
end

function plot_item_response(ir::ItemResponse, args...; kwargs...)
    plot_item_response(DomainType(ir), ir, args...; kwargs...)
end

function item_response_xs(::VectorContinuousDomain, lim_lo, lim_hi)
    range(lim_lo, lim_hi, length = 100)
    prod = Iterators.product((range(lo, hi, length = 100)
                              for (lo, hi)
    in zip(theta_lo, theta_hi))...)
    grid = reshape(collect.(prod), :)
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
        ignore_domain_indices = [],)
    fig = Figure()
    ax = Axis(fig[1, 1])
    lim_lo = Inf
    lim_hi = -Inf
    for (idx, item_bank) in enumerate(item_banks)
        if idx in ignore_domain_indices
            continue
        end
        ib_lim_lo, ib_lim_hi = _item_bank_domain(DomainType(item_bank), item_bank, items)
        lim_lo = min(lim_lo, ib_lim_lo)
        lim_hi = max(lim_hi, ib_lim_hi)
    end
    outcomes = Array{Makie.Lines}(undef, length(item_banks), 2, length(items))
    for (ibi, item_bank) in enumerate(item_banks)
        ax = Axis(fig[ibi, 1])
        xlims!(ax, lim_lo, lim_hi)
        for (ii, item) in enumerate(items)
            ir = ItemResponse(item_bank, item)
            xs = range(lim_lo, lim_hi, length = 100)
            plot_item_response(ir, ax, xs, ys, labeller(item), @view outcomes[ibi, :, ii])
        end
    end
    outcome_grid = include_outcome_toggles ? draw_outcome_toggles!(fig[1, 2], [1, 2]) :
                   nothing
    item_grid = include_item_toggles ?
                draw_item_toggles!(fig[include_outcome_toggles ? length(item_banks) : 1, 2],
        items,
        labeller) : nothing
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
