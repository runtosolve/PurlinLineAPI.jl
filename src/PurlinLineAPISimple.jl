module PurlinLineAPISimple

using HTTP, JSON3, Sockets, StructTypes
using Pkg, CSV, DataFrames, PurlinLine


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
  max_load::Float64
  failure_location::Float64

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
  output.max_load = analysisResult.applied_pressure
  output.failure_location = analysisResult.failure_location

  return output

end


# Define CORS headers
const CORS_OPT_HEADERS = [
  "Access-Control-Allow-Origin" => "*",
  "Access-Control-Allow-Headers" => "*",
  "Access-Control-Allow-Methods" => "GET, POST, OPTIONS",
]

const CORS_RES_HEADERS = [
  "Access-Control-Allow-Origin" => "*",
]

function CorsMiddleware(handler)

  return function(req::HTTP.Request)
    if HTTP.method(req) == "OPTIONS"
      return HTTP.Response(200, CORS_OPT_HEADERS)
    else
      return handler(req)
    end
  end
  
end


# Define API handlers
function submitJob(req::HTTP.Request)
  data = JSON3.read(req.body, PurlinLineData)

  output = runAnalysis(data)

  res = HTTP.Response(200, CORS_RES_HEADERS, JSON3.write(output))

  return res
end

# Define routers
const router = HTTP.Router()
HTTP.register!(router, "POST", "/api/create_job", submitJob)

function runServer()
  return HTTP.serve!(router |> CorsMiddleware, Sockets.localhost, 8080)
end


end # PurlinLineAPISimple
