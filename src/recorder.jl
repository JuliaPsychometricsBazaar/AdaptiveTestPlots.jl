mutable struct CatRecorder{AbilityVecT}
    col_idx::Int
    step::Int
    points::Int
    respondents::Vector{Int}
    ability_ests::AbilityVecT
    ability_divs::Vector{Float64}
    steps::Vector{Int}
    xs::Union{Nothing, AbilityVecT}
    likelihoods::Matrix{Float64}
    integrator::AbilityIntegrator
    raw_estimator::LikelihoodAbilityEstimator
    raw_likelihoods::Matrix{Float64}
    item_responses::Matrix{Float64}
    item_difficulties::Matrix{Float64}
    item_index::Matrix{Int}
    item_correctness::Matrix{Bool}
    ability_estimator::AbilityEstimator
    respondent_step_lookup::Dict{Tuple{Int, Int}, Int}
    actual_abilities::Union{Nothing, AbilityVecT}
end

#xs = range(-2.5, 2.5, length=points)

"""
$(TYPEDSIGNATURES)
"""
function CatRecorder(xs,
        points,
        ability_ests,
        num_questions,
        num_respondents,
        integrator,
        raw_estimator,
        ability_estimator,
        actual_abilities = nothing)
    num_values = num_questions * num_respondents
    if xs === nothing
        xs_vec = nothing
    else
        xs_vec = collect(xs)
    end

    CatRecorder(1,
        1,
        points,
        zeros(Int, num_values),
        ability_ests,
        zeros(Float64, num_values),
        zeros(Int, num_values),
        xs_vec,
        zeros(points, num_values),
        AbilityIntegrator(integrator),
        raw_estimator,
        zeros(points, num_values),
        zeros(points, num_values),
        zeros(num_questions, num_respondents),
        zeros(Int, num_questions, num_respondents),
        zeros(Bool, num_questions, num_respondents),
        ability_estimator,
        Dict{Tuple{Int, Int}, Int}(),
        actual_abilities)
end

function CatRecorder(xs::AbstractVector{Float64},
        responses,
        integrator,
        raw_estimator,
        ability_estimator,
        actual_abilities = nothing)
    points = size(xs, 1)
    num_questions = size(responses, 1)
    num_respondents = size(responses, 2)
    num_values = num_questions * num_respondents
    CatRecorder(xs,
        points,
        zeros(num_values),
        num_questions,
        num_respondents,
        integrator,
        raw_estimator,
        ability_estimator,
        actual_abilities)
end

function CatRecorder(xs::AbstractMatrix{Float64},
        responses,
        integrator,
        raw_estimator,
        ability_estimator,
        actual_abilities = nothing)
    dims = size(xs, 1)
    points = size(xs, 2)
    num_questions = size(responses, 1)
    num_respondents = size(responses, 2)
    num_values = num_questions * num_respondents
    CatRecorder(xs,
        points,
        zeros(dims, num_values),
        num_questions,
        num_respondents,
        integrator,
        raw_estimator,
        ability_estimator,
        actual_abilities)
end

function CatRecorder(xs::AbstractVector{Float64},
        max_responses::Int,
        integrator,
        raw_estimator,
        ability_estimator,
        actual_abilities = nothing)
    points = size(xs, 1)
    CatRecorder(xs,
        points,
        zeros(max_responses),
        max_responses,
        1,
        integrator,
        raw_estimator,
        ability_estimator,
        actual_abilities)
end

function CatRecorder(xs::AbstractMatrix{Float64},
        max_responses::Int,
        integrator,
        raw_estimator,
        ability_estimator,
        actual_abilities = nothing)
    dims = size(xs, 1)
    points = size(xs, 2)
    CatRecorder(xs,
        points,
        zeros(dims, max_responses),
        max_responses,
        1,
        integrator,
        raw_estimator,
        ability_estimator,
        actual_abilities)
end

function push_ability_est!(ability_ests::AbstractMatrix{Float64}, col_idx, ability_est)
    ability_ests[:, col_idx] = ability_est
end

function push_ability_est!(ability_ests::AbstractVector{Float64}, col_idx, ability_est)
    ability_ests[col_idx] = ability_est
end

function eachmatcol(xs::Matrix)
    eachcol(xs)
end

function eachmatcol(xs::Vector)
    xs
end

function save_sampled(
        xs::Nothing, integrator, recorder::CatRecorder, tracked_responses, ir, item_correct)
    # Just skip saving in this case
end

function save_sampled(xs::Nothing, integrator::RiemannEnumerationIntegrator,
        recorder::CatRecorder, tracked_responses, ir, item_correct)
    # In this case, the item bank is probably sampled so we can use that

    # Save likelihoods
    dist_est = distribution_estimator(recorder.ability_estimator)
    denom = normdenom(integrator, dist_est, tracked_responses)
    recorder.likelihoods[:, recorder.col_idx] = function_ys(
        Aggregators.pdf(
        dist_est,
        tracked_responses
    )
    ) ./ denom
    raw_denom = normdenom(integrator, recorder.raw_estimator, tracked_responses)
    recorder.raw_likelihoods[:, recorder.col_idx] = function_ys(
        Aggregators.pdf(
        recorder.raw_estimator,
        tracked_responses
    )
    ) ./ raw_denom

    # Save item responses
    recorder.item_responses[:, recorder.col_idx] = item_ys(ir, item_correct)
end

function save_sampled(
        xs, integrator, recorder::CatRecorder, tracked_responses, ir, item_correct)
    # Save likelihoods
    dist_est = distribution_estimator(recorder.ability_estimator)
    denom = normdenom(integrator, dist_est, tracked_responses)
    recorder.likelihoods[:, recorder.col_idx] = Aggregators.pdf.(Ref(dist_est),
        Ref(tracked_responses),
        eachmatcol(xs)) ./ denom
    raw_denom = normdenom(integrator, recorder.raw_estimator, tracked_responses)
    recorder.raw_likelihoods[:, recorder.col_idx] = Aggregators.pdf.(
        Ref(recorder.raw_estimator),
        Ref(tracked_responses),
        eachmatcol(xs)) ./ raw_denom

    # Save item responses
    recorder.item_responses[:, recorder.col_idx] = resp.(Ref(ir),
        item_correct,
        eachmatcol(xs))
end

"""
$(TYPEDSIGNATURES)
"""
function (recorder::CatRecorder)(tracked_responses, resp_idx, terminating)
    ability_est = recorder.ability_estimator(tracked_responses)
    if recorder.col_idx > 1 && recorder.respondents[recorder.col_idx - 1] != resp_idx
        recorder.step = 1
    end
    recorder.respondent_step_lookup[(resp_idx, recorder.step)] = recorder.col_idx
    recorder.respondents[recorder.col_idx] = resp_idx
    push_ability_est!(recorder.ability_ests, recorder.col_idx, ability_est)
    if recorder.actual_abilities !== nothing
        recorder.ability_divs[recorder.col_idx] = sum(abs.(ability_est .-
                                                           recorder.actual_abilities[resp_idx]))
    end
    recorder.steps[recorder.col_idx] = recorder.step

    item_index = tracked_responses.responses.indices[end]
    item_correct = tracked_responses.responses.values[end] > 0
    ir = ItemResponse(tracked_responses.item_bank, item_index)
    save_sampled(
        recorder.xs, recorder.integrator, recorder, tracked_responses, ir, item_correct)

    # Save item parameters
    params = item_params(tracked_responses.item_bank, item_index)
    if hasproperty(params, :difficulty)
        recorder.item_difficulties[recorder.step, resp_idx] = params.difficulty
    end
    recorder.item_index[recorder.step, resp_idx] = item_index
    recorder.item_correctness[recorder.step, resp_idx] = item_correct

    recorder.col_idx += 1
    recorder.step += 1
end

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
function lh_evolution_interactive(recorder; abilities = nothing)
    conv_dist_fig = Figure(size = (1000, 700))
    ax = Axis(conv_dist_fig[1, 1])

    respondents = 1:length(unique(recorder.respondents))
    steps = 1:length(unique(recorder.steps))
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

    cur_col_idx = @lift(recorder.respondent_step_lookup[($respondent, $time_step)])
    cur_likelihood_ys = @lift(@view recorder.likelihoods[:, $cur_col_idx])
    cur_raw_likelihood_ys = @lift(@view recorder.raw_likelihoods[:, $cur_col_idx])
    cur_response_ys = @lift(@view recorder.item_responses[:, $cur_col_idx])
    if abilities !== nothing
        cur_ability = @lift(abilities[$respondent])
    end
    function mk_get_correctness(correct)
        function get_correctness(time_step, respondent)
            difficulty = @view recorder.item_difficulties[1:time_step, respondent]
            correctness = @view recorder.item_correctness[1:time_step, respondent]
            difficulty[correctness .== correct]
        end
    end
    cur_prev_correct = lift(mk_get_correctness(true), time_step, respondent)
    cur_prev_incorrect = lift(mk_get_correctness(false), time_step, respondent)

    posterior_likelihood_line = lines!(ax, recorder.xs, cur_likelihood_ys)
    raw_likelihood_line = lines!(ax, recorder.xs, cur_raw_likelihood_ys)
    cur_item_response_curve = lines!(ax, recorder.xs, cur_response_ys)
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
