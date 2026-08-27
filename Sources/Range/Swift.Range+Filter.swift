public import Property

extension Swift.Range where Bound: Strideable, Bound.Stride: SignedInteger {

    public enum Filter {}

    @inlinable
    public var filter: Property<Filter, Self> {
        Property(self)
    }
}

extension Property {

    @inlinable
    public func callAsFunction<Bound: Strideable, E: Swift.Error>(
        _ isIncluded: (Bound) throws(E) -> Bool
    ) throws(E) -> [Bound]
    where
        Bound.Stride: SignedInteger,
        Tag == Swift.Range<Bound>.Filter,
        Base == Swift.Range<Bound>
    {
        var result: [Bound] = []
        var i = base.lowerBound
        while i < base.upperBound {
            if try isIncluded(i) {
                result.append(i)
            }
            i = i.advanced(by: 1)
        }
        return result
    }
}