using NsightSystems
using Documenter

DocMeta.setdocmeta!(NsightSystems, :DocTestSetup, :(using NsightSystems); recursive=true)

makedocs(;
    modules=[NsightSystems],
    authors="singularitti <singularitti@outlook.com> and contributors",
    sitename="NsightSystems.jl",
    format=Documenter.HTML(;
        canonical="https://singularitti.github.io/NsightSystems.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/singularitti/NsightSystems.jl",
    devbranch="main",
)
