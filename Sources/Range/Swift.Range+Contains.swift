public import Property

extension Swift.Range where Bound: Strideable, Bound.Stride: SignedInteger {

    public enum Contains {}

    @inlinable
    public var contains: Property<Contains, Self> {
        Property(self)
    }
}

extension Property {

    @inlinable
    public func callAsFunction<Bound: Strideable, E: Swift.Error>(
        _ predicate: (Bound) throws(E) -> Bool
    ) throws(E) -> Bool
    where
        Bound.Stride: SignedInteger,
        Tag == Swift.Range<Bound>.Contains,
        Base == Swift.Range<Bound>
    {
        var i = base.lowerBound
        while i < base.upperBound {
            if try predicate(i) {
                return true
            }
            i = i.advanced(by: 1)
        }
        return false
    }
}