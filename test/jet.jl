using JET
using AdaptiveTestPlots

@testset "JET checks" begin
    rep = report_package(
        AdaptiveTestPlots;
        target_modules = (
            AdaptiveTestPlots,
        ),
        mode = :typo
    )
    @show rep
    @test length(JET.get_reports(rep)) <= 0
    #@test_broken length(JET.get_reports(rep)) == 0
end
