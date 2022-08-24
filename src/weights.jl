"""
    MetaWeights{InnerMetaGraph<:MetaGraph,Weight<:Real} <: AbstractMatrix{Weight}

Matrix-like wrapper for edge weights on a metagraph of type `InnerMetaGraph`.
"""

struct MetaWeights{InnerMetaGraph <: MetaGraph, Weight <: Real} <: AbstractMatrix{Weight}
    meta_graph::InnerMetaGraph
end

Base.show(io::IO, meta_weights::MetaWeights) = print(io, "MetaWeights of size $(size(meta_weights))")
Base.show(io::IO, ::MIME"text/plain", x::MetaWeights) = show(io, x)

MetaWeights(meta_graph::MetaGraph) = MetaWeights{typeof(meta_graph), weighttype(meta_graph)}(meta_graph)

"""
    weigths(meta_graph)

Return a matrix-like `MetaWeights` object containing the edge weights for meta_graph `meta_graph`.
"""
Graphs.weights(meta_graph::MetaGraph) = MetaWeights(meta_graph)

function Base.size(meta_weights::MetaWeights)
    vertices = nv(meta_weights.meta_graph)
    (vertices, vertices)
end

"""
    weighttype(meta_graph)

Return the weight type for metagraph `meta_graph`.
"""
function weighttype(
    ::MetaGraph{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:Any, Weight},
) where {Weight}
    Weight
end

"""
    get_weight_function(meta_graph)

Return the weight function for metagraph `meta_graph`.
"""
get_weight_function(meta_graph::MetaGraph) = meta_graph.weight_function

"""
    default_weight(meta_graph)

Return the default weight for metagraph `meta_graph`.
"""
default_weight(meta_graph::MetaGraph) = meta_graph.default_weight

"""
    getindex(meta_weights::MetaWeights, code_1, code_2)

Get the weight of edge `(code_1, code_2)`.
"""
function Base.getindex(meta_weights::MetaWeights, code_1::Integer, code_2::Integer)
    meta_graph = meta_weights.meta_graph
    if has_edge(meta_graph, code_1, code_2)
        labels = meta_graph.vertex_labels
        weight_function = get_weight_function(meta_graph)
        weight_function(meta_graph[arrange(meta_graph, labels[code_1], labels[code_2], code_1, code_2)...])
    else
        default_weight(meta_graph)
    end
end
