var documenterSearchIndex = {"docs":
[{"location":"#AdaptiveTestPlots.jl","page":"Home","title":"AdaptiveTestPlots.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This is a package for plotting recordings of CATs (Computerised Adaptive Tests).","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = AdaptiveTestPlots","category":"page"},{"location":"#Index","page":"Home","title":"Index","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"#API","page":"Home","title":"API","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Modules = [AdaptiveTestPlots]","category":"page"},{"location":"#AdaptiveTestPlots.AdaptiveTestPlots","page":"Home","title":"AdaptiveTestPlots.AdaptiveTestPlots","text":"This module contains helpers for creating CAT/IRT related plots. This module requires the optional depedencies AlgebraOfGraphics, DataFrames and Makie to be installed.\n\n\n\n\n\n","category":"module"},{"location":"#AdaptiveTestPlots.CatRecorder","page":"Home","title":"AdaptiveTestPlots.CatRecorder","text":"CatRecorder(\n    xs,\n    points,\n    ability_ests,\n    num_questions,\n    num_respondents,\n    integrator,\n    raw_estimator,\n    ability_estimator\n) -> CatRecorder\nCatRecorder(\n    xs,\n    points,\n    ability_ests,\n    num_questions,\n    num_respondents,\n    integrator,\n    raw_estimator,\n    ability_estimator,\n    actual_abilities\n) -> CatRecorder\n\n\n\n\n\n\n","category":"type"},{"location":"#AdaptiveTestPlots.CatRecorder-Tuple{Any, Any, Any}","page":"Home","title":"AdaptiveTestPlots.CatRecorder","text":"\n\n\n\n","category":"method"},{"location":"#AdaptiveTestPlots.LabelledToggleGrid","page":"Home","title":"AdaptiveTestPlots.LabelledToggleGrid","text":"AdaptiveTestPlots.LabelledToggleGrid <: Block\n\nNo docstring defined.\n\nAttributes\n\n(type ?AdaptiveTestPlots.LabelledToggleGrid.x in the REPL for more information about attribute x)\n\nalignmode, halign, height, tellheight, tellwidth, valign, width\n\n\n\n\n\n","category":"type"},{"location":"#AdaptiveTestPlots.MenuGrid","page":"Home","title":"AdaptiveTestPlots.MenuGrid","text":"AdaptiveTestPlots.MenuGrid <: Block\n\nNo docstring defined.\n\nAttributes\n\n(type ?AdaptiveTestPlots.MenuGrid.x in the REPL for more information about attribute x)\n\nalignmode, halign, height, tellheight, tellwidth, valign, width\n\n\n\n\n\n","category":"type"},{"location":"#AdaptiveTestPlots.ability_convergence_lines-Tuple{Any}","page":"Home","title":"AdaptiveTestPlots.ability_convergence_lines","text":"ability_convergence_lines(recorder; abilities)\n\n\n\n\n\n\n","category":"method"},{"location":"#AdaptiveTestPlots.ability_evolution_lines-Tuple{Any}","page":"Home","title":"AdaptiveTestPlots.ability_evolution_lines","text":"ability_evolution_lines(\n    recorder;\n    abilities\n) -> AlgebraOfGraphics.FigureGrid\n\n\n\n\n\n\n","category":"method"},{"location":"#AdaptiveTestPlots.lh_evolution_interactive-Tuple{Any}","page":"Home","title":"AdaptiveTestPlots.lh_evolution_interactive","text":"lh_evolution_interactive(\n    recorder;\n    abilities\n) -> Makie.Figure\n\n\n\n\n\n\n","category":"method"},{"location":"#AdaptiveTestPlots.plot_item_bank-Tuple{FittedItemBanks.AbstractItemBank}","page":"Home","title":"AdaptiveTestPlots.plot_item_bank","text":"plot_item_bank(\n    item_bank::FittedItemBanks.AbstractItemBank;\n    fig,\n    items,\n    labeller,\n    zero_symmetric,\n    include_outcome_toggles,\n    item_selection,\n    include_legend\n) -> Makie.Figure\n\n\nPlot an item bank item_bank with items items using the labeller labeller to label the items.\n\nLines are drawn for each item and each outcome. The domain of the item bank is used to determine the x-axis limits. You can use zero_symmetric to force the domain to be symmetric about zero.\n\nIf include_outcome_toggles is true, then a toggle grid is drawn to show/hide the outcomes. If item_selection is :toggles, then a toggle grid is drawn to show/hide the items, for :menu a menu is used allowing a single item to be choseshowenn.\n\n\n\n\n\n","category":"method"},{"location":"#AdaptiveTestPlots.plot_item_bank_comparison-Tuple{AbstractVector}","page":"Home","title":"AdaptiveTestPlots.plot_item_bank_comparison","text":"plot_item_bank_comparison(\n    item_banks::AbstractVector;\n    items,\n    labeller,\n    include_outcome_toggles,\n    include_item_toggles,\n    ignore_domain_indices\n) -> Makie.Figure\n\n\nPlot a comparison of multiple item banks item_banks. For an explanation of the options, see: plot_item_bank.\n\n\n\n\n\n","category":"method"},{"location":"#AdaptiveTestPlots.plot_likelihoods","page":"Home","title":"AdaptiveTestPlots.plot_likelihoods","text":"plot_likelihoods(\n    estimators,\n    tracked_responses,\n    integrator,\n    xs\n) -> Makie.Figure\nplot_likelihoods(\n    estimators,\n    tracked_responses,\n    integrator,\n    xs,\n    lim_lo\n) -> Makie.Figure\nplot_likelihoods(\n    estimators,\n    tracked_responses,\n    integrator,\n    xs,\n    lim_lo,\n    lim_hi\n) -> Makie.Figure\n\n\n\n\n\n\n","category":"function"}]
}
