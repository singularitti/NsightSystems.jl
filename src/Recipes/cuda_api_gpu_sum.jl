export load_summary_csv, is_time_consistent, check_total_time

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

function load_summary_csv(filepath)
    vector = CSV.read(
        filepath, StructArray; header=1, normalizenames=true, missingstring="-"
    )
    return map(vector) do element
        time_fraction = parse_percentage(element.Time)
        total_time = _uparse(element.Total_Time)
        instances = element.Instances
        average_time = _uparse(element.Avg)
        median_time = _uparse(element.Med)
        min_time = _uparse(element.Min)
        max_time = _uparse(element.Max)
        std_dev = _uparse(element.StdDev)
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

is_time_consistent(summary::Summary) =
    summary.min_time <= summary.median_time <= summary.max_time &&
    summary.min_time <= summary.average_time <= summary.max_time

function check_total_time(summary::Summary, rtol=0.01)
    expected = summary.instances * summary.average_time
    actual = summary.total_time
    diff_ratio = abs((expected - actual) / (actual))
    return diff_ratio <= rtol
end
