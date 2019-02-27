module Readme

using LightGraphs
using GraphPlot, GraphPlot.Compose
using StorageGraphs
using Test
using Logging

log = SimpleLogger(stdout, Logging.Debug)

function draw_graph(g, x, y, name::String, args...; ns=1, C=5)
    layout = (x...)->spring_layout(x...; C=C)
    draw(SVG("$(@__DIR__)/../assets/$name.svg", x*cm, y*cm),
        plot_graph(g, layout=layout, nodesize=ns))
end

g = StorageGraph()
@test add_vertex!.(Ref(g), [(x=1,),(x=2,),(x=3,)]) |> all
@test get_prop(g, 1) == (x=1,)
@test get_prop(g, 2) == (x=2,)
@test get_prop(g, 3) == (x=3,)

draw_graph(g, 10, 4, "ex1")

# with_logger(log) do
#     add_derived_values!(g, (x=[1,2,3],), (y=[1,4,9],))
# end

@test_logs((:debug, (x = 1,) => (y = 1,)),
           (:debug, (x = 2,) => (y = 4,)),
           (:debug, (x = 3,) => (y = 9,)),
    min_level=Logging.Debug, match_mode=:all,
    add_derived_values!(g, (x=[1,2,3],), (y=[1,4,9],)))

@test nv(g) == 6
@test ne(g) == 3
@test get_prop(g, 4) == (y=1,)
@test get_prop(g, 5) == (y=4,)
@test get_prop(g, 6) == (y=9,)

draw_graph(g, 10, 4, "ex2", C=8)

# Code snippets

using StorageGraphs

g = StorageGraph()
add_derived_values!(g, (x=[1,2,3],), (y=[1,4,9],))

# We can add the nodes one by one
add_nodes!(g, (P=1,)=>(alg="alg1",))
# or in bulk
add_bulk!(g, (P=1,)=>(alg="alg1",), (x=[10., 20., 30.],))

plot_graph(g)
draw(SVG("$(@__DIR__)/../assets/ic_graph.svg", 12cm, 4.5cm),
    plot_graph(g, layout=layout, nodesize=ns, edgelabeldistx=0.5, edgelabeldisty=0.5))

simulation(x; alg) = alg == "alg1" ? x.+2 : x.^2

# retrieve the previously stored initial conditions
x = [g.data[v][:x] for v in final_neighborhs(g, (P=1,)=>(alg="alg1",))]
results = simulation(x, alg="alg1")
add_derived_values!(g, ((P=1,),(alg="alg1",)), (x=x,), (r=results,))

plot_graph(g)
draw(SVG("$(@__DIR__)/../assets/sim_graph.svg", 12cm, 6cm),
    plot_graph(g, layout=layout, nodesize=ns, edgelabeldistx=0.5, edgelabeldisty=0.5))

add_derived_values!(g, ((P=2,),(alg="alg1",)), (x=2x,), (r=2results,))

plot_graph(g)
draw(SVG("$(@__DIR__)/../assets/complicated_graph.svg", 12cm, 10cm),
    plot_graph(g, layout=layout, nodesize=ns, edgelabeldistx=0.5, edgelabeldisty=0.5))

end  # module Readme

@testset "Readme" begin
    using .Readme
end
