module DynamicQuantitiesLatexifyExt
  using DynamicQuantities, Latexify, LaTeXStrings

  function dimension_fullname(d::T,k::Symbol) where {T<:AbstractDimensions}
    SIbase_fullnames = (length="meter", mass="kilogram", time="second", S="second", current="ampere", temperature="kelvin", luminosity="candela", amount="mol")
    SIderived_fullnames = ( Bq="becquerel", °C="degreeCelcius", C="coulomb", F="fard", Gy="gray", Hz="hertz", H="henry", J="joule", lm="lumen", kat="katal", lx="lux", N="newton", Ω="ohm")
    nonSI_fullnames = ( B="bel", Da="dalton", d="day", dB="decibel", °="degree", eV="electronvolt", ha="hectare", h="hour", L="liter", arcmin="arcminute", min="minute", arcsec="arcsecond", Np="neper", t="tonne", hbar="planckbar")
    dim_fullnames = merge(SIbase_fullnames,SIderived_fullnames,nonSI_fullnames)
    nicknames = ( μS = "micro\\second" , kJ = "kilo\\joule", nΩ = "nano\\ohm")
    a = get(dim_fullnames, k, string(k))
    b = get(nicknames, k, string(k))
    if a ∈ dim_fullnames
      return a
    elseif b ∈ nicknames
      return b
    else
      error("Cannot render unit using :siunitx for non-SI units.")
    end
end

  function dims(d, mode = :mathrm)
    s = "";
    dim2latex = mode == :mathrm ?
          (d,k) -> "\\mathrm{$(DynamicQuantities.dimension_name(d,k))}" :
          (d,k) -> "\\$(dimension_fullname(d,k))"
    exp2latex = mode == :mathrm ?
          (d,k) -> "^{$(d[k])}" :
          (d,k) -> "\\tothe{$(d[k])}"
    unitjoin = mode == :mathrm ? "\\," : ""
    for k in filter(k -> !iszero(d[k]), keys(d))
      tmp_io = IOBuffer()
      print(tmp_io, dim2latex(d,k))
      isone(d[k]) || print(tmp_io, exp2latex(d,k))
      print(tmp_io, unitjoin)
      s = s * String(take!(tmp_io))
    end
    s
  end

  @latexrecipe function f(q::T; unitformat = :mathrm) where {T<:AbstractQuantity}
    if unitformat == :mathrm
      return Expr(:latexifymerge, ustrip(q), "\\;", dimension(q))
    end
    return Expr(:latexifymerge, "\\qty{" , ustrip(q) , "}{", dimension(q) ,"}" )
  end


  @latexrecipe function f(d::T; unitformat = :mathrm) where {T<:AbstractDimensions}
    return LaTeXString(dims(d,unitformat))
  end

end # DynamicQuantitiesLatexifyExt
