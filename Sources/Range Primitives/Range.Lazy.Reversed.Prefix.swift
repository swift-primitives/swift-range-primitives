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
    /// let count = try Range.Index.Count(10)
    /// let range = Range.Lazy(count: count) { $0 }.reversed()
    /// range.prefix.first(try .init(3))  // Equivalent to 7..<10 reversed → [9, 8, 7]
    /// ```
    @inlinable
    public consuming func first(_ count: Range.Index.Count) -> Range.Lazy<Bound>.Reversed {
        let newStart = base.end.retreated(by: count, clampedTo: base.start)
        return Range.Lazy<Bound>.Reversed(__unchecked: (), start: newStart, end: base.end, transform: base.transform)
    }

    /// Take elements while predicate is true: `.prefix.while { }` → O(n)
    ///
    /// ```swift
    /// let count = try Range.Index.Count(10)
    /// let range = Range.Lazy(count: count) { $0 }.reversed()
    /// range.prefix.while { $0.position > 5 }  // [9, 8, 7, 6]
    /// ```
    @inlinable
    public consuming func `while`(_ predicate: (Bound) -> Bool) -> [Bound] {
        var result: [Bound] = []
        guard !base.isEmpty else { return result }

        // Proof: !isEmpty means end > start >= 0, so end - 1 >= 0
        var i = Range.Index(__unchecked: (), Ordinal(base.end.position.rawValue - 1))
        while i >= base.start {
            let element = base.transform(i)
            if !predicate(element) { break }
            result.append(element)
            if i == base.start { break }
            // Proof: i > start >= 0, so i - 1 >= 0
            i = Range.Index(__unchecked: (), Ordinal(i.position.rawValue - 1))
        }
        return result
    }
}

extension Range.Lazy.Reversed where Bound: Copyable {

    /// Access to `.prefix` operations.
    ///
    /// ```swift
    /// let range = Range.Lazy(count: try .init(10)) { $0 }.reversed()
    /// let prefixed = range.prefix.first(try .init(3))  // O(1)
    /// ```
    @inlinable
    public var `prefix`: Prefix {
        Prefix(self)
    }
}
