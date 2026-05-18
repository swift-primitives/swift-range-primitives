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
    /// Tag type for Property-dispatched typed-throws first-match search.
    public enum First {}

    /// Verb-as-property accessor for typed-throws `first(where:)` over the range.
    ///
    /// Coexists with stdlib's inherited `Collection.first(where:) rethrows -> Element?`;
    /// Swift's overload resolution picks the Property path when the
    /// predicate carries `throws(E)`. Returns the first value for which
    /// the predicate returns `true`, or `nil` if none does. Per
    /// `[IMPL-020]` verb-as-property.
    ///
    /// ## Example
    ///
    /// ```swift
    /// enum LookupError: Swift.Error { case probeFailed(Int) }
    ///
    /// let found: Int? = try (0..<n).first { (i: Int) throws(LookupError) in
    ///     guard let probe = sample(i) else { throw .probeFailed(i) }
    ///     return probe.matches(query)
    /// }
    /// ```
    @inlinable
    public var first: Property<First, Self> {
        Property(self)
    }
}

extension Property {
    /// Typed-throws `first(where:)` over the bounds of a `Swift.Range`.
    ///
    /// Short-circuits on the first `true` return from the predicate.
    ///
    /// - Parameter predicate: A predicate over each `Bound`. May throw `E`.
    /// - Returns: The first `Bound` for which the predicate returned
    ///   `true`, or `nil` if no value satisfied it.
    /// - Throws: Any error of type `E` thrown by the predicate.
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
