extension Swift.Range where Bound: Strideable, Bound.Stride: SignedInteger {

    public enum First {}

    @inlinable
    public var first: Property<First, Self> {
        Property(self)
    }
}

extension Property {

    @inlinable
    public func callAsFunction<Bound: Strideable, E: Swift.Error>(
        _ predicate: (Bound) throws(E) -> Bool
    ) throws(E) -> Bound?
    where
        Bound.Stride: SignedInteger,
        Tag == Swift.Range<Bound>.First,
        Base == Swift.Range<Bound>
    {
        var i = base.lowerBound
        while i < base.upperBound {
            if try predicate(i) {
                return i
            }
            i = i.advanced(by: 1)
        }
        return nil
    }
}
