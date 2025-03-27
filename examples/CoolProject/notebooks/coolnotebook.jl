### A Pluto.jl notebook ###
# v0.20.5

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 60941eaa-1aea-11eb-1277-97b991548781
begin 
	using Pkg
	Pkg.activate(joinpath(@__DIR__,".."))
	using Revise
	using PlutoUI
	using Plots
	using CoolProject
end

# ╔═╡ 882dda23-63b9-4b1e-a04e-69071deff69a
md"This notebook is only relocateable together with the whole CoolProject project."

# ╔═╡ df596603-7507-418d-bd96-fefa82240634
@bind n Slider(10:100:5000, show_value=true)

# ╔═╡ a8e37976-5db2-485f-87aa-0cf7155e8e00
X,Y=runsimulation(n)

# ╔═╡ dc22609b-39e8-4407-ae5f-71593bb1840f
plot(X,Y, size=(600,300))

# ╔═╡ Cell order:
# ╟─882dda23-63b9-4b1e-a04e-69071deff69a
# ╠═60941eaa-1aea-11eb-1277-97b991548781
# ╠═df596603-7507-418d-bd96-fefa82240634
# ╠═a8e37976-5db2-485f-87aa-0cf7155e8e00
# ╠═dc22609b-39e8-4407-ae5f-71593bb1840f
