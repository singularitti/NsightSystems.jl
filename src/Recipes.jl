module Recipes

using CSV: CSV
using DataFrames: DataFrame, nrow
using StructArrays: StructArray
using Unitful: Quantity, dimension, uparse, ms, μs

export end_time, load_trace_csv

Millisecond = Quantity{Float64,dimension(ms),typeof(ms)}
Microsecond = Quantity{Float64,dimension(μs),typeof(μs)}

"Represents a CUDA trace event with timing, resource, and execution details"
struct TraceEvent
    "Start time of trace event in milliseconds"
    start_time::Millisecond
    "Length of event in microseconds"
    duration::Microsecond
    "Correlation ID"
    correlation_id::Int
    "Grid X value"
    grid_x::Union{Int,Missing}
    "Grid Y value"
    grid_y::Union{Int,Missing}
    "Grid Z value"
    grid_z::Union{Int,Missing}
    "Block X value"
    block_x::Union{Int,Missing}
    "Block Y value"
    block_y::Union{Int,Missing}
    "Block Z value"
    block_z::Union{Int,Missing}
    "Registers per thread"
    registers_per_thread::Union{Int,Missing}
    "Size of static shared memory"
    static_shared_memory::Union{String,Missing}
    "Size of dynamic shared memory"
    dynamic_shared_memory::Union{String,Missing}
    "Size of memory operation"
    bytes::Union{String,Missing}
    "Throughput in MB per Second"
    throughput::Union{String,Missing}
    "Memcpy source memory kind or memset memory kind"
    source_memory_kind::Union{String,Missing}
    "Memcpy destination memory kind"
    destination_memory_kind::Union{String,Missing}
    "GPU device name and ID"
    device::String
    "Context ID"
    context_id::Int
    "Green context ID"
    green_context::Union{String,Missing}
    "Stream ID"
    stream_id::Int
    "Trace event name"
    name::String
end

end_time(trace) = trace.start_time + trace.duration

_uparse(str) = uparse(replace(str, " " => ""))

function load_trace_csv(filepath)
    df = CSV.read(filepath, DataFrame; missingstring="-")
    return map(eachrow(df)) do row
        start_ms = _uparse(row.Start)
        duration_μs = _uparse(row.Duration)
        corr_id = row.CorrId
        grid_x = row.GrdX
        grid_y = row.GrdY
        grid_z = row.GrdZ
        block_x = row.BlkX
        block_y = row.BlkY
        block_z = row.BlkZ
        reg_per_trd = row["Reg/Trd"]
        stc_smem = row.StcSMem
        dym_smem = row.DymSMem
        bytes = row.Bytes
        throughput = row.Throughput
        src_mem_kd = row.SrcMemKd
        dst_mem_kd = row.DstMemKd
        device = string(row.Device)
        ctx = parse(Int, string(row.Ctx))
        green_ctx = row.GreenCtx
        strm = parse(Int, string(row.Strm))
        name = string(row.Name)
        TraceEvent(
            start_ms,
            duration_μs,
            corr_id,
            grid_x,
            grid_y,
            grid_z,
            block_x,
            block_y,
            block_z,
            reg_per_trd,
            stc_smem,
            dym_smem,
            bytes,
            throughput,
            src_mem_kd,
            dst_mem_kd,
            device,
            ctx,
            green_ctx,
            strm,
            name,
        )
    end
end

end
