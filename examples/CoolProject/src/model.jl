"""
    runsimulation(n)

Run simulation on n nodes.
"""
function runsimulation(n)
    X=range(0,10, length=n)
    Y=sin.(X)+0.1*rand(length(X))
    return X,Y
end
