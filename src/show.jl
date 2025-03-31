function Base.show(io::IO, ::MIME"text/plain", obj::TraceEvent)
    summary(io, obj)
    println(io)
    for name in propertynames(obj)
        println(io, "  ", name, ": ", getfield(obj, name))
    end
    return nothing
end
