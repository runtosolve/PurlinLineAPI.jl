module PurlinLineAPISimple

using HTTP, JSON3, Sockets, StructTypes

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

StructTypes.StructType(::Type{PurlinLineData}) = StructTypes.Mutable()

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
  res = HTTP.Response(200, CORS_RES_HEADERS, JSON3.write(data))

  return res
end

# Define routers
const router = HTTP.Router()
HTTP.register!(router, "POST", "/api/create_job", submitJob)

function runServer()
  return HTTP.serve!(router |> CorsMiddleware, Sockets.localhost, 8080)
end


end # PurlinLineAPISimple

using CSV, DataFrames

purlin_data = CSV.read("/Users/crismoen/.julia/dev/PurlinLine/database/Purlins.csv", DataFrame);

deck_data = CSV.read("/Users/crismoen/.julia/dev/PurlinLine/database/Existing_Deck.csv", DataFrame);


using PurlinLine


purlin_types = ["Z8x2.5 060"]

purlin_spans = tuple(ones(Float64, 4) .* 25.0...)  #ft

purlin_size_span_assignment = tuple(ones(Int, 8)...)

purlin_laps = tuple(ones(Float64, 3*2) .* 18.0/12...)

purlin_spacing = 5.0  #ft

frame_flange_width = 6.0  #in

roof_slope = 1.0/12

deck_type = "SSR Ultra-Dek 18 in. 24 ga";

purlin_line_gravity = PurlinLine.UI.calculate_response(purlin_spans, purlin_laps, purlin_spacing, roof_slope, purlin_data, deck_type, deck_data, frame_flange_width, purlin_types, purlin_size_span_assignment);

