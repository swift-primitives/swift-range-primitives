extension Swift.Range where Bound: Strideable, Bound.Stride: SignedInteger {

    public enum Reduce {}

    @inlinable
    public var reduce: Property<Reduce, Self> {
        Property(self)
    }
}

extension Property {

    @inlinable
    public func callAsFunction<Bound: Strideable, R, E: Swift.Error>(
        _ initialResult: R,
        _ combine: (R, Bound) throws(E) -> R
    ) throws(E) -> R
    where
        Bound.Stride: SignedInteger,
        Tag == Swift.Range<Bound>.Reduce,
        Base == Swift.Range<Bound>
    {
        var accumulator = initialResult
        var i = base.lowerBound
        while i < base.upperBound {
            accumulator = try combine(accumulator, i)
            i = i.advanced(by: 1)
        }
        return accumulator
    }
}
