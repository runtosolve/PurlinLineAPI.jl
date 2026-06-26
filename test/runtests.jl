import PurlinLineAPI

data = PurlinLineAPI.RunPurlinLine()
data.purlin_types = ["Z8x2.5 060"]
data.purlin_spans = [
  16,
  20
]
data.purlin_size_span_assignment = [
  1,
  1,
  1,
  1
]
data.purlin_laps = [
  4,
  4
]
data.purlin_spacing = 5
data.frame_flange_width = 6
data.roof_slope = 0.08333333333333333
data.deck_type = "SSR Ultra-Dek 18 in. 24 ga"
data.loading_direction = "uplift"
data.generate_report = false

PurlinLineAPI.calculate(data)
