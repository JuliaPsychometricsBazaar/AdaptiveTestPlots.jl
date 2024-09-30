using PrecompileTools


@setup_workload begin
    @compile_workload begin
        f = Figure()
        LabelledToggleGrid(f, (off_label = "Show", on_label = "Hide", active = true))
    end
end
