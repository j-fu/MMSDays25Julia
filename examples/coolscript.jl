using Plots
X=range(0,10, length=2001)
Y=sin.(X)+0.1*rand(length(X))
plot(X,Y)

