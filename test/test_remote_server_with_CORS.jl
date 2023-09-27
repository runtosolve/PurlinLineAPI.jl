using PurlinLine, URIs, HTTP, JSON3 

#inputs
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

#package up inputs 
inputs = PurlinLine.Inputs(loading_direction, design_code, segments, spacing, roof_slope, cross_section_dimensions, material_properties, deck_details, deck_material_properties, frame_flange_width, support_locations, purlin_frame_connections, bridging_locations)

#convert inputs to JSON
inputs_json = JSON3.write(inputs)

#send JSON to VM serice, run simulated test of purlin line to failure
url = URI(scheme="https", host="purlinline.runtosolve.com", port="443", path="/api/purlinline")
resp = HTTP.post(url, require_ssl_verification=false, [], inputs_json)

#translate response as solution output, get test results  
output = JSON3.read(resp.body)
