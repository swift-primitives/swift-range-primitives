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

extension Range.Lazy.Reversed {
    /// Namespace for drop operations on reversed lazy ranges.
    ///
    /// For a reversed range, dropping skips elements from the high end
    /// (which appears first in iteration order).
    public struct Drop: ~Copyable {
        @usableFromInline
        var base: Range.Lazy<Bound>.Reversed

        @inlinable
        init(_ base: Range.Lazy<Bound>.Reversed) {
            self.base = base
        }
    }
}

extension Range.Lazy.Reversed.Drop where Bound: Copyable {

    /// Skip first N elements (from end): `.drop.first(_:)` → O(1)
    ///
    /// For a reversed range, this drops from the high end.
    ///
    /// ```swift
    /// let count: Index.Count = 10
    /// let range = Range.Lazy(.zero..<count) { $0 }.reversed()
    /// range.drop.first(3)  // Equivalent to 0..<7 reversed
    /// ```
    @inlinable
    public consuming func first(_ count: Index.Count) -> Range.Lazy<Bound>.Reversed {
        let newEnd = max(base.end - count, base.start)
        return Range.Lazy<Bound>.Reversed(
            start: base.start,
            end: newEnd,
            transform: base.transform
        )
    }

    /// Skip elements while predicate is true: `.drop.while { }` → O(n)
    ///
    /// ```swift
    /// let count: Index.Count = 10
    /// let range = Range.Lazy(.zero..<count) { $0 }.reversed()
    /// range.drop.while { $0 > 5 }  // [5, 4, 3, 2, 1, 0]
    /// ```
    @inlinable
    public consuming func `while`(_ predicate: (Bound) -> Bool) -> [Bound] {
        var result: [Bound] = []
        var dropping = true
        var i = base.end - .one
        while i >= base.start {
            let element = base.transform(i)
            if dropping && predicate(element) {
                i -= .one
                continue
            }
            dropping = false
            result.append(element)
            i -= .one
        }
        return result
    }
}

extension Range.Lazy.Reversed where Bound: Copyable {

    /// Access to `.drop` operations.
    ///
    /// ```swift
    /// let range = Range.Lazy(0..<10) { $0 }.reversed()
    /// let dropped = range.drop.first(3)  // O(1)
    /// ```
    @inlinable
    public var drop: Drop {
        Drop(self)
    }
}
