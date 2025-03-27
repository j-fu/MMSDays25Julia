# MMSDays25Julia

Material for the mini-workshop "The Julia language: Reproducibility infrastructure and project workflows" at Leibniz MMS Days 2025.

## Files in this repository
```
├── julia-reproducibility-mms25.jl   # Presentation (Pluto notebook)
├── julia-reproducibility-mms25.pdf  # Preentation (Rendered to pdf)
├── examples                         # Examples discussed during the workshop  
│   ├── coolscript.jl              
│   ├── coolnotebook.jl
│   ├── CoolProject
│   └── project-skeleton
└── README.md                       # This readme
```

## Installation

- How to install Julia: [https://julialang.org/downloads/](https://julialang.org/downloads/#install_julia)
- How to install Pluto: [https://plutojl.org/](https://plutojl.org/#install)
- How to start the presentation:
```
$ julia
julia> using Pkg
julia> Pkg.add("Pluto")
julia> using Pluto
julia> Pluto.run("julia-reproducibility-mms25.jl"
```

## Alternative/extended takes

- Modern Julia Workflows: [https://modernjuliaworkflows.org/](https://modernjuliaworkflows.org/)
- Marginalia/Julia: [ https://j-fu.github.io/marginalia](https://j-fu.github.io/marginalia/julia/project-workflow/)
