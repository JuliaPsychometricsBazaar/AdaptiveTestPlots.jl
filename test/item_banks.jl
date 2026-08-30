using Random
using FittedItemBanks
using FittedItemBanks.DummyData: dummy_item_bank
using Makie

@testset "polytomous item bank" begin
    item_bank = OneDimensionItemBankAdapter(
        dummy_item_bank(Random.default_rng(42), GPCMItemBank, 4, 1))

    fig = plot_item_bank(item_bank)

    @test fig isa Figure
end
