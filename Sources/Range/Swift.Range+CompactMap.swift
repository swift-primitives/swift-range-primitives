public import Property

extension Swift.Range where Bound: Strideable, Bound.Stride: SignedInteger {

    public enum CompactMap {}

    @inlinable
    public var compactMap: Property<CompactMap, Self> {
        Property(self)
    }
}

extension Property {

    @inlinable
    public func callAsFunction<Bound: Strideable, T, E: Swift.Error>(
        _ transform: (Bound) throws(E) -> T?
    ) throws(E) -> [T]
    where
        Bound.Stride: SignedInteger,
        Tag == Swift.Range<Bound>.CompactMap,
        Base == Swift.Range<Bound>
    {
        var result: [T] = []
        var i = base.lowerBound
        while i < base.upperBound {
            if let mapped = try transform(i) {
                result.append(mapped)
            }
            i = i.advanced(by: 1)
        }
        return result
    }
}