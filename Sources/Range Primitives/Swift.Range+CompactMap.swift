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
    /// Tag type for Property-dispatched typed-throws optional-returning transform.
    public enum CompactMap {}

    /// Verb-as-property accessor for typed-throws `compactMap` over the range.
    ///
    /// Coexists with stdlib's inherited `Sequence.compactMap(_:) rethrows -> [T]`;
    /// Swift's overload resolution picks the Property path when the
    /// transform carries `throws(E)`. The closure returns `T?`; `nil`
    /// returns are filtered out, non-nil returns are unwrapped into the
    /// result array. Per `[IMPL-020]` verb-as-property.
    ///
    /// ## Example
    ///
    /// ```swift
    /// enum ParseError: Swift.Error { case syntax(Int) }
    ///
    /// let parsed: [Token] = try (0..<lines).compactMap { (line: Int) throws(ParseError) in
    ///     guard let raw = source(line) else { return nil }   // skip blank
    ///     guard let token = Token(raw) else { throw .syntax(line) }
    ///     return token
    /// }
    /// ```
    @inlinable
    public var compactMap: Property<CompactMap, Self> {
        Property(self)
    }
}

extension Property {
    /// Typed-throws `compactMap` over the bounds of a `Swift.Range`.
    ///
    /// Each `Bound` is passed to the transform; `nil` returns are
    /// dropped, non-`nil` returns are unwrapped into the result array.
    ///
    /// - Parameter transform: A closure mapping each `Bound` to an
    ///   optional `T`. May throw `E`.
    /// - Returns: `[T]` of unwrapped non-nil transform results, in range
    ///   order.
    /// - Throws: Any error of type `E` thrown by the transform closure.
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
