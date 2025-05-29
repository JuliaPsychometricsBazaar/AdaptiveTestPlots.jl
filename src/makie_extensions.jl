using Makie: make_block_docstring  # This is used by @Block

# Allows hline! on AlgebraOfGraphics plots. May be better way in future.
# See: https://github.com/JuliaPlots/AlgebraOfGraphics.jl/issues/299
function aog_hlines!(fg::AlgebraOfGraphics.FigureGrid, args...; kws...)
    for axis in fg.grid
        hlines!(axis.axis, args...; kws...)
    end
    return fg
end

@Block LabelledToggleGrid begin
    @forwarded_layout
    toggles::Vector{Toggle}
    labels::Vector{Label}
    @attributes begin
        "The horizontal alignment of the block in its suggested bounding box."
        halign = :center
        "The vertical alignment of the block in its suggested bounding box."
        valign = :center
        "The width setting of the block."
        width = Auto()
        "The height setting of the block."
        height = Auto()
        "Controls if the parent layout can adjust to this block's width"
        tellwidth::Bool = true
        "Controls if the parent layout can adjust to this block's height"
        tellheight::Bool = true
        "The align mode of the block in its parent GridLayout."
        alignmode = Inside()
    end
end

function Makie.initialize_block!(sg::LabelledToggleGrid, nts::NamedTuple...)
    sg.toggles = Toggle[]
    sg.labels = Label[]

    for (i, nt) in enumerate(nts)
        label = haskey(nt, :label) ? nt.label : ""
        on_label = haskey(nt, :on_label) ? nt.on_label : label
        off_label = haskey(nt, :off_label) ? nt.off_label : label
        remaining_pairs = filter(pair -> pair[1] ∉ (:label, :on_label, :off_label),
            pairs(nt))
        toggle = Toggle(sg.layout[i, 2]; remaining_pairs...)
        label = Label(sg.layout[i, 1],
            lift(x -> x ? on_label : off_label, toggle.active),
            halign = :left)
        push!(sg.toggles, toggle)
        push!(sg.labels, label)
    end
end

@Block MenuGrid begin
    @forwarded_layout
    menus::Vector{Menu}
    labels::Vector{Label}
    @attributes begin
        "The horizontal alignment of the block in its suggested bounding box."
        halign = :center
        "The vertical alignment of the block in its suggested bounding box."
        valign = :center
        "The width setting of the block."
        width = Auto()
        "The height setting of the block."
        height = Auto()
        "Controls if the parent layout can adjust to this block's width"
        tellwidth::Bool = true
        "Controls if the parent layout can adjust to this block's height"
        tellheight::Bool = true
        "The align mode of the block in its parent GridLayout."
        alignmode = Inside()
    end
end

function Makie.initialize_block!(sg::MenuGrid, nts::NamedTuple...)
    sg.menus = Menu[]
    sg.labels = Label[]

    for (i, nt) in enumerate(nts)
        label = haskey(nt, :label) ? nt.label : ""
        remaining_pairs = filter(pair -> pair[1] ∉ (:label, :format), pairs(nt))
        menu = Menu(sg.layout[i, 2]; remaining_pairs...)
        lbl = Label(sg.layout[i, 1], label, halign = :left)
        push!(sg.menus, menu)
        push!(sg.labels, lbl)
    end
end

macro automakie()
    quote
        if "USE_WGL_MAKIE" in keys(ENV)
            using WGLMakie
        elseif "USE_GL_MAKIE" in keys(ENV)
            using GLMakie
        elseif "USE_CARIO_MAKIE" in keys(ENV)
            using CairoMakie
        elseif (isdefined(Main, :IJulia) && Main.IJulia.inited)
            using WGLMakie
        elseif isdefined(Main, :WGLMakie)
            const WGLMakie = Main.WGLMakie
        elseif isdefined(Main, :GLMakie)
            const GLMakie = Main.GLMakie
        elseif isdefined(Main, :CairoMakie)
            const CairoMakie = Main.CairoMakie
        else
            Pkg = Base.require(Base.PkgId(Base.UUID(0x44cfe95a1eb252eab672e2afdf69b78f),
                "Pkg"))
            if "WGLMakie" in keys(Pkg.project().dependencies)
                using WGLMakie
            elseif "GLMakie" in keys(Pkg.project().dependencies)
                using GLMakie
            else
                using CairoMakie
            end
        end
    end
end
