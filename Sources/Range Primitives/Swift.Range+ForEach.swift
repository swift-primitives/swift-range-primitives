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
    /// Tag type for Property-dispatched typed-throws iteration.
    public enum ForEach {}

    /// Verb-as-property accessor for typed-throws iteration over the range.
    ///
    /// Bridges the `[API-ERR-005]` gap: stdlib `Range.forEach` is the
    /// `rethrows` `Sequence.forEach` inherited via protocol conformance,
    /// which widens `throws(E)` to untyped throws at the closure boundary.
    /// Declaring `forEach` as a `Property` accessor directly on `Range`
    /// (rather than as a same-named method) lets Swift's overload
    /// resolution pick the Property path for typed-throws closures while
    /// non-throwing call sites continue to compose unchanged: a `var
    /// forEach: Property<...>` extension and the inherited `func
    /// forEach(_:) rethrows` coexist on the same type, and Swift selects
    /// the direct-extension member over the protocol-inherited one when
    /// the closure shape requires typed throws.
    ///
    /// Mirrors the institute's existing Property pattern for typed-throws
    /// iteration on owned containers (see `Vector.ForEach+Property.swift`
    /// in `swift-vector-primitives`). Per `[IMPL-020]` verb-as-property
    /// with `callAsFunction`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// enum AxisError: Swift.Error { case outOfBounds(Int) }
    ///
    /// try (0..<rank).forEach { (axis: Int) throws(AxisError) in
    ///     guard axis < bound else { throw .outOfBounds(axis) }
    /// }
    /// ```
    @inlinable
    public var forEach: Property<ForEach, Self> {
        Property(self)
    }
}

extension Property {
    /// Typed-throws iteration over the bounds of a `Swift.Range`.
    ///
    /// Selected via `range.forEach { ... }` per the verb-as-property
    /// accessor on `Swift.Range`. The closure parameter receives each
    /// `Bound` value in `lowerBound..<upperBound`; a thrown error of type
    /// `E` propagates with its typed shape intact (no type-erasure to untyped throws).
    ///
    /// - Parameter body: A closure called with each `Bound` value. May throw `E`.
    /// - Throws: Any error of type `E` thrown by the closure.
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
