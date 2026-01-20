module Recipes

using CSV: CSV
using StructArrays: StructArray
using Unitful: Quantity, dimension, uparse, ms, μs, ns

Millisecond = Quantity{Float64,dimension(ms),typeof(ms)}
Microsecond = Quantity{Float64,dimension(μs),typeof(μs)}
Nanosecond = Quantity{Float64,dimension(ns),typeof(ns)}

_uparse(str) = uparse(replace(str, " " => ""))

include("cuda_gpu_trace.jl")
include("cuda_gpu_sum.jl")
include("show.jl")

end
