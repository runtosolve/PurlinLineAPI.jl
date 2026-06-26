module PurlinLineAPI

using CSV, DataFrames, PurlinLine, StructTypes, UUIDs

export RunPurlinLine, PurlinLineResult, calculate

# Input payload for a purlin line calculation.
mutable struct RunPurlinLine
  purlin_types::Vector{String}
  purlin_spans::Vector{Float64}
  purlin_size_span_assignment::Vector{Int}
  purlin_laps::Vector{Float64}
  purlin_spacing::Float64
  frame_flange_width::Float64
  roof_slope::Float64
  deck_type::String
  loading_direction::String
  generate_report::Bool

  RunPurlinLine() = new()
end

# Result of a purlin line calculation.
mutable struct PurlinLineResult
  applied_pressure::Float64
  failure_limit_state::String
  failure_location::Float64
  input_z::Vector{Float64}
  output_v::Vector{Float64}
  report_id::String

  PurlinLineResult() = new()
end

# Register the structs with StructTypes so consumers (e.g. Oxygen.jl) can
# deserialize requests into RunPurlinLine and serialize PurlinLineResult.
StructTypes.StructType(::Type{RunPurlinLine}) = StructTypes.Mutable()
StructTypes.StructType(::Type{PurlinLineResult}) = StructTypes.Mutable()

const purlin_data_path = joinpath(pkgdir(PurlinLine), "database", "Purlins.csv")
const deck_data_path = joinpath(pkgdir(PurlinLine), "database", "Existing_Deck.csv")
const purlin_data = CSV.read(purlin_data_path, DataFrame)
const deck_data = CSV.read(deck_data_path, DataFrame)

"""
    calculate(data::RunPurlinLine) -> PurlinLineResult

Run the purlin line analysis for the given input and return the result.
"""
function calculate(data::RunPurlinLine)::PurlinLineResult
  analysisResult = PurlinLine.UI.calculate_response(
    data.purlin_spans,
    data.purlin_laps,
    data.purlin_spacing,
    data.roof_slope,
    purlin_data,
    data.deck_type,
    deck_data,
    data.frame_flange_width,
    data.purlin_types,
    data.purlin_size_span_assignment,
    data.loading_direction,
  )

  output = PurlinLineResult()
  output.applied_pressure = analysisResult.applied_pressure
  output.failure_limit_state = analysisResult.failure_limit_state
  output.failure_location = analysisResult.failure_location
  output.input_z = analysisResult.model.inputs.z
  output.output_v = analysisResult.model.outputs.v

  if data.generate_report
    output.report_id = string(uuid4()) # replace with actual report generation function
  else
    output.report_id = ""
  end

  return output
end

end # module PurlinLineAPI
