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
    /// Namespace for drop operations on lazy ranges.
    ///
    /// Provides O(1) `first(_:)` by adjusting bounds directly, and O(n) `while { }`
    /// which must iterate to find the first non-matching element.
    public struct Drop: ~Copyable {
        @usableFromInline
        var base: Range.Lazy<Bound>

        @inlinable
        init(_ base: Range.Lazy<Bound>) {
            self.base = base
        }
    }
}

extension Range.Lazy.Drop where Bound: Copyable {

    /// Skip first N elements: `.drop.first(_:)` → O(1)
    ///
    /// Returns a new lazy range with adjusted start bound.
    ///
    /// ```swift
    /// let count = try Range.Index.Count(10)
    /// let range = Range.Lazy(count: count) { $0 }
    /// range.drop.first(try .init(3))  // Range.Lazy(3..<10)
    /// ```
    @inlinable
    public consuming func first(
        _ count: Range.Index.Count
    ) -> Range.Lazy<Bound> {
        let newStart = base.start.advanced(by: count, clampedTo: base.end)
        // Safe: newStart is clamped to base.end, so newStart <= base.end
        return Range.Lazy<Bound>(
            __unchecked: (),
            start: newStart,
            end: base.end,
            transform: base.transform
        )
    }

    /// Skip elements while predicate is true: `.drop.while { }` → O(n)
    ///
    /// Must iterate to find first non-matching element.
    /// Returns array (cannot compute new bounds without iteration).
    ///
    /// ```swift
    /// let range = Range.Lazy(count: try .init(10)) { $0 }
    /// range.drop.while { $0.position < 5 }  // [5, 6, 7, 8, 9]
    /// ```
    @inlinable
    public consuming func `while`(_ predicate: (Bound) -> Bool) -> [Bound] {
        var result: [Bound] = []
        var dropping = true
        var i = base.start
        while i < base.end {
            let element = base.transform(i)
            if dropping && predicate(element) {
                // Proof: i < end, so i + 1 <= end
                i = Range.Index(__unchecked: (), Ordinal(i.position.rawValue + 1))
                continue
            }
            dropping = false
            result.append(element)
            // Proof: i < end, so i + 1 <= end
            i = Range.Index(__unchecked: (), Ordinal(i.position.rawValue + 1))
        }
        return result
    }
}

extension Range.Lazy where Bound: Copyable {

    /// Access to `.drop` operations with O(1) `first(_:)`.
    ///
    /// ```swift
    /// let count = try Range.Index.Count(10)
    /// let range = Range.Lazy(count: count) { $0 }
    /// let dropped = range.drop.first(try .init(3))  // O(1) → Range.Lazy(3..<10)
    /// ```
    @inlinable
    public var drop: Drop {
        Drop(self)
    }
}
