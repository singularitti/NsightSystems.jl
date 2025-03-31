module Recipes

using CSV: CSV
using StructArrays: StructArray
using Unitful: Quantity, dimension, uparse, ms, μs

export end_time, load_trace_csv

Millisecond = Quantity{Float64,dimension(ms),typeof(ms)}
Microsecond = Quantity{Float64,dimension(μs),typeof(μs)}

include("cuda_gpu_trace.jl")
include("show.jl")

end
