using Pkg

Pkg.activate(joinpath(@__DIR__,".."))

using CoolProject
using DrWatson
using Plots

n=5000
X,Y=runsimulation(n)
p=plot(X,Y, size=(600,300))
filename=savename((n=n,), "png")
mkpath(plotsdir())
savefig(p, plotsdir(filename))


