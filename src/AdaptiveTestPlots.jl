"""
This module contains helpers for creating CAT/IRT related plots. This module
requires the optional depedencies AlgebraOfGraphics, DataFrames and Makie to be
installed.
"""
module AdaptiveTestPlots

export CatRecorder
export lh_evolution_interactive, @automakie, plot_likelihoods
export plot_item_bank, plot_item_bank_comparison
export summary_plot

using Distributions
using DocStringExtensions
using AlgebraOfGraphics
using DataFrames
using Makie
using Makie: @Block, compute_x_and_width, extrema_nan
using MakieCore: mixin_generic_plot_attributes, automatic
using ColorTypes: RGBA
using DocStringExtensions
using FittedItemBanks
using FittedItemBanks: item_params, item_bank_domain, item_ys
using ComputerAdaptiveTesting: Aggregators
using ComputerAdaptiveTesting.Aggregators
using ComputerAdaptiveTesting.Responses: function_ys
using ComputerAdaptiveTesting.Sim: CatRecorder, CatRecording
using PsychometricsBazaarBase.Integrators
using FillArrays

include("./makie_extensions.jl")
include("./item_banks.jl")
include("./stateful.jl")
include("./likelihoods.jl")
include("./violinseq.jl")
include("./recorder.jl")
include("./precompile.jl")

end
