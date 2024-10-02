using PrecompileTools


@setup_workload begin
    @compile_workload begin
        f = Figure()
        LabelledToggleGrid(f, (off_label = "Show", on_label = "Hide", active = true))
    end

    using Random
    using FittedItemBanks
    using FittedItemBanks.DummyData
    model = StdModel4PL()
    domain = OneDimContinuousDomain()
    response = BooleanResponse()
    spec = SimpleItemBankSpec(model, domain, response)
    item_bank = dummy_item_bank(Random.default_rng(42), spec, 1)

    @compile_workload begin
        plot_item_bank(item_bank)
    end
end
