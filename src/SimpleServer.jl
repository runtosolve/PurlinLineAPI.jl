module SimpleServer

using HTTP, JSON3, Sockets, StructTypes
using Pkg, CSV, DataFrames, PurlinLine

const CORS_OPT_HEADERS = [
    "Access-Control-Allow-Origin" => "https://www.runtosolve.com",
    "Access-Control-Allow-Methods" => "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers" => "*", # without credentials needed
]
const CORS_RES_HEADERS = ["Access-Control-Allow-Origin" => "https://www.runtosolve.com"]

# Define input struct
mutable struct PurlinLineData
  purlin_types::Vector{String}
  purlin_spans::Vector{Float64}
  purlin_size_span_assignment::Vector{Int}
  purlin_laps::Vector{Float64}
  purlin_spacing::Float64
  frame_flange_width::Float64
  roof_slope::Float64
  deck_type::String

  PurlinLineData() = new()

end

mutable struct PurlinLineOutput
  applied_pressure::Float64
  failure_limit_state::String
  failure_location::Float64
  input_z::Vector{Float64}
  output_v::Vector{Float64}

  PurlinLineOutput() = new()
end

StructTypes.StructType(::Type{PurlinLineData}) = StructTypes.Mutable()

purlin_data_path = joinpath(pkgdir(PurlinLine), "database", "Purlins.csv")
deck_data_path = joinpath(pkgdir(PurlinLine), "database", "Existing_Deck.csv")
purlin_data = CSV.read(purlin_data_path, DataFrame);
deck_data = CSV.read(deck_data_path, DataFrame);

function runAnalysis(data::PurlinLineData)
  purlin_types = data.purlin_types
  purlin_spans = data.purlin_spans  #ft
  purlin_size_span_assignment = data.purlin_size_span_assignment
  purlin_laps = data.purlin_laps
  purlin_spacing = data.purlin_spacing
  frame_flange_width = data.frame_flange_width
  roof_slope = data.roof_slope
  deck_type = data.deck_type
  
  analysisResult = PurlinLine.UI.calculate_response(purlin_spans, purlin_laps, purlin_spacing, roof_slope, purlin_data, deck_type, deck_data, frame_flange_width, purlin_types, purlin_size_span_assignment);
  
  output = PurlinLineOutput()
  output.applied_pressure = analysisResult.applied_pressure
  output.failure_limit_state = analysisResult.failure_limit_state
  output.failure_location = analysisResult.failure_location
  output.input_z = analysisResult.model.inputs.z
  output.output_v = analysisResult.model.outputs.v

  return output

end

function CorsMiddleware(handler)
  return function(req::HTTP.Request)
    if HTTP.method(req) == "OPTIONS"
      return HTTP.Response(200, CORS_OPT_HEADERS)
    else
      return handler(req)
    end
  end
  
end

function getMessage(req::HTTP.Request)
  msg = Dict([("id", "xyzabc"), ("value", "success")])
  return HTTP.Response(200, CORS_RES_HEADERS, JSON3.write(msg))
end

function submitJob(req::HTTP.Request)
  data = JSON3.read(req.body, PurlinLineData)
  output = runAnalysis(data)
  return HTTP.Response(200, CORS_RES_HEADERS, JSON3.write(output))
end

function testPost(req::HTTP.Request)
  data = JSON3.read(req.body)
  return HTTP.Response(200, CORS_RES_HEADERS, JSON3.write(data))
end

const router = HTTP.Router()
HTTP.register!(router, "GET", "/api/msg", getMessage)
HTTP.register!(router, "POST", "/api/submit_job", submitJob)
HTTP.register!(router, "POST", "/api/test_post", testPost)

function serve()
  server = HTTP.serve!(router |> CorsMiddleware, Sockets.localhost, 8080)
  return server
end

end # module SimpleServer

server = SimpleServer.serve()