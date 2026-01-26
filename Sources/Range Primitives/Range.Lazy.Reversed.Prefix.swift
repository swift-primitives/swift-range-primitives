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
    /// Namespace for prefix operations on reversed lazy ranges.
    ///
    /// For a reversed range, prefix takes elements from the high end
    /// (which appears first in iteration order).
    public struct Prefix: ~Copyable {
        @usableFromInline
        var base: Range.Lazy<Bound>.Reversed

        @inlinable
        init(_ base: Range.Lazy<Bound>.Reversed) {
            self.base = base
        }
    }
}

extension Range.Lazy.Reversed.Prefix where Bound: Copyable {

    /// Take first N elements (from end): `.prefix.first(_:)` → O(1)
    ///
    /// For a reversed range, this takes from the high end.
    ///
    /// ```swift
    /// let count: Index.Count = 10
    /// let range = Range.Lazy(.zero..<count) { $0 }.reversed()
    /// range.prefix.first(3)  // Equivalent to 7..<10 reversed → [9, 8, 7]
    /// ```
    @inlinable
    public consuming func first(_ count: Index.Count) -> Range.Lazy<Bound>.Reversed {
        let newStart = max(base.end - count, base.start)
        return Range.Lazy<Bound>.Reversed(
            start: newStart,
            end: base.end,
            transform: base.transform
        )
    }

    /// Take elements while predicate is true: `.prefix.while { }` → O(n)
    ///
    /// ```swift
    /// let count: Index.Count = 10
    /// let range = Range.Lazy(.zero..<count) { $0 }.reversed()
    /// range.prefix.while { $0 > 5 }  // [9, 8, 7, 6]
    /// ```
    @inlinable
    public consuming func `while`(_ predicate: (Bound) -> Bool) -> [Bound] {
        var result: [Bound] = []
        var i = base.end - .one
        while i >= base.start {
            let element = base.transform(i)
            if !predicate(element) { break }
            result.append(element)
            i -= .one
        }
        return result
    }
}

extension Range.Lazy.Reversed where Bound: Copyable {

    /// Access to `.prefix` operations.
    ///
    /// ```swift
    /// let range = Range.Lazy(0..<10) { $0 }.reversed()
    /// let prefixed = range.prefix.first(3)  // O(1)
    /// ```
    @inlinable
    public var `prefix`: Prefix {
        Prefix(self)
    }
}
