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

extension Swift.Range where Bound: Strideable, Bound.Stride: SignedInteger {
    /// Tag type for Property-dispatched typed-throws existential predicate.
    public enum Contains {}

    /// Verb-as-property accessor for typed-throws `contains(where:)` over the range.
    ///
    /// Coexists with both stdlib `Range.contains(_:)` (single-value form)
    /// and stdlib's inherited `Sequence.contains(where:) rethrows -> Bool`
    /// (predicate form). Swift's overload resolution picks the Property
    /// path when the closure shape is a typed-throws predicate; the
    /// single-value form (`range.contains(5)`) is unaffected because it
    /// passes a value, not a closure. Per `[IMPL-020]` verb-as-property.
    ///
    /// ## Example
    ///
    /// ```swift
    /// enum CheckError: Swift.Error { case probeFailed(Int) }
    ///
    /// let any: Bool = try (0..<rank).contains { (axis: Int) throws(CheckError) in
    ///     guard let probe = sample(axis) else { throw .probeFailed(axis) }
    ///     return probe > threshold
    /// }
    /// ```
    @inlinable
    public var contains: Property<Contains, Self> {
        Property(self)
    }
}

extension Property {
    /// Typed-throws `contains(where:)` over the bounds of a `Swift.Range`.
    ///
    /// Short-circuits on the first `true` return from the predicate.
    ///
    /// - Parameter predicate: A predicate over each `Bound`. May throw `E`.
    /// - Returns: `true` iff at least one value in the range satisfies the
    ///   predicate; `false` if the range is empty.
    /// - Throws: Any error of type `E` thrown by the predicate.
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
