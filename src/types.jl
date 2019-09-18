abstract type AbstractPixel end

"""
    Pixel{CT<:Colorant} <: AbstractPixel

A pixel holds both color and spatial information.

Use [`color`](@ref) and [`position`](@ref) to get the color
and spatial information of `Pixel`.
"""
struct Pixel{CT<:Colorant} <: AbstractPixel
    color::CT
    pos::CartesianIndex
end
Pixel(gray::Number, pos) = Pixel(Gray(gray), pos)
Pixel(color::Colorant, pos::Tuple) = Pixel(color, CartesianIndex(pos))

color(p::Pixel) = p.color
position(p::Pixel) = p.pos

"""
    SuperPixel{T<:AbstractPixel, N} = AbstractArray{T, N}

A super pixel is a collection of [`Pixel`](@ref)s, where each pixel holds
both color and spatial information.
"""
const SuperPixel{T<:AbstractPixel, N} = AbstractArray{T, N}

"""
    SuperPixelImage{T<:SuperPixel, N} = AbstractArray{T, N}

A super pixel image is a collection of super pixels [`SuperPixel`](@ref).
"""
const SuperPixelImage{T<:SuperPixel, N} = AbstractArray{T, N}

PixelCollection = Union{SuperPixel, SuperPixelImage}

color_type(sp::Union{Pixel, PixelCollection}) = color_type(typeof(sp))
color_type(::Type{Pixel{CT}}) where CT<:Colorant = CT
color_type(::Type{T}) where T <: SuperPixel = color_type(eltype(T))
color_type(::Type{T}) where T<:SuperPixelImage = color_type(eltype(T))


# see issue: https://github.com/JuliaLang/julia/issues/33274
function Base.intersect(s::SuperPixel, itrs...)
    if isempty(itrs)
        return s
    else
        o = first(itrs)
        idx = intersect(position.(s), position.(o))
        return intersect(s[idx], itrs[2:end]...)
    end
end

"""
    image_size(img)

Returns the size of potential image represented by [`SuperPixel`](@ref).
"""
function image_size(img::SuperPixelImage)
    R = position.(Iterators.flatten(img))
    I_first, I_last = extrema(R)
    return I_last.I .- I_first.I .+ (1, 1)
end
image_size(img::GenericImage) = size(img)
