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

extension Range.Lazy {
    /// Namespace for prefix operations on lazy ranges.
    ///
    /// Provides O(1) `first(_:)` by adjusting bounds directly, and O(n) `while { }`
    /// which must iterate to find the first non-matching element.
    public struct Prefix: ~Copyable {
        @usableFromInline
        var base: Range.Lazy<Bound>

        @inlinable
        init(_ base: Range.Lazy<Bound>) {
            self.base = base
        }
    }
}

extension Range.Lazy.Prefix where Bound: Copyable {

    /// Take first N elements: `.prefix.first(_:)` → O(1)
    ///
    /// Returns a new lazy range with adjusted end bound.
    ///
    /// ```swift
    /// let count = try Range.Index.Count(10)
    /// let range = Range.Lazy(count: count) { $0 }
    /// range.prefix.first(try .init(3))  // Range.Lazy(0..<3)
    /// ```
    @inlinable
    public consuming func first(_ count: Range.Index.Count) -> Range.Lazy<Bound> {
        // Total: Index position + Count is always non-negative
        let advancedPosition = base.start.position.rawValue + count.rawValue
        let newEnd = Range.Index(__unchecked: (), Ordinal.Position(min(advancedPosition, base.end.position.rawValue)))
        return Range.Lazy<Bound>(__unchecked: (), start: base.start, end: newEnd, transform: base.transform)
    }

    /// Take elements while predicate is true: `.prefix.while { }` → O(n)
    ///
    /// Must iterate to find first non-matching element.
    /// Returns array (cannot compute new bounds without iteration).
    ///
    /// ```swift
    /// let range = Range.Lazy(count: try .init(10)) { $0 }
    /// range.prefix.while { $0.position.rawValue < 5 }  // [0, 1, 2, 3, 4]
    /// ```
    @inlinable
    public consuming func `while`(_ predicate: (Bound) -> Bool) -> [Bound] {
        var result: [Bound] = []
        var i = base.start
        while i < base.end {
            let element = base.transform(i)
            if !predicate(element) { break }
            result.append(element)
            // Proof: i < end, so i + 1 <= end
            i = Range.Index(__unchecked: (), Ordinal.Position(i.position.rawValue + 1))
        }
        return result
    }
}

extension Range.Lazy where Bound: Copyable {

    /// Access to `.prefix` operations with O(1) `first(_:)`.
    ///
    /// ```swift
    /// let count = try Range.Index.Count(10)
    /// let range = Range.Lazy(count: count) { $0 }
    /// let prefixed = range.prefix.first(try .init(3))  // O(1) → Range.Lazy(0..<3)
    /// ```
    @inlinable
    public var `prefix`: Prefix {
        Prefix(self)
    }
}
