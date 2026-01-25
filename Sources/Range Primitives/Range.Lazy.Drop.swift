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
    /// let range = Range.Lazy(0..<10) { $0 }
    /// range.drop.first(3)  // Range.Lazy(3..<10)
    /// ```
    @inlinable
    public consuming func first(_ count: Int) -> Range.Lazy<Bound> {
        let newStart = min(base.start + count, base.end)
        return Range.Lazy<Bound>(start: newStart, end: base.end, transform: base.transform)
    }

    /// Skip elements while predicate is true: `.drop.while { }` → O(n)
    ///
    /// Must iterate to find first non-matching element.
    /// Returns array (cannot compute new bounds without iteration).
    ///
    /// ```swift
    /// var range = Range.Lazy(0..<10) { $0 }
    /// range.drop.while { $0 < 5 }  // [5, 6, 7, 8, 9]
    /// ```
    @inlinable
    public consuming func `while`(_ predicate: (Bound) -> Bool) -> [Bound] {
        var result: [Bound] = []
        var dropping = true
        for i in base.start..<base.end {
            let element = base.transform(i)
            if dropping && predicate(element) {
                continue
            }
            dropping = false
            result.append(element)
        }
        return result
    }
}

extension Range.Lazy where Bound: Copyable {

    /// Access to `.drop` operations with O(1) `first(_:)`.
    ///
    /// ```swift
    /// let range = Range.Lazy(0..<10) { $0 }
    /// let dropped = range.drop.first(3)  // O(1) → Range.Lazy(3..<10)
    /// ```
    @inlinable
    public var drop: Drop {
        Drop(self)
    }
}
