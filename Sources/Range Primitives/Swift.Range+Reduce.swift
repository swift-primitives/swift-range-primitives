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
    /// Tag type for Property-dispatched typed-throws reduction.
    public enum Reduce {}

    /// Verb-as-property accessor for typed-throws reduction over the range.
    ///
    /// Coexists with stdlib's inherited `Sequence.reduce(_:_:) rethrows -> R`;
    /// Swift's overload resolution picks the Property path when the
    /// combine closure carries `throws(E)`. Per `[IMPL-020]` verb-as-property.
    ///
    /// ## Example
    ///
    /// ```swift
    /// enum SumError: Swift.Error { case overflow }
    ///
    /// let total: Int = try (0..<n).reduce(0) { (acc: Int, i: Int) throws(SumError) in
    ///     let (next, overflow) = acc.addingReportingOverflow(i)
    ///     guard !overflow else { throw .overflow }
    ///     return next
    /// }
    /// ```
    @inlinable
    public var reduce: Property<Reduce, Self> {
        Property(self)
    }
}

extension Property {
    /// Typed-throws reduction over the bounds of a `Swift.Range`.
    ///
    /// - Parameters:
    ///   - initialResult: The accumulator's seed value.
    ///   - combine: A closure folding each `Bound` into the accumulator.
    ///     May throw `E`.
    /// - Returns: The final accumulated value.
    /// - Throws: Any error of type `E` thrown by the combine closure.
    @inlinable
    public func callAsFunction<Bound: Strideable, R, E: Swift.Error>(
        _ initialResult: R,
        _ combine: (R, Bound) throws(E) -> R
    ) throws(E) -> R
    where
        Bound.Stride: SignedInteger,
        Tag == Swift.Range<Bound>.Reduce,
        Base == Swift.Range<Bound>
    {
        var accumulator = initialResult
        var i = base.lowerBound
        while i < base.upperBound {
            accumulator = try combine(accumulator, i)
            i = i.advanced(by: 1)
        }
        return accumulator
    }
}
