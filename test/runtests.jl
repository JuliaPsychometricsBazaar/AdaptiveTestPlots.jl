using Test

@testset "aqua" begin
    include("./aqua.jl")
end

@testset "jet" begin
    include("./jet.jl")
end
