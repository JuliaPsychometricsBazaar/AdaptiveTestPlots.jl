"""
$(TYPEDSIGNATURES)
"""
function ability_evolution_lines(recorder; abilities = nothing)
    plt = (data((respondent = recorder.respondents,
               ability_est = recorder.ability_ests,
               step = recorder.steps)) *
           visual(Lines) *
           mapping(:step, :ability_est, color = :respondent => nonnumeric))
    conv_lines_fig = draw(plt)
    if abilities !== nothing
        aog_hlines!(conv_lines_fig, abilities)
    end
    conv_lines_fig
end

"""
$(TYPEDSIGNATURES)
"""
function ability_convergence_lines(recorder; abilities)
    plt = (data((respondent = recorder.respondents,
               ability_div = recorder.ability_divs,
               step = recorder.steps)) *
           visual(Lines) *
           mapping(:step, :ability_div, color = :respondent => nonnumeric))
    draw(plt)
end

"""
$(TYPEDSIGNATURES)
"""
function lh_evolution_interactive(recording; abilities = nothing)
    conv_dist_fig = Figure(size = (1000, 700))
    ax = Axis(conv_dist_fig[1, 1])

    respondents = 1:length(unique(recording.respondents))
    steps = 1:length(unique(recording.steps))
    lsgrid = SliderGrid(conv_dist_fig[1, 2][1, 1],
        (label = "Respondent", range = respondents, format = "{:d}"),
        (label = "Time step", range = steps, format = "{:d}"),
        width = 350,
        height = 200)

    toggle_labels = [
        "posterior ability estimate",
        "raw ability estimate",
        "actual ability",
        "current item response",
        "previous responses"
    ]
    toggles = [Toggle(conv_dist_fig, active = true) for _ in toggle_labels]
    labels = [Label(conv_dist_fig, lift(x -> x ? "Hide $l" : "Show $l", t.active))
              for (t, l) in zip(toggles, toggle_labels)]
    toggle_by_name = Dict(zip(toggle_labels, toggles))

    conv_dist_fig[1, 2][2, 1] = grid!(hcat(toggles, labels), tellheight = false)

    respondent = lsgrid.sliders[1].value
    time_step = lsgrid.sliders[2].value

    cur_col_idx = @lift(recording.respondent_step_lookup[($respondent, $time_step)])
    cur_likelihood_ys = @lift(@view recording.likelihoods[:, $cur_col_idx])
    cur_raw_likelihood_ys = @lift(@view recording.raw_likelihoods[:, $cur_col_idx])
    cur_response_ys = @lift(@view recording.item_responses[:, $cur_col_idx])
    if abilities !== nothing
        cur_ability = @lift(abilities[$respondent])
    end
    function mk_get_correctness(correct)
        function get_correctness(time_step, respondent)
            difficulty = @view recording.item_difficulties[1:time_step, respondent]
            correctness = @view recording.item_correctness[1:time_step, respondent]
            difficulty[correctness .== correct]
        end
    end
    cur_prev_correct = lift(mk_get_correctness(true), time_step, respondent)
    cur_prev_incorrect = lift(mk_get_correctness(false), time_step, respondent)

    posterior_likelihood_line = lines!(ax, recording.xs, cur_likelihood_ys)
    raw_likelihood_line = lines!(ax, recording.xs, cur_raw_likelihood_ys)
    cur_item_response_curve = lines!(ax, recording.xs, cur_response_ys)
    correct_items = scatter!(ax, cur_prev_correct, [0.0], color = :green)
    incorrect_items = scatter!(ax, cur_prev_incorrect, [0.0], color = :red)
    if abilities !== nothing
        actual_ability_line = vlines!(ax, cur_ability)
    end

    connect!(correct_items.visible, toggle_by_name["previous responses"].active)
    connect!(incorrect_items.visible, toggle_by_name["previous responses"].active)
    # TODO: put back: KeyError: key :visible not found
    #connect!(actual_ability_line.visible, toggle_by_name["actual ability"].active)
    connect!(posterior_likelihood_line.visible,
        toggle_by_name["posterior ability estimate"].active)
    connect!(raw_likelihood_line.visible, toggle_by_name["raw ability estimate"].active)
    connect!(cur_item_response_curve.visible,
        toggle_by_name["current item response"].active)

    conv_dist_fig
end
