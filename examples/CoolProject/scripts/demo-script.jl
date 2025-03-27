using Pkg

Pkg.activate(joinpath(@__DIR__,".."))

using CoolProject

println(CoolProject.greet())
