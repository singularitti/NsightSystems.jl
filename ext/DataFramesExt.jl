module DataFramesExt

using DataFrames: DataFrame
using Tables: rows

import NsightSystems.Recipes: load_trace, load_summary

load_trace(data::DataFrame) = DataFrame(load_trace(rows(data)))

load_summary(data::DataFrame) = DataFrame(load_summary(rows(data)))

end
