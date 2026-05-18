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
    /// Tag type for Property-dispatched typed-throws universal predicate.
    public enum AllSatisfy {}

    /// Verb-as-property accessor for typed-throws `allSatisfy` over the range.
    ///
    /// Coexists with stdlib's inherited `Sequence.allSatisfy(_:) rethrows -> Bool`;
    /// Swift's overload resolution picks the Property path when the
    /// predicate carries `throws(E)`. Returns `true` iff every element
    /// satisfies the predicate (vacuously true for an empty range);
    /// short-circuits on the first `false` return. Per `[IMPL-020]`
    /// verb-as-property.
    ///
    /// ## Example
    ///
    /// ```swift
    /// enum ValidationError: Swift.Error { case oneOutOfRange(Int) }
    ///
    /// let allValid: Bool = try (0..<rank).allSatisfy { (axis: Int) throws(ValidationError) in
    ///     guard axis >= 0 else { throw .oneOutOfRange(axis) }
    ///     return axis < shape.count
    /// }
    /// ```
    @inlinable
    public var allSatisfy: Property<AllSatisfy, Self> {
        Property(self)
    }
}

extension Property {
    /// Typed-throws `allSatisfy` over the bounds of a `Swift.Range`.
    ///
    /// Short-circuits on the first `false` return from the predicate.
    ///
    /// - Parameter predicate: A predicate over each `Bound`. May throw `E`.
    /// - Returns: `true` iff every value in the range satisfies the
    ///   predicate; `true` if the range is empty.
    /// - Throws: Any error of type `E` thrown by the predicate.
    @inlinable
    public func callAsFunction<Bound: Strideable, E: Swift.Error>(
        _ predicate: (Bound) throws(E) -> Bool
    ) throws(E) -> Bool
    where
        Bound.Stride: SignedInteger,
        Tag == Swift.Range<Bound>.AllSatisfy,
        Base == Swift.Range<Bound>
    {
        var i = base.lowerBound
        while i < base.upperBound {
            if try !predicate(i) {
                return false
            }
            i = i.advanced(by: 1)
        }
        return true
    }
}
