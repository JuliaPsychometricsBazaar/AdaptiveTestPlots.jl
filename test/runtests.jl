using XUnit

@testset runner=ParallelTestRunner() xml_report=true "top" begin
    @testset "aqua" begin
        include("./aqua.jl")
    end
end
