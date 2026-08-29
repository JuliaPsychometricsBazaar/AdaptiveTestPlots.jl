using Test
using Random
using Distributions
using Makie
using AdaptiveTestPlots
using FittedItemBanks
using FittedItemBanks.DummyData
using ComputerAdaptiveTesting.Aggregators
using ComputerAdaptiveTesting.Responses: BareResponses
using PsychometricsBazaarBase.Integrators: even_grid

function dummy_tracked_responses()
    spec = SimpleItemBankSpec(StdModel4PL(), OneDimContinuousDomain(), BooleanResponse())
    item_bank = dummy_item_bank(Random.default_rng(42), spec, 3)
    responses = BareResponses(BooleanResponse(), [1, 2, 3], [true, false, true])
    TrackedResponses(responses, item_bank, NullAbilityTracker())
end

@testset "plot_likelihoods" begin
    tracked_responses = dummy_tracked_responses()
    integrator = FunctionIntegrator(even_grid(-6.0, 6.0, 61))
    estimators = [
        ("Posterior", PosteriorAbilityEstimator(Normal())),
        ("Likelihood", LikelihoodAbilityEstimator())
    ]
    xs = range(-6.0, 6.0, length = 61)
    fig = plot_likelihoods(estimators, tracked_responses, integrator, xs)
    @test fig isa Figure

    # The toggles should control the visibility of the corresponding plots
    ax = only(filter(x -> x isa Axis, fig.content))
    ltgrid = only(filter(x -> x isa AdaptiveTestPlots.LabelledToggleGrid, fig.content))
    toggles = ltgrid.toggles
    @test length(toggles) == length(estimators)
    for (toggle, plt) in zip(toggles, ax.scene.plots)
        @test plt.visible[] == true
        toggle.active[] = false
        @test plt.visible[] == false
        toggle.active[] = true
        @test plt.visible[] == true
    end
end
