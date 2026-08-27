public import Property

extension Swift.Range {

    public enum Map {}
}

extension Swift.Range {

    @inlinable
    public var map: Property<Map, Swift.Range<Bound>> {
        Property(self)
    }
}

extension Property {

    @inlinable
    public func bounds<Bound: Comparable, T: Comparable>(
        _ transform: (Bound) -> T
    ) -> Swift.Range<T>
    where Tag == Swift.Range<Bound>.Map, Base == Swift.Range<Bound> {
        transform(base.lowerBound)..<transform(base.upperBound)
    }
}

extension Property {

    @inlinable
    public func callAsFunction<Bound: Strideable, T, E: Swift.Error>(
        _ transform: (Bound) throws(E) -> T
    ) throws(E) -> [T]
    where
        Bound.Stride: SignedInteger,
        Tag == Swift.Range<Bound>.Map,
        Base == Swift.Range<Bound>
    {
        var result: [T] = []
        result.reserveCapacity(base.count)
        var i = base.lowerBound
        while i < base.upperBound {
            result.append(try transform(i))
            i = i.advanced(by: 1)
        }
        return result
    }
}