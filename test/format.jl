using JuliaFormatter
using AdaptiveTestPlots

@testcase "format" begin
    dir = pkgdir(AdaptiveTestPlots)
    @test format(dir * "/src"; overwrite = false)
    @test format(dir * "/test"; overwrite = false)
end
