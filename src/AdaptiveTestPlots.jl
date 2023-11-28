"""
This module contains helpers for creating CAT/IRT related plots. This module
requires the optional depedencies AlgebraOfGraphics, DataFrames and Makie to be
installed.
"""
module AdaptiveTestPlots

export CatRecorder, ability_evolution_lines, ability_convergence_lines
export lh_evolution_interactive, @automakie, plot_likelihoods

using Distributions
using DocStringExtensions
using AlgebraOfGraphics
using DataFrames
using Makie
using Makie: @Block
using FittedItemBanks
using FittedItemBanks: item_params
using ComputerAdaptiveTesting: Aggregators
using ComputerAdaptiveTesting.Aggregators
using PsychometricsBazaarBase.Integrators

include("./makie_extensions.jl")
include("./item_banks.jl")
include("./recorder.jl")

end
