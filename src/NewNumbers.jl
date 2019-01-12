Base.:(==)(x::A, y::B) where {A<:Symbolic,B<:Symbolic} = false
Base.promote(x::A, y::B) where {A<:Symbolic,B<:Symbolic} =
    (SymExpr(:identity, [x]), SymExpr(:identity, [y]))

macro new_number(type_name, comp_params, compare)
    Base_isequal = Expr(:call, Expr(Symbol("."), :Base, :(:(==))))
    signature,args = if comp_params.head == :where
        Expr(:where, Base_isequal, comp_params.args[2:end]...),comp_params.args[1].args
    else
        Base_isequal,comp_params.args
    end
    append!(Base_isequal.args, args)
    def = Expr(:(=), signature, compare)

    quote
        Base.:(==)(x::$(esc(type_name)), y::N) where {N<:Union{Real,Complex}} = false
        Base.:(==)(x::N, y::$(esc(type_name))) where {N<:Union{Real,Complex}} = false
        Base.:(==)(x::$(esc(type_name)), y::Sym) = false
        Base.:(==)(x::Sym, y::$(esc(type_name))) = false
        Base.:(==)(x::$(esc(type_name)), y::SymExpr) = false
        Base.:(==)(x::SymExpr, y::$(esc(type_name))) = false

        Base.promote(::Type{<:$(esc(type_name))}) = SymExpr

        Base.promote(x::TT, y::SymExpr) where {TT<:$(esc(type_name))} =
            (SymExpr(:identity, [x]), y)
        Base.promote(x::SymExpr, y::TT) where {TT<:$(esc(type_name))} =
            (x, SymExpr(:identity, [y]))

        $(esc(def))
    end
end
