public import Property

extension Swift.Range where Bound: Strideable, Bound.Stride: SignedInteger {

    public enum ForEach {}

    @inlinable
    public var forEach: Property<ForEach, Self> {
        Property(self)
    }
}

extension Property {

    @inlinable
    public func callAsFunction<Bound: Strideable, E: Swift.Error>(
        _ body: (Bound) throws(E) -> Void
    ) throws(E)
    where
        Bound.Stride: SignedInteger,
        Tag == Swift.Range<Bound>.ForEach,
        Base == Swift.Range<Bound>
    {
        var i = base.lowerBound
        while i < base.upperBound {
            try body(i)
            i = i.advanced(by: 1)
        }
    }
}