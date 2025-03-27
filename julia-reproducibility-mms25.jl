### A Pluto.jl notebook ###
# v0.20.5

using Markdown
using InteractiveUtils

# ╔═╡ 60941eaa-1aea-11eb-1277-97b991548781
begin
    using PlutoUI,HypertextLiteral,ForwardDiff
	const EL=PlutoUI.ExperimentalLayout
	using Pkg

end;

# ╔═╡ 6d5f35a4-5a34-4bba-a2ae-e6fe43ec835e
using Test

# ╔═╡ 5707ba63-2798-4c5c-9fb4-4295bce55796
using GSL_jll

# ╔═╡ 4085ce7c-b2e8-4756-af92-6b853f3d9088
using GSL

# ╔═╡ 97989456-9703-4ddb-ab35-d20b300e3ad4
begin

using AbstractTrees

abstract type FSNode end

struct File <: FSNode
    path::String
end

AbstractTrees.children(::File) = ()

struct Directory <: FSNode
    path::String
end

function AbstractTrees.children(d::Directory)
    contents = readdir(d.path)
    children = Vector{Union{Directory,File}}(undef,length(contents))
    for (i,c) in enumerate(contents)
        path = joinpath(d.path,c)
        children[i] = isdir(path) ? Directory(path) : File(path)
    end
    return children
end
	AbstractTrees.nodevalue(n::FSNode) = n.path

AbstractTrees.printnode(io::IO, d::Directory) = print(io, basename(d.path))
AbstractTrees.printnode(io::IO, f::File) = print(io, basename(f.path))

function showdir(dir; maxdepth=2)
	io=IOBuffer()
	print_tree(io,Directory(dir);maxdepth)
	Markdown.parse("""
	```
	$(String(take!(io)))
	```
	""")
end
printdir(dir;maxdepth=2)=print_tree(Directory(dir);maxdepth)
showfile(fname)=Markdown.parse("""
	```
	$(read(fname,String))
	```
	""")
printfile(fname)=println(read(fname,String))
end;

# ╔═╡ bf1d7148-90be-436a-a8ce-5d46bd21d8d9
begin
using PlutoVista,GridVisualize,ExtendableGrids
end

# ╔═╡ a41278ee-e4d8-479a-8167-cfd1fab307bc
md"""
## Leibniz MMS Days 2025
"""

# ╔═╡ bdb3548c-9ecf-4e50-beef-f226f257f425
md"""
## The two language problem
"""

# ╔═╡ ea954f05-b245-4c4a-91e7-fc257b3cc8b0
md"""
## Julia
"""

# ╔═╡ cc07ac1a-9266-481f-ab27-61252509eeeb
EL.hbox([md"""
- Syntax comparable to matlab, python/numpy
- Just-ahead-of time compilation  to native code ``\Rightarrow`` performance without need to vectorize or to call a computational kernel in another language
- Performant multi-dimensional arrays
- Comprehensive linear algebra
- Parallelization: SIMD, multithreading, distributed
- Interoperability with C, C++, python, R ``\dots``
- Use of modern knowledge in language design
- Open source (MIT License)
- Excellent __package management__

- Current stable release: 1.11
- Current LTS release: 1.10
""",
md""" ``\quad``""",
EL.vbox([
md"""[https://julialang.org](https://julialang.org)""",
html"""<iframe src="https://julialang.org" style="width: 300px; height: 300px;"></iframe>"""])
	])




# ╔═╡ f5decf61-fe75-4760-84f4-7d8eabe417df
md"""
## https://julialang.org/downloads/#install_julia
"""

# ╔═╡ 7c65ed65-8a1c-4658-981c-d9018169f0c3
html"""<iframe src="https://julialang.org/downloads/#install_julia" style="width: 700px; height: 300px;"></iframe>"""


# ╔═╡ 5932287d-3e72-4533-92e2-7e02f0c13015
md"""
## Packages
"""

# ╔═╡ 7b4b635d-c600-4d6a-9cef-64bd97eb6a3e
EL.grid([md"""
Extend Julia's core functionality. Each package is a git repository with standardized structure.
- __Package Registries__  provide the infrastructure for finding package repositories via package names
-  __General Registry__: ≈ 11500  packages (October 2024)
- [Pkg.jl](https://pkgdocs.julialang.org/v1/) __Package Manager__  is part of the Julia standard library
- __Composability__ of packages due to generic Julia source code  (like C++ header only libs)
- __Easy to install__ via  `Pkg`:
```
julia> using Pkg
julia> Pkg.add("QuantumFrobnicate")
julia> using QuantumFrobnicate
julia> QuantumFrobnicate.minimize_uncertainty!()
```

"""  EL.vbox([  md"""xkcd.com""",
Resource("https://imgs.xkcd.com/comics/universal_install_script_2x.png",
		:width=>240)
      ])
])

# ╔═╡ ff993ebe-86c2-4f96-9572-426bfd08263e
md"""
## Standard structure of a Julia package
"""

# ╔═╡ 5765c545-9f01-434d-aa5f-61bbbc6ddb7b
EL.grid([md"""

- Locally, each package is stored in a directory named e.g. `MyPack` for package `MyPack.jl`.
- Structure of a package directory:
   - `MyPack/src`: subdirectory for package source code
      - `MyPack/src/MyPack.jl`: code defining a module `MyPack`
      - Further Julia sources included by `MyPack.jl`
   - `MyPack/ext`: Source code of package extensions
   - `MyPack/test`: code for unit testing
   - `MyPack/docs`: markdown sources + code for documentation
   - LICENSE.md: (open source) license
   - README.md: README - basic introduction text
   - `MyPack/.github`: control files for github CI
   - Project.toml: Metadata, list of dependencies
"""  showdir(pkgdir(ForwardDiff),maxdepth=1)])

# ╔═╡ 78d80605-8e36-4714-90da-44bd613c5357
md"""
## Package extensions: ext/

- Contain code of MyPkg which is used only if some other package is loaded.
- E.g. `MyPack/ext/MyPkgOtherPkgExt.jl` is loaded only if `OtherPkg` is used
- Avoid extensive strong dependencies and precompilation of code which is not always used.
  - E.g. load plotting code only if the plotting package is used.
- `OtherPkg` needs to be recorded in the project metadata as "weak dependency"

"""

# ╔═╡ 2b6bae65-0270-4659-a1ff-2a594b068e72
md"""
## Continuous integration: test/runtests.jl
- `test/runtests.jl` contains code for testing package functionality
- Invoked by `Pkg.test("MyPackage")`
- `@test` macro allows to test code
- `test/Project.toml` can contain additional dependencies for testing
"""

# ╔═╡ a073d980-63a2-499a-acdd-cbf2a5cb4a9d
@test 1+1 == 2

# ╔═╡ 5cf4cae3-7406-4235-aab7-d0cc25a90a47
md"""
## Documentation generation: docs/make.jl
- `Documenter.jl` Julia package for documentation generation from docstrings
- Part of standard Julia CI: automatically upon package releases
"""

# ╔═╡ 4084656e-ba52-4359-a73d-e242818e09c9
"""
	sinsquare(x)
Return the squared sinus of x
"""
function sinsquare(x)
	return sin(x)^2
end

# ╔═╡ c64e094a-edab-4af1-b9f3-e0221261e3f9
md"""
## Package metadata & dependencies: Project.toml
"""

# ╔═╡ d9d57deb-85b1-4842-a71c-5d740603a118
md"""
Contents of `Project.toml` for the ForwardDiff.jl package
"""

# ╔═╡ ac8ba311-c791-4003-b556-a6d7e4f46042
printfile(joinpath(pkgdir(ForwardDiff),"Project.toml"))

# ╔═╡ 7ae55b24-cb55-46b0-b65f-fb3650ca93cd
md"""
## Package metadata: Project.toml
"""

# ╔═╡ 86590ce4-f14b-4a9f-982f-f89e28939fa8
EL.grid([md"""
- Package name
- UUID to identify package, name is secondary
   - ``\Rightarrow`` manage different packages with the same name
- Version according to Semantic Versioning
- `[deps]`: list of dependecies with UUIDs
- `[weakdeps]`:  list of weak dependecies with UUIDs
- `[extensions]`: list of package extensions and corresponding weak dependencies
- `[compat]` section: version compatibility bounds for strong and weak dependencies and julia
- `[sources]` section (since julia 1.11): path or git url of unregistered packages
- Further info: author, additional packages for testing ``\dots``
"""  EL.vbox([
Resource("https://www.wias-berlin.de/people/fuhrmann/blobs/A_package_with_address.png",:width=>240),
	html"""<font size=-5> dreamstudio.ai CC01.0</font>"""
      ])
])

# ╔═╡ f449284a-3d1b-4e4e-834e-11fca55561bb
md"""
## Semantic versioning: [compat]

"""

# ╔═╡ 21364af4-1619-4056-a865-d03831cbf2e9
EL.hbox([ md"""
With a package  version `X.Y.Z`, increment:

- "Major"  `X` when incompatible API changes are made
- "Minor"	 `Y` when functionality is added in a backward compatible manner
- "Patch"	 `Z` when  bug fixes are made
- Julia:  major  version is 0 $\Rightarrow$ minor version acts like major
- `[compat]` section describes the compatibility bounds
- `Pkg.add` selects highest possible  version
- Resolver looks for optimal solution of dependency versions
```toml
[compat]
julia = "1.6"    # versions >=1.6 , < 2.0
Example = "0.5"  # versions >=0.5 , < 0.6
Foo = "1.2, 2"   # versions >=1.2 , < 3.0
Bar = "~1.2.23"  # only version 1.2.23
```
""",

md""" ``\quad`` """,

EL.vbox([
md"""[https://semver.org](https://semver.org)""",
html"""<iframe src="https://semver.org/#summary" style="width: 250px; height: 300px;"></iframe>"""])
	])

# ╔═╡ 1e624ad2-09c0-49d5-9ba2-ed89035b4861
md"""
## What happens when adding a package ?
"""

# ╔═╡ 14429a42-d88c-45e0-b0ba-b7980c5f8d3f
EL.grid([md"""
`julia> Pkg.add("MyPkg")`

1. Package name and UUID are looked up in a __registry__
2. Package git repo URL read from registry (nowadays packages are cached and served from a package server)
3. Calculate version compatibility for package and dependencies
4. Package and dependencies downloaded to `~/.julia/packages/`
5. Package and dependencies recorded in  current active __environment__
6. Some package code is precompiled

`julia> using MyPkg`

7. Precompile  more of the package code
8. Make the exported symbols available for use

""" EL.vbox([
Resource("https://www.wias-berlin.de/people/fuhrmann/blobs/Receiving_a_package.png",:width=>200),
	html"""<font size=-5> dreamstudio.ai CC01.0</font>"""
      ])
])

# ╔═╡ 9fa14fbf-bf42-4d46-a8f0-c17c86108991
md"""
## Manifest.toml
- Automatically generated and updated 
- Lists recursively all package dependencies with their installed versions
- Since 1.11: Julia version specific manifest files: `Manifest-v1.11.toml`,  `Manifest-v1.12.toml` …
"""

# ╔═╡ 5207440a-b7ad-4175-b60a-a390e4fcedda
print(read(joinpath(dirname(Pkg.project().path),"Manifest.toml"),String))

# ╔═╡ bb298b7c-1190-4b28-96c9-c5af6d04ac2d
md"""
## Environments: Project.toml & Manifest.toml
"""

# ╔═╡ 7feb3dae-2ec9-4557-a305-72f5a40f785f
EL.grid([md"""  __Environment__: directory with `Project.toml` and `Manifest.toml`
- `Project.toml`: name + UUIDs of all packages added
- `Manifest.toml`: name + UUID + version + git-hash of package _and all of its depedencies and their dependencies_
- Julia codes always runs in an  environment
   - `$ julia`: use  __default environment__ for julia version, e.g. `~/.julia/environments/v1.11`
   - `$ julia --project=@xyz`: activate __shared environment__ in  `~/.julia/environments/xyz`
   - `$ julia --project=dir` or `julia> Pkg.activate("dir")`: activate __project environment__ in directory `dir`
""" EL.vbox([
Resource("https://www.wias-berlin.de/people/fuhrmann/blobs/Environment.png",:width=>200),
	html"""<font size=-5> dreamstudio.ai CC01.0</font>"""
      ])
])


# ╔═╡ 90cf770e-45c3-4911-b3cb-90444910e80f
md"""
## Registries
"""

# ╔═╡ 4762eb48-b187-4819-a218-77e5678b96b4
EL.grid([md"""
__Registry__: directory collecting metadata of packages for look-up
- Maintained as git repository
- Default:  [https://github.com/JuliaRegistries/General](https://github.com/JuliaRegistries/General)
    - Like blockchain: no deletions, continued forever
    - Packages must be open source
    - Automated heuristic  decision process for new packages to be registered
- Local copy kept up-to-date for each Julia installation
- Multiple registries are possible
""" EL.vbox([
Resource("https://www.wias-berlin.de/people/fuhrmann/blobs/A_registrar__with_pen_and_book_a_la_tiziano.png",:width=>240),
	html"""<font size=-5> dreamstudio.ai CC01.0</font>"""
      ])
])






# ╔═╡ 7802879b-8436-4db6-b7e7-f8eea051cb42
md"""
## Publishing a package in the General Registry 

- Add Julia registrator app to github repository
- Increse version number in `Project.toml`
- Comment the relevant commit on github:
```
@JuliaRegistrator register

Release notes:
- Removed all the bugs

```
- Creates pull request to [`https://github.com/JuliaRegistries/General`](https://github.com/JuliaRegistries/General)
- If the package is new, merge it after 3-days waiting period and heuristic feasibility check
  - Github repo with standard structure
  - Reasonable name
  - OSI approved Open Source license
- Otherwise, merge automatically after some heuristic check

"""

# ╔═╡ 89d88a52-61b2-48b1-9d96-c583426d0db7
md"""
## I can't publish in the General Registry!

- [LocalRegistry.jl](https://github.com/GunnarFarneback/LocalRegistry.jl) supports user maintained registries
- Institutions or project cooperations can maintain their own package registries
```
julia> Pkg.registry.add("https://github.com/xyz/XYZRegistry")
julia> Pkg.add("PackageFromXYZRegistry")
```
- Uses full capabilities of `[compat]` mechanism - easy to manage by users
- Need to __trust__ the repository maintainers

- `[sources]` section in Project.toml since Julia 1.11 allows to specify path or URL of package source
```
    [sources]
    PkgA = {url="https://github.com/xyz/PkgA.jl"}
    PkgB = {path="packages/PkgB"}
```
"""

# ╔═╡ fc0a2152-28d6-452d-bc2d-e4b6c9ef71a5
md"""
## Binary packages
"""

# ╔═╡ 9e7cbb62-757e-41e3-9da7-cde10871375b
md"""
- __Foreign Function Interface (FFI)__ allows to call binary code compliant with the C ABI
- `CxxWrap.jl`, `CXX.jl` provide ways to interoperate with code compiled from C++
- __Binary packages:__ "jll's" and Julia wrappers around them
"""

# ╔═╡ 0878ff07-3c82-463f-a746-5b9233fdd231
 ccall((:gsl_sf_bessel_J0, GSL_jll.libgsl),Cdouble, (Cdouble,),6.0)

# ╔═╡ d6936e7a-d1fe-4a5c-b3e5-2c5c8abdb228
GSL.sf_bessel_J0(6.0)

# ╔═╡ 28ce3e73-05ac-445d-bab1-4fc338ac37bb
md"""
## BinaryBuilder & Yggdrasil
"""

# ╔═╡ a65a17da-68b2-44e6-81a8-78eea6b46350
md"""
## Hey, let us work together!
"""

# ╔═╡ 93acfc47-f5fe-40aa-a16a-6af89e3b86d4
md"""
```
# coolscript.jl
using Plots
X=range(0,10, length=2001)
Y=sin.(X)+0.1*rand(length(X))
plot(X,Y)
```
"""

# ╔═╡ 5c4ac205-d1b7-4b46-823e-10c63df2f287
md"""
```
julia> include("coolscript.jl")
julia> using Plots
│ Package Plots not found, but a package named Plots is available from a
│ registry.
│ Install package?
│   (@v1.11) pkg> add Plots
└ (y/n/o) [y]:
```
"""

# ╔═╡ 1903235e-bca1-416a-ba4e-131ba2b8e771
md"""
- __Default environment__  cluttered, possible incompatible compatibility requirements
- Need to tell collaborator: "before running the script, you need to install this and that"
"""

# ╔═╡ 82288118-3ade-4a20-8c94-c5de31f65f40
md"""
## Reproducible Notebooks: [Pluto.jl](https://github.com/fonsp/pluto.jl)
"""

# ╔═╡ 786b452a-b7bf-4957-a553-56ecd50b5786
X=0:0.1:5;

# ╔═╡ 21d92b62-104b-45dd-ab5c-ed5e5ab0edb7
f(x,y,z)=sin(x)*cos(3y)*z;

# ╔═╡ d9b5c2b0-bcbd-430e-9e51-c89386ec734a
grid=simplexgrid(X,X,X);

# ╔═╡ d744ef4a-cae6-49ed-bbe1-28145ae405ca
EL.grid([md"""
Browser based notebooks implemented in Julia and Javascript
- __Easy installation__:  installed as a single Julia package on Linux, MacOS, Windows
- __Reactive__: cell results are automatically recalculated
- __Version controllable__: no results in the notebook
- __Reproducible__: notebooks contain their own environment
- Efficient interaction with HTML+Javascript
- Created by Fons van der Plas & his friends
""" EL.vbox([ htl"""PlutoVista.jl+vtk.js+webgl: $(num_nodes(grid)) nodes""", scalarplot(grid,f;Plotter=PlutoVista,size=(200,200))])])

# ╔═╡ 9eb53f42-8e82-4450-971e-5d3452662e1f
md"""
## More Pluto.jl Benefits
"""

# ╔═╡ bd64d3b8-2056-4372-8964-9128109414c7
md"""
## Reproducible projects
"""

# ╔═╡ 0a5e9b36-1a92-4ca3-bf19-48e24b1195da
md"""
## A take on project structure
"""

# ╔═╡ b1b3fc07-ab73-41b7-a22b-02343c26bc4e
EL.hbox([
md"""
- `Project.toml`: Project metadata + dependencies
- `LICENSE`: License of the project. By default it is the MIT license
- `README.md`: Package summary
- `src`: Subdirectory for project specific code as part of the MyProject package representing the project.
- `test`: Unit tests for project code in `src`. Could include something from `scripts`, `notebooks`.
- `scripts`, `notebooks`: "Frontend" code for creating project results
- `docs`: Sources for the documentation created with `Documenter.jl`
- `etc`: Service code
""", md"", html"""
<pre style="width: 500px">
MyProject/
├── src
│   └── MyProject.jl
├── docs
│   ├── make.jl
│   ├── Project.toml
│   └── src
│       └── index.md
├── LICENSE
├── notebooks
│   └── demo-notebook.jl
├── Project.toml
├── README.md
├── scripts
│   └── demo-script.jl
├── etc
│   ├── runpluto.jl
│   └── instantiate.jl
└── test
    └── runtests.jl
</pre>
""" 
]; style= Dict("flex"=>"1 1 auto"))

# ╔═╡ f83b8d65-0c5b-43af-932a-b6c5529edd83
md"""
[PkgSkeleton.jl](https://github.com/tpapp/PkgSkeleton.jl) can generate these this:
Download and unpack project skeleton [project-skeleton.zip](https://j-fu.github.io/marginalia/assets/project-skeleton.zip).
Then invoke
```
julia> using PkgSkeleton
julia> PkgSkeleton.generate("MyProject"; templates=["project-skeleton"])
```

"""

# ╔═╡ 57293128-7711-499e-80fe-68543ef2bf34
md"""
## Further infrastructure
"""

# ╔═╡ 3c9bf8e5-b14e-4751-a8f2-a8ff89b8c873
EL.grid([md"""
- [DrWatson.jl](https://github.com/JuliaDynamics/DrWatson.jl) manages code and computational results in a Julia project repository
   - Automatic generation of data file names from simulation parameters
- [Visual Studio Code integration](https://code.visualstudio.com/docs/languages/julia)
- [Jupyter notebook support](https://github.com/JuliaLang/IJulia.jl)
- Integration with [quarto](https://quarto.org/docs/computations/julia.html) for reproducible publications
- [Draft repo](https://github.com/MilesCranmer/showyourwork_julia_example) for integration with [showyourwork](https://github.com/showyourwork/showyourwork)
""" EL.vbox([
	Resource("https://raw.githubusercontent.com/JuliaDynamics/JuliaDynamics/master/videos/drwatson/DrWatson-banner.png",:width=>200),
	EL.hbox([
	Resource("https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Visual_Studio_Code_1.35_icon.svg/512px-Visual_Studio_Code_1.35_icon.svg.png",:width=>100),
	Resource("https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Jupyter_logo.svg/883px-Jupyter_logo.svg.png", :width=>100)]),
Resource("https://quarto.org/quarto.png",:width=>200),
	Resource("https://raw.githubusercontent.com/showyourwork/.github/main/images/showyourwork.png", :width=>200)
])
])

# ╔═╡ 1d0b17b7-5e9b-4160-aaac-d5bb4db6a139
md"""
## Some Issues
"""

# ╔═╡ 4271f050-9e79-4031-bfe7-374951ad0fbf
md"""
## Conclusions
"""

# ╔═╡ 6eb68ba7-2e69-4688-829e-688c22f0440d
EL.grid([md"""
Julia provides as well a __fresh approach to reproducibility__, learning from the experiences of of `conda`, `npm` etc.
- Package management is part of the standard Julia workflow, available without further installation
- Transparent package and project source code without the need to know two languages or handling of build systems
- Introductions to Julia at an early stage should explain working with environments etc.
- Package management can be leveraged for reproducible research
""" EL.vbox([Resource("https://www.wias-berlin.de/people/fuhrmann/blobs/julia-fresh.png"),
             Resource("https://www.wias-berlin.de/people/fuhrmann/blobs/learning.png",:height=>220,:width=>220) ])])

# ╔═╡ 7a93e9a8-8a2d-4b11-84ef-691706c0eb0f
begin
    hrule()=html"""<hr>"""
    highlight(mdstring,color)= htl"""<blockquote style="padding: 10px; background-color: $(color);">$(mdstring)</blockquote>"""

	macro important_str(s)	:(highlight(Markdown.parse($s),"#ffcccc")) end
	macro definition_str(s)	:(highlight(Markdown.parse($s),"#ccccff")) end
	macro statement_str(s)	:(highlight(Markdown.parse($s),"#ccffcc")) end


    html"""
    <style>
     h1{background-color:#dddddd;  padding: 10px;}
     h2{background-color:#e7e7e7;  padding: 10px;}
     h3{background-color:#eeeeee;  padding: 10px;}
     h4{background-color:#f7f7f7;  padding: 10px;}

	 pluto-log-dot-sizer  { max-width: 655px;}
     pluto-log-dot.Stdout { background: #002000;
	                        color: #10f080;
 	                       }
		main {
		margin: 0 auto;
		max-width: 2000px;
    	padding-left: max(20px, 5%);
    	padding-right: max(20px, 5%);
	}


    </style>
"""
end

# ╔═╡ b4479fb8-e6bf-486e-b791-90eccd0690fe
EL.grid([md"""
- __Clara__ teaches a Julia based course in scientific computing. She prepares the __course material as Pluto notebooks__. After installation with simple instructions, __students run them__ on their computers. The package environment automatically installs all packages necessary. HTML and PDF previews available as well.
- __Students__ prepare their __exam projects as Pluto notebooks__. Clara can receive their work and run it on her computer.
- Leverage this for simple computational projects
""" important"""
Download Julia and install it according to the procedure on you particular operating system. Invoke Julia and issue the following commands:
```
using Pkg
Pkg.add("Pluto")
using Pluto
Pluto.run()
```
A menu will show up in the browser which allows to start a notebook
"""
])

# ╔═╡ 5beb3a0d-e57a-4aea-b7a0-59b8ce9ff5ce
hrule()

# ╔═╡ 6580fee3-8bee-4b7f-8181-5c901d99ac63
function slide_with_pic(text,pic;width=240, source="dreamstudio.ai CC01.0")
EL.grid([text EL.vbox([
Resource("https://www.wias-berlin.de/people/fuhrmann/blobs/$pic",:width=>width),
	htl"""<font size=-5>$source </font>"""
      ])    ])
end;

# ╔═╡ a2c70caf-5435-48c0-8348-d9ca0d4baa88
slide_with_pic(
	md"""
- Combination of  performant core simulation tools, e.g. in C/Fortran/C++ and glueing/postprocessing tools in a scripting language, e.g. Python.
- But ... this at least a __three language problem__:  consider the __build system__ in yet another language, e.g. __CMake__
- Claim: __Each project needs its own guru__ to maintain the build system and to help to compile the code on new machines or to maintain docker containers
- Claim: Python APIs are easy to explain to general users, efficient algorithms are implemented in C/C++. __Python project codebases are intransparent for many of their users__
- Claim: __Containers are the new binaries__

Akin to  an __exponential boundary layer hitting a wall__ regarding the complexity of this. 

Julia tries to provide an alternative.

""",
	"Complicated-machine3.png"
)

# ╔═╡ ee26f2cc-d564-4c65-8d1d-ca612c9b774c
slide_with_pic(
	md"""
- `BinaryBuilder.jl` provides a container like infrastructure to build and maintain __binary packages__ for __all architectures supported by Julia__
   - Leverage of software libraries from the world of compiled languages
   - Mesh generators, numerics packages, GUI toolkits etc.
- [https://github.com/JuliaPackaging/Yggdrasil](https://github.com/JuliaPackaging/Yggdrasil): collection of  ≈ 1400 build scripts for binary packages


""",
	"ygg.png", source="https://github.com/JuliaPackaging/Yggdrasil"
)


# ╔═╡ 40f6918f-9da5-4db4-a586-b320acc5f37b
slide_with_pic(
md"""
Transferring `Project.toml`  allows to share the information on project dependencies along with compat bounds

- __Alice__, working on Linux, creates a project using Julia and __a number of Julia packages__. She develops the code in a directory which is activated as a Julia environment. She sets up a git repository containing source code, documentation and a `Project.toml` file. 
- __Bob__, working on windows,  checks out the code from the repo. A call to `Pkg.instantiate()` __installs all packages__  with the right compat bounds as Alice intended.
- Upon __publishing__, they create a repo branch which in addition contains `Manifest.toml`, allowing for exact reproducibility of their results
""",
"alice+bob.png")

# ╔═╡ c4809a66-3ef7-4879-b60e-f0f6ef6052b4
slide_with_pic(md"""
- Package loading and `using` latency due to JIT precompilation aka "Time to first plot"
   - Currently, the Julia community undertakes dedicated successful efforts towards fixing this problem
- Missing formal interface descriptions
   - Julia alternative to C++20 concepts ? Traits ?
   - Bottom up design process, fear to lose opportunities due to too rigid formalizations
- Resources for keeping infrastructure running
   - Many volunteers are involved at central points
   - Competitivity  depends on package contributions
   - Server infrastructure costs
""", "volunteer-davinci.png")

# ╔═╡ d5d85567-ef7a-42ea-9321-bf5475677394
html"""
<script id=asdf>

    const right = document.querySelector('button.changeslide.next')
    const left = document.querySelector('button.changeslide.prev')

    let fullScreen = false


    const func = (e) => {
        if (e.key == "F10") {
            e.preventDefault()
            window.present()
            if (fullScreen) {
                document.exitFullscreen().then(() => fullScreen = false)
            } else {

                document.documentElement.requestFullscreen().then(() => fullScreen = true)
            }
        }
        if (document.body.classList.contains('presentation')) {

            if (e.target.tagName == "TEXTAREA") return
            if (e.key == "PageUp") {
                e.preventDefault()
                left.click()
                return
         }

            if (e.key == "PageDown") {
                e.preventDefault()
                right.click()
                return
            }
            if (e.key == "Escape") {
                window.present()
                fullScreen = false
document.exitFullscreen().catch(() => {return})
            }
        }
    }

    document.addEventListener('keydown',func)

    invalidation.then(() => {document.removeEventListener('keydown',func)})
</script>
"""

# ╔═╡ c0e96707-d1ca-4163-b400-783b72858abb
pkgdir(AbstractTrees);

# ╔═╡ 4cf88856-f6e0-4167-a92d-07b292560515
showdir(pkgdir(ForwardDiff);maxdepth=1);

# ╔═╡ 74eede08-a6a2-4cf5-8286-f488aaf56537
hsep(px=50)=htl"""<div style="width:$(px)px"/>""";

# ╔═╡ bbcbe33f-bdaa-46c2-9541-eafc0d621ec5
EL.hbox([
htl"""
<div>
<font size=+3><b>
<br>
<br>
The Julia language: Reproducibility infrastructure and project workflows
</b>
<br>
</font>
<br>
<font size=+2>
Jürgen Fuhrmann<br>
WIAS Berlin
</font>
</div>
""",
	hsep(),
	EL.vbox([
            Resource("https://www.wias-berlin.de/layout/images/WIAS_MMS100Px_1,0PxLine.png",:width=>100),
		Resource("https://www.fv-berlin.de/fileadmin/user_upload/Institute/Logos/WIAS/WIAS_ohne.svg",:width=>100),
		Resource("https://www.leibniz-gemeinschaft.de/fileadmin/user_upload/ARCHIV_downloads/ARCHIV_Presse_copy/Leibniz-Logos/Leibniz__Logo_EN_Blue-Black.jpg",:width=>100),

	Resource("https://julialang.org/assets/infra/logo.svg",:width=>100)
	])
])


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AbstractTrees = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
ExtendableGrids = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
GSL = "92c85e6c-cbff-5e0c-80f7-495c94daaecd"
GSL_jll = "1b77fbbe-d8ee-58f0-85f9-836ddc23a7a4"
GridVisualize = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PlutoVista = "646e1f28-b900-46d7-9d87-d554eb38a413"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[compat]
AbstractTrees = "~0.4.5"
ExtendableGrids = "~1.10.2"
ForwardDiff = "~0.10.36"
GSL = "~1.0.1"
GSL_jll = "~2.7.2"
GridVisualize = "~1.8.0"
HypertextLiteral = "~0.9.5"
PlutoUI = "~0.7.60"
PlutoVista = "~1.0.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.4"
manifest_format = "2.0"
project_hash = "12904ab294d8d0868d4e89eb25cd4f87eb77d079"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "d80af0733c99ea80575f612813fa6aa71022d33a"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.1.0"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "d57bd3762d308bded22c3b82d033bff85f6195c6"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.4.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "01b8ccb13d68535d73d2b0c23e39bd23155fb712"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.1.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.Bijections]]
git-tree-sha1 = "d8b0439d2be438a5f2cd68ec158fe08a7b2595b7"
uuid = "e2ed5e7c-b2de-5872-ae92-c73ca462fb04"
version = "0.1.9"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "3e4b134270b372f2ed4d4d0e936aabaefc1802bc"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.25.0"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "bce6804e5e6044c6daab27bb533d1295e4a2e759"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.6"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b5278586822443594ff615963b0c09755771b3e0"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.26.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

[[deps.CommonSubexpressions]]
deps = ["MacroTools"]
git-tree-sha1 = "cda2cfaebb4be89c9084adaca7dd7333369715c5"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.1"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConstructionBase]]
git-tree-sha1 = "76219f1ed5771adbb096743bff43fb5fdd4c1157"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.8"
weakdeps = ["IntervalSets", "LinearAlgebra", "StaticArrays"]

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.ElasticArrays]]
deps = ["Adapt"]
git-tree-sha1 = "75e5697f521c9ab89816d3abeea806dfc5afb967"
uuid = "fdbdab4c-e67f-52f5-8c3f-e7b388dad3d4"
version = "1.2.12"

[[deps.ExtendableGrids]]
deps = ["AbstractTrees", "Bijections", "Compat", "Dates", "DocStringExtensions", "ElasticArrays", "Graphs", "InteractiveUtils", "LinearAlgebra", "Printf", "Random", "SparseArrays", "StaticArrays", "StatsBase", "UUIDs", "WriteVTK"]
git-tree-sha1 = "6c7f0dc5182bb9737b37246b24c437ef66a2fe89"
uuid = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
version = "1.10.2"

    [deps.ExtendableGrids.extensions]
    ExtendableGridsGmshExt = "Gmsh"
    ExtendableGridsMetisExt = "Metis"
    ExtendableGridsTetGenExt = "TetGen"
    ExtendableGridsTriangulateExt = "Triangulate"

    [deps.ExtendableGrids.weakdeps]
    Gmsh = "705231aa-382f-11e9-3f0c-b7cb4346fdeb"
    Metis = "2679e427-3c69-5b7f-982b-ece356f1e94b"
    TetGen = "c5d3f3f7-f850-59f6-8a2e-ffc6dc1317ea"
    Triangulate = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"

[[deps.Extents]]
git-tree-sha1 = "81023caa0021a41712685887db1fc03db26f41f5"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.4"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "6a70198746448456524cb442b8af316927ff3e1a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.13.0"

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

    [deps.FillArrays.weakdeps]
    PDMats = "90014a1f-27ba-587c-ab20-58faa44d9150"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "cf0fe81336da9fb90944683b8c41984b08793dad"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.36"
weakdeps = ["StaticArrays"]

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

[[deps.GSL]]
deps = ["GSL_jll", "Libdl", "Markdown"]
git-tree-sha1 = "3ebd07d519f5ec318d5bc1b4971e2472e14bd1f0"
uuid = "92c85e6c-cbff-5e0c-80f7-495c94daaecd"
version = "1.0.1"

[[deps.GSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "56f1e2c9e083e0bb7cf9a7055c280beb08a924c0"
uuid = "1b77fbbe-d8ee-58f0-85f9-836ddc23a7a4"
version = "2.7.2+0"

[[deps.GeoFormatTypes]]
git-tree-sha1 = "59107c179a586f0fe667024c5eb7033e81333271"
uuid = "68eda718-8dee-11e9-39e7-89f7f65f511f"
version = "0.4.2"

[[deps.GeoInterface]]
deps = ["Extents", "GeoFormatTypes"]
git-tree-sha1 = "2f6fce56cdb8373637a6614e14a5768a88450de2"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.3.7"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "Extents", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "b62f2b2d76cee0d61a2ef2b3118cd2a3215d3134"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.11"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "1dc470db8b1131cfc7fb4c115de89fe391b9e780"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.12.0"

[[deps.GridVisualize]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "ElasticArrays", "ExtendableGrids", "GeometryBasics", "GridVisualizeTools", "HypertextLiteral", "Interpolations", "IntervalSets", "LinearAlgebra", "Observables", "OrderedCollections", "Printf", "StaticArrays"]
git-tree-sha1 = "333fc9dcce2e57836e053f2d8f110f770213d30d"
uuid = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
version = "1.8.0"

    [deps.GridVisualize.weakdeps]
    CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
    GLMakie = "e9467ef8-e4e7-5192-8a1a-b1aee30e663a"
    Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
    PlutoVista = "646e1f28-b900-46d7-9d87-d554eb38a413"
    PyPlot = "d330b81b-6aea-500a-939a-2ce795aea3ee"

[[deps.GridVisualizeTools]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "StaticArraysCore"]
git-tree-sha1 = "e111f256aa000c4e4662d1119281b751aa66dc37"
uuid = "5573ae12-3b76-41d9-b48c-81d0b6e61cc5"
version = "1.1.0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.Inflate]]
git-tree-sha1 = "d1b1b796e47d94588b3757fe84fbf65a5ec4a80d"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "88a101217d7cb38a7b481ccd50d21876e1d1b0e0"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.15.1"

    [deps.Interpolations.extensions]
    InterpolationsUnitfulExt = "Unitful"

    [deps.Interpolations.weakdeps]
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.IntervalSets]]
git-tree-sha1 = "dba9ddf07f77f60450fe5d2e2beb9854d9a49bd0"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.10"

    [deps.IntervalSets.extensions]
    IntervalSetsRandomExt = "Random"
    IntervalSetsRecipesBaseExt = "RecipesBase"
    IntervalSetsStatisticsExt = "Statistics"

    [deps.IntervalSets.weakdeps]
    Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "be3dc50a92e5a386872a493a10050136d4703f9b"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.6.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.LightXML]]
deps = ["Libdl", "XML2_jll"]
git-tree-sha1 = "3a994404d3f6709610701c7dabfc03fed87a81f8"
uuid = "9c8b4983-aa76-5018-a973-4c85ecc9e179"
version = "0.9.1"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "a2d09619db4e765091ee5c6ffe8872849de0feea"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.28"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "7438a59546cf62428fc9d1bc94729146d37a7225"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.5"

[[deps.OffsetArrays]]
git-tree-sha1 = "1a27764e945a152f7ca7efa04de513d473e9542e"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.14.1"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+4"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"

    [deps.Pkg.extensions]
    REPLExt = "REPL"

    [deps.Pkg.weakdeps]
    REPL = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PlutoVista]]
deps = ["AbstractPlutoDingetjes", "ColorSchemes", "Colors", "DocStringExtensions", "GridVisualizeTools", "HypertextLiteral", "UUIDs"]
git-tree-sha1 = "5be7548065d668761814809e2c7ee33310a3d82f"
uuid = "646e1f28-b900-46d7-9d87-d554eb38a413"
version = "1.0.1"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"
version = "1.11.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.11.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "2f5d4697f21388cbe1ff299430dd169ef97d7e14"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.4.0"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "777657803913ffc7e8cc20f0fd04b634f871af8f"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.8"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "5cf7606d6cef84b543b483848d4ae08ad9832b21"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.3"

[[deps.StructArrays]]
deps = ["ConstructionBase", "DataAPI", "Tables"]
git-tree-sha1 = "f4dc295e983502292c4c3f951dbb4e985e35b3be"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.18"

    [deps.StructArrays.extensions]
    StructArraysAdaptExt = "Adapt"
    StructArraysGPUArraysCoreExt = "GPUArraysCore"
    StructArraysSparseArraysExt = "SparseArrays"
    StructArraysStaticArraysExt = "StaticArrays"

    [deps.StructArrays.weakdeps]
    Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.7.0+0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.VTKBase]]
git-tree-sha1 = "c2d0db3ef09f1942d08ea455a9e252594be5f3b6"
uuid = "4004b06d-e244-455f-a6ce-a5f9919cc534"
version = "1.0.1"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c1a7aa6219628fcd757dede0ca95e245c5cd9511"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "1.0.0"

[[deps.WriteVTK]]
deps = ["Base64", "CodecZlib", "FillArrays", "LightXML", "TranscodingStreams", "VTKBase"]
git-tree-sha1 = "1d8042d58334ab7947ce505709df7009da6f3375"
uuid = "64499a7a-5c06-52f2-abe2-ccb03c286192"
version = "1.21.1"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "1165b0443d0eca63ac1e32b8c0eb69ed2f4f8127"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.3+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─a41278ee-e4d8-479a-8167-cfd1fab307bc
# ╟─bbcbe33f-bdaa-46c2-9541-eafc0d621ec5
# ╟─bdb3548c-9ecf-4e50-beef-f226f257f425
# ╟─a2c70caf-5435-48c0-8348-d9ca0d4baa88
# ╟─ea954f05-b245-4c4a-91e7-fc257b3cc8b0
# ╟─cc07ac1a-9266-481f-ab27-61252509eeeb
# ╟─f5decf61-fe75-4760-84f4-7d8eabe417df
# ╟─7c65ed65-8a1c-4658-981c-d9018169f0c3
# ╟─5932287d-3e72-4533-92e2-7e02f0c13015
# ╟─7b4b635d-c600-4d6a-9cef-64bd97eb6a3e
# ╟─ff993ebe-86c2-4f96-9572-426bfd08263e
# ╟─5765c545-9f01-434d-aa5f-61bbbc6ddb7b
# ╟─78d80605-8e36-4714-90da-44bd613c5357
# ╟─2b6bae65-0270-4659-a1ff-2a594b068e72
# ╠═6d5f35a4-5a34-4bba-a2ae-e6fe43ec835e
# ╠═a073d980-63a2-499a-acdd-cbf2a5cb4a9d
# ╟─5cf4cae3-7406-4235-aab7-d0cc25a90a47
# ╠═4084656e-ba52-4359-a73d-e242818e09c9
# ╟─c64e094a-edab-4af1-b9f3-e0221261e3f9
# ╟─d9d57deb-85b1-4842-a71c-5d740603a118
# ╟─ac8ba311-c791-4003-b556-a6d7e4f46042
# ╟─7ae55b24-cb55-46b0-b65f-fb3650ca93cd
# ╟─86590ce4-f14b-4a9f-982f-f89e28939fa8
# ╟─f449284a-3d1b-4e4e-834e-11fca55561bb
# ╟─21364af4-1619-4056-a865-d03831cbf2e9
# ╟─1e624ad2-09c0-49d5-9ba2-ed89035b4861
# ╟─14429a42-d88c-45e0-b0ba-b7980c5f8d3f
# ╟─9fa14fbf-bf42-4d46-a8f0-c17c86108991
# ╟─5207440a-b7ad-4175-b60a-a390e4fcedda
# ╟─bb298b7c-1190-4b28-96c9-c5af6d04ac2d
# ╟─7feb3dae-2ec9-4557-a305-72f5a40f785f
# ╟─90cf770e-45c3-4911-b3cb-90444910e80f
# ╟─4762eb48-b187-4819-a218-77e5678b96b4
# ╟─7802879b-8436-4db6-b7e7-f8eea051cb42
# ╟─89d88a52-61b2-48b1-9d96-c583426d0db7
# ╟─fc0a2152-28d6-452d-bc2d-e4b6c9ef71a5
# ╟─9e7cbb62-757e-41e3-9da7-cde10871375b
# ╠═5707ba63-2798-4c5c-9fb4-4295bce55796
# ╠═0878ff07-3c82-463f-a746-5b9233fdd231
# ╠═4085ce7c-b2e8-4756-af92-6b853f3d9088
# ╠═d6936e7a-d1fe-4a5c-b3e5-2c5c8abdb228
# ╟─28ce3e73-05ac-445d-bab1-4fc338ac37bb
# ╟─ee26f2cc-d564-4c65-8d1d-ca612c9b774c
# ╟─a65a17da-68b2-44e6-81a8-78eea6b46350
# ╟─93acfc47-f5fe-40aa-a16a-6af89e3b86d4
# ╟─5c4ac205-d1b7-4b46-823e-10c63df2f287
# ╟─1903235e-bca1-416a-ba4e-131ba2b8e771
# ╟─82288118-3ade-4a20-8c94-c5de31f65f40
# ╟─d744ef4a-cae6-49ed-bbe1-28145ae405ca
# ╠═786b452a-b7bf-4957-a553-56ecd50b5786
# ╠═21d92b62-104b-45dd-ab5c-ed5e5ab0edb7
# ╠═d9b5c2b0-bcbd-430e-9e51-c89386ec734a
# ╟─9eb53f42-8e82-4450-971e-5d3452662e1f
# ╟─b4479fb8-e6bf-486e-b791-90eccd0690fe
# ╟─bd64d3b8-2056-4372-8964-9128109414c7
# ╟─40f6918f-9da5-4db4-a586-b320acc5f37b
# ╟─0a5e9b36-1a92-4ca3-bf19-48e24b1195da
# ╟─b1b3fc07-ab73-41b7-a22b-02343c26bc4e
# ╟─f83b8d65-0c5b-43af-932a-b6c5529edd83
# ╟─57293128-7711-499e-80fe-68543ef2bf34
# ╟─3c9bf8e5-b14e-4751-a8f2-a8ff89b8c873
# ╟─1d0b17b7-5e9b-4160-aaac-d5bb4db6a139
# ╟─c4809a66-3ef7-4879-b60e-f0f6ef6052b4
# ╟─4271f050-9e79-4031-bfe7-374951ad0fbf
# ╟─6eb68ba7-2e69-4688-829e-688c22f0440d
# ╟─5beb3a0d-e57a-4aea-b7a0-59b8ce9ff5ce
# ╟─60941eaa-1aea-11eb-1277-97b991548781
# ╟─7a93e9a8-8a2d-4b11-84ef-691706c0eb0f
# ╟─6580fee3-8bee-4b7f-8181-5c901d99ac63
# ╟─d5d85567-ef7a-42ea-9321-bf5475677394
# ╟─97989456-9703-4ddb-ab35-d20b300e3ad4
# ╟─c0e96707-d1ca-4163-b400-783b72858abb
# ╟─4cf88856-f6e0-4167-a92d-07b292560515
# ╟─74eede08-a6a2-4cf5-8286-f488aaf56537
# ╟─bf1d7148-90be-436a-a8ce-5d46bd21d8d9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
