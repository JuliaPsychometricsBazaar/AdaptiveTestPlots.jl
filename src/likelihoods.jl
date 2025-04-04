function draw_likelihood(ax,
        ::OneDimContinuousDomain,
        dist_est::DistributionAbilityEstimator,
        tracked_responses,
        integrator,
        xs)
    denom = normdenom(integrator, dist_est, tracked_responses)
    likelihood = Aggregators.pdf.(Ref(dist_est), Ref(tracked_responses), xs) ./ denom
    lines!(ax, xs, likelihood)
end

function draw_likelihood(ax,
        ::OneDimContinuousDomain,
        point_est::PointAbilityEstimator,
        tracked_responses,
        integrator_,
        xs)
    θ_estimate = point_est(tracked_responses)
    vlines([θ_estimate]).plot.plots[1]
end

function draw_likelihood(ax,
        ::OneDimContinuousDomain,
        dist::Distribution, _tracked_responses, integrator_, xs)
    lines!(ax, xs, pdf.(dist, xs))
end

function draw_likelihood(ax,
        ::OneDimContinuousDomain,
        grid_tracker::ClosedFormNormalAbilityTracker,
        tracked_responses,
        integrator,
        xs)
    @info "ClosedFormNormalAbilityTracker",
    grid_tracker.cur_ability.mean,
    grid_tracker.cur_ability.var
    draw_likelihood(ax,
        OneDimContinuousDomain(),
        Normal(grid_tracker.cur_ability.mean, sqrt(grid_tracker.cur_ability.var)),
        tracked_responses,
        integrator,
        xs)
end

function draw_likelihood(ax,
        ::OneDimContinuousDomain,
        grid_tracker::GriddedAbilityTracker,
        tracked_responses,
        integrator_,
        xs)
    lines!(ax, grid_tracker.grid, grid_tracker.cur_ability)
end

function draw_likelihood(ax,
        ::VectorContinuousDomain,
        dist_est::DistributionAbilityEstimator,
        tracked_responses,
        integrator,
        xs)
    denom = normdenom(integrator, dist_est, tracked_responses)
    ys = Aggregators.pdf.(Ref(dist_est), Ref(tracked_responses), xs) ./ denom

    dim1 = [x[1] for x in xs]
    dim2 = [x[2] for x in xs]
    heatmap!(ax,
        dim1,
        dim2,
        ys,
        label = "Outcome")
end

"""
$(TYPEDSIGNATURES)
"""
function plot_likelihoods(estimators,
        tracked_responses,
        integrator,
        xs,
        lim_lo = -6.0,
        lim_hi = 6.0;
        fig = Figure())
    ax = Axis(fig[1, 1])
    rowsize!(fig.layout, 1, Auto(false))
    colsize!(fig.layout, 1, Auto(false))
    domain_type = DomainType(tracked_responses.item_bank)
    if domain_type isa OneDimContinuousDomain
        xlims!(lim_lo, lim_hi)
    end
    est_plots = []
    toggles = []
    for (name, estimator) in estimators
        est_plot = draw_likelihood(
            ax, domain_type, estimator, tracked_responses, integrator, xs)
        push!(toggles, (off_label = "Show $name", on_label = "Hide $name", active = true))
        push!(est_plots, est_plot)
    end
    ltgrid = LabelledToggleGrid(fig[1, 2],
        toggles...,
        width = 350,
        tellheight = false)
    for (toggle, est_plot) in zip(ltgrid.toggles, est_plots)
        connect!(est_plot.visible, toggle.active)
    end
    fig
end
