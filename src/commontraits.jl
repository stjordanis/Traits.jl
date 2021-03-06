# Some rough definitions of some common traits/interfaces of the
# standard library.  Note that most are single parameter traits.

export Eq, Cmp, IsIterable, IsCollection, IsIterColl, IsIndexable, IsAssociative, Arith

@traitdef Eq{X,Y} begin
    # note anything is part of Eq as ==(::Any,::Any) is defined
    ==(X,Y) -> Bool
end

@traitdef Cmp{X,Y} <: Eq{X,Y} begin
    isless(X,Y) -> Bool
    # automatically provides:
    # >, <, >=, <=
end

@traitdef IsIterable{X}  begin
    # type-functions based on return_type:
    State = Base.return_types(start, (X,))[1]
    Item =  Base.return_types(next, (X,State))[1][1] # use eltype instead
    
    # interface functions
    start(X) -> State
    next(X, State) -> Item, State
    done(X, State) -> Bool
    # automatically provides:
    # zip, enumerated, in, map, reduce, ...
end

# general collections
@traitdef IsCollection{X} <: IsIterable{X} begin
    El = eltype(X)
    
    isempty(X) -> Bool
    length(X) -> Integer
    eltype(X) -> Type{El}
    eltype(Type{X}) -> Type{El}
end

@traitdef IsIterColl{X} <: IsCollection{X} begin # iterable collection
    empty!(X) # -> X # ToDo: fix after updating return types
end

@traitdef IsIndexable{X} <:IsCollection{X} begin
    El = eltype(X) # note, for Associative this would be a tuple, which is wrong: see base_fixes.jl
    I = indextype(X)
    
    getindex(X, I) -> El
    setindex!(X, El, I)
    
    length(X) -> Integer
    # automatically provided:
    # size(X) -> Tuple
    # size(X,Integer) -> Integer
end

@traitdef IsAssociative{X} <: IsIndexable{X} begin
    V = eltype(X)
    K = indextype(X)

    # note, ObjectId dict is not part of this interface
    haskey(X, Any)
    get(X, Any, Any)
    get(Function, X, Any)
    get!(X, Any, Any)
    get!(Function, X, Any)
    getkey(X, Any, Any)
    delete!(X, Any) -> X
    pop!(X, Any)
    pop!(X, Any, Any)
    # merge(X, Any...) -> X
    # merge!(X, Any...)
    # provieds
    # keys(X) -> Base.KeyIterator
    # values(X) -> Base.ValueIterator
end

@traitdef Arith{X,Y} begin
    Z = promote_type(X,Y)
    D = Tuple{X,Y}<:Tuple{Integer, Integer} ? Float64 : Z

     # note, promote_type is defined for (Type{Any},Type{Any}), so no
     # need to include it here:
    +(X,Y) -> Z
    -(X,Y) -> Z
    *(X,Y) -> Z
    /(X,Y) -> D
end

