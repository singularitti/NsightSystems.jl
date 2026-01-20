# See /Applications/NVIDIA Nsight Systems.app/Contents/target-linux-x64/reports/cuda_gpu_sum.py

using Tables: ByRow, columnnames

export CUDA_API,
    CUDA_KERNEL,
    MEMORY_OPER,
    load_summary,
    is_time_consistent,
    check_total_time,
    get_total_time

"CUDA operation categories from the summary data"
@enum Category begin
    CUDA_API
    CUDA_KERNEL
    MEMORY_OPER
end

"Represents a CUDA operation summary with timing statistics"
struct Summary
    "Percentage of total time"
    time_fraction::Float64
    "Total time used by all executions in nanoseconds"
    total_time::Microsecond
    "Number of executions of this object"
    instances::Int64
    "Average execution time in microseconds"
    average_time::Microsecond
    "Median execution time in microseconds"
    median_time::Microsecond
    "Smallest execution time in microseconds"
    min_time::Microsecond
    "Largest execution time in microseconds"
    max_time::Microsecond
    "Standard deviation of execution time in nanoseconds"
    std_dev::Nanosecond
    "Category of the operation"
    category::Category
    "Name of the kernel or operation"
    operation::String
end

parse_percentage(str) = parse(Float64, replace(str, "%" => "")) / 100

function parse_category(str)
    if str == "CUDA_KERNEL"
        return CUDA_KERNEL
    elseif str == "CUDA_API"
        return CUDA_API
    elseif str == "MEMORY_OPER"
        return MEMORY_OPER
    else
        error("Unknown CUDA category: $str")
    end
end

function load_summary(table)
    header = columnnames(table)
    # Check if headers have units in parentheses
    has_units_in_header = any(@. occursin('(', string(header)))
    return map(rows(table)) do element
        if has_units_in_header
            time_fraction = element[1] / 100  # Percentage
            # Extract unit from header if present
            # With units in header, values are plain numbers
            total_time = element[2] * extract_unit(header, "Total Time")  # FIXME: using index is not always safe
            instances = element.Instances
            average_time = element[4] * extract_unit(header, "Avg")
            median_time = element[5] * extract_unit(header, "Med")
            min_time = element[6] * extract_unit(header, "Min")
            max_time = element[7] * extract_unit(header, "Max")
            std_dev = element[8] * extract_unit(header, "StdDev")
        else
            # Without units in header, values have inline units
            time_fraction = parse_percentage(element.Time)
            total_time = _uparse(element.Total_Time)
            instances = element.Instances
            average_time = _uparse(element.Avg)
            median_time = _uparse(element.Med)
            min_time = _uparse(element.Min)
            max_time = _uparse(element.Max)
            std_dev = _uparse(element.StdDev)
        end
        category = parse_category(element.Category)
        operation = element.Operation
        Summary(
            time_fraction,
            total_time,
            instances,
            average_time,
            median_time,
            min_time,
            max_time,
            std_dev,
            category,
            operation,
        )
    end
end

function extract_unit(header, field)
    m = match(Regex("$(field)\\s*\\((.*?)\\)"), header)
    if isnothing(m)
        error("Unit not found in \"$header\": $field")
    end
    return _uparse(m.captures[1])
end

is_time_consistent(summary::Summary) =
    summary.min_time <= summary.median_time <= summary.max_time &&
    summary.min_time <= summary.average_time <= summary.max_time

function check_total_time(summary::Summary, rtol=0.01)
    expected = summary.instances * summary.average_time
    actual = summary.total_time
    diff_ratio = abs((expected - actual) / (actual))
    return diff_ratio <= rtol
end

function get_total_time(summary, category::Category)
    filtered_summary = filter(ByRow(item -> item.category == category), summary)
    total_time = sum(item.total_time for item in filtered_summary)
    return total_time
end
function get_total_time(summary, categories)
    return sum(categories) do category
        filtered_summary = filter(ByRow(item -> item.category == category), summary)
        sum(item.total_time for item in filtered_summary)
    end
end
