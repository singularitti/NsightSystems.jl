export end_time, load_trace_csv

"Represents a CUDA trace event with timing, resource, and execution details"
struct TraceEvent
    "Start time of trace event in milliseconds"
    start_time::Millisecond
    "Length of event in microseconds"
    duration::Microsecond
    "Correlation ID"
    correlation_id::Int64
    "Grid X value"
    grid_x::Union{Int64,Missing}
    "Grid Y value"
    grid_y::Union{Int64,Missing}
    "Grid Z value"
    grid_z::Union{Int64,Missing}
    "Block X value"
    block_x::Union{Int64,Missing}
    "Block Y value"
    block_y::Union{Int64,Missing}
    "Block Z value"
    block_z::Union{Int64,Missing}
    "Registers per thread"
    registers_per_thread::Union{Int64,Missing}
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
    context_id::Int64
    "Green context ID"
    green_context::Union{String,Missing}
    "Stream ID"
    stream_id::Int64
    "Trace event name"
    operation::String
end

end_time(trace) = trace.start_time + trace.duration

function load_trace_csv(filepath)
    vector = CSV.read(
        filepath, StructArray; header=1, normalizenames=true, missingstring="-"
    )
    return map(vector) do element
        start_ms = _uparse(element.Start)
        duration_μs = _uparse(element.Duration)
        corr_id = element.CorrId
        grid_x = element.GrdX
        grid_y = element.GrdY
        grid_z = element.GrdZ
        block_x = element.BlkX
        block_y = element.BlkY
        block_z = element.BlkZ
        reg_per_trd = element.Reg_Trd  # The name has been normalized into a valid Julia identifier symbol
        stc_smem = element.StcSMem
        dym_smem = element.DymSMem
        bytes = element.Bytes
        throughput = element.Throughput
        src_mem_kd = element.SrcMemKd
        dst_mem_kd = element.DstMemKd
        device = element.Device
        ctx = element.Ctx
        green_ctx = element.GreenCtx
        strm = element.Strm
        operation = element.Name
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
            operation,
        )
    end
end
