deps_unreg = [
  "https://github.com/runtosolve/LinesCurvesNodes.jl.git",  # LinesCurvesNodes
  "https://github.com/runtosolve/InternalForces.jl.git",  # InternalForces
  "https://github.com/runtosolve/FornbergFiniteDiff.jl.git",  # FornbergFiniteDiff
  "https://github.com/runtosolve/AISIS100.jl.git",  # AISIS100
  "https://github.com/runtosolve/CUFSM.jl.git",  # CUFUSM
  "https://github.com/runtosolve/CrossSection.jl.git",  # CrossSection
  "https://github.com/runtosolve/ScrewConnections.jl.git",  # ScrewConnections
  "https://github.com/runtosolve/ThinWalledBeam.jl.git",  # ThinWalledBeam
  "https://github.com/runtosolve/ThinWalledBeamColumn.jl.git",  # ThinWalledBeamColumn
  "https://github.com/runtosolve/PurlinLine.jl.git",   # PurlinLine
]

dep_reg= [
  "CSV",
  "DataFrames",
  "HTTP",
  "JSON3",
  "Sockets",
  "StructTypes",
  "URIs"
]

using Pkg

for path in deps_unreg
  Pkg.add(url=path, rev="main")
end

for name in dep_reg
  Pkg.add(name)
end