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
    /// Tag type for Property-dispatched typed-throws filtering.
    public enum Filter {}

    /// Verb-as-property accessor for typed-throws filtering over the range.
    ///
    /// Coexists with stdlib's inherited `Sequence.filter(_:) rethrows -> [Element]`;
    /// Swift's overload resolution picks the Property path when the
    /// predicate carries `throws(E)`. Per `[IMPL-020]` verb-as-property.
    ///
    /// ## Example
    ///
    /// ```swift
    /// enum CheckError: Swift.Error { case bad(Int) }
    ///
    /// let evens: [Int] = try (0..<10).filter { (i: Int) throws(CheckError) in
    ///     guard i >= 0 else { throw .bad(i) }
    ///     return i.isMultiple(of: 2)
    /// }
    /// ```
    @inlinable
    public var filter: Property<Filter, Self> {
        Property(self)
    }
}

extension Property {
    /// Typed-throws filter over the bounds of a `Swift.Range`.
    ///
    /// - Parameter isIncluded: A predicate; values for which it returns
    ///   `true` are included in the result. May throw `E`.
    /// - Returns: `[Bound]` of values that satisfied the predicate, in
    ///   range order.
    /// - Throws: Any error of type `E` thrown by the predicate.
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
