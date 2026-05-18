// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// MARK: - Tag

extension Swift.Range {
    /// Tag type for `Property`-dispatched mapping operations on ranges.
    public enum Map {}
}

// MARK: - Map Accessor

extension Swift.Range {
    /// Verb-as-property accessor for mapping operations on the range.
    ///
    /// Provides two distinct mapping shapes, disambiguated by the
    /// `Property` extension selected at the call site:
    /// - `.map.bounds { (Bound) -> T } -> Range<T>` — transforms both
    ///   endpoints of the range, yielding a new range with mapped bounds.
    /// - `.map { (Bound) throws(E) -> T } throws(E) -> [T]` — typed-throws
    ///   element-wise transformation, yielding an array of transformed
    ///   values. The Property accessor coexists with stdlib's inherited
    ///   `Sequence.map(_:) rethrows -> [T]`; Swift's overload resolution
    ///   picks the Property path when the transform closure carries
    ///   `throws(E)`, so non-throwing call sites continue to resolve to
    ///   stdlib's inherited `map` unchanged.
    ///
    /// ```swift
    /// // Bound transform
    /// let intRange: Range<Index<Foo>> = ...
    /// let bitRange = intRange.map.bounds { $0.retag(Bit.self) }
    ///
    /// // Typed-throws element map
    /// enum DecodeError: Swift.Error { case invalid(Int) }
    /// let names: [String] = try (0..<count).map { (i: Int) throws(DecodeError) in
    ///     guard let name = lookup(i) else { throw .invalid(i) }
    ///     return name
    /// }
    /// ```
    @inlinable
    public var map: Property<Map, Swift.Range<Bound>> {
        Property(self)
    }
}

// MARK: - Bound Transformation

extension Property {
    /// Transforms both bounds of a range using the given closure.
    ///
    /// ```swift
    /// let mapped = range.map.bounds { $0.retag(Bit.self) }
    /// ```
    ///
    /// - Parameter transform: A closure that transforms a bound value.
    /// - Returns: A new range with transformed bounds.
    @inlinable
    public func bounds<Bound: Comparable, T: Comparable>(_ transform: (Bound) -> T) -> Swift.Range<T>
    where Tag == Swift.Range<Bound>.Map, Base == Swift.Range<Bound> {
        transform(base.lowerBound)..<transform(base.upperBound)
    }
}

// MARK: - Typed-Throws Element Transformation

extension Property {
    /// Typed-throws element-wise transformation over the bounds of a `Swift.Range`.
    ///
    /// Selected via `range.map { ... }` per the verb-as-property accessor
    /// on `Swift.Range`. The closure receives each `Bound` value in
    /// `lowerBound..<upperBound` and returns a transformed value; a thrown
    /// error of type `E` propagates with its typed shape intact (no
    /// type-erasure to untyped throws).
    ///
    /// Coexists with the `.bounds(_:)` accessor on the same `Map` tag —
    /// disambiguated by closure shape: `.bounds` takes `(Bound) -> T` and
    /// returns `Range<T>`; this accessor takes `(Bound) throws(E) -> T` and
    /// returns `[T]`.
    ///
    /// - Parameter transform: A closure mapping each `Bound` to a value of
    ///   type `T`. May throw `E`.
    /// - Returns: An array `[T]` containing each transformed value in
    ///   range order.
    /// - Throws: Any error of type `E` thrown by the transform closure.
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
