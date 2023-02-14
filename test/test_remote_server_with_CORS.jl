using PurlinLine, URIs, HTTP, JSON3 


loading_direction = "gravity"
design_code = "AISI S100-16 ASD"
segments = [(25.0*12, 25.0, 1, 1)]
spacing = 60;  #in.
roof_slope = 0.0;   #degrees
cross_section_dimensions = [("Z", 0.059, 0.91, 2.5, 8.0, 2.5, 0.91, -55.0, 0.0, 90.0, 0.0, -55.0, 3*0.059, 3*0.059, 3*0.059, 3*0.059)]
material_properties = [(29500.0, 0.30, 55.0, 70.0)]
deck_details = ("vertical leg standing seam", 18.0)
deck_material_properties = (29500.0, 0.30, 55.0, 70.0)
frame_flange_width = 10.0
support_locations = [0.0, 25.0*12]
purlin_frame_connections = "bottom flange connection"
bridging_locations =[ ]

# using Pkg 
# Pkg.add(url="https://github.com/runtosolve/AISIS100.jl.git")
# Pkg.add(url="https://github.com/runtosolve/LinesCurvesNodes.jl.git")
# Pkg.add(url="https://github.com/runtosolve/CUFSM.jl.git")
# Pkg.add(url="https://github.com/runtosolve/CrossSection.jl.git")
# Pkg.add(url="https://github.com/runtosolve/ThinWalledBeam.jl.git")
# Pkg.add(url="https://github.com/runtosolve/ThinWalledBeamColumn.jl.git")
# Pkg.add(url="https://github.com/runtosolve/InternalForces.jl.git")
# Pkg.add(url="https://github.com/runtosolve/ScrewConnections.jl.git")
# Pkg.add(url="https://github.com/runtosolve/PurlinLine.jl.git")


inputs = PurlinLine.Inputs(loading_direction, design_code, segments, spacing, roof_slope, cross_section_dimensions, material_properties, deck_details, deck_material_properties, frame_flange_width, support_locations, purlin_frame_connections, bridging_locations)
inputs_json = JSON3.write(inputs)


url = URI(scheme="http", host="157.245.87.161", port="8080", path="/api/purlin_line")

resp = HTTP.post(url, [], inputs_json)


