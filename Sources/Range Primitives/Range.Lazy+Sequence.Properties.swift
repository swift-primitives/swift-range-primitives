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

public import Property_Primitives
public import Sequence_Primitives

// MARK: - Sequence Property Accessors for Range.Lazy

extension Range.Lazy where Bound: Copyable {

    /// Access to `.satisfies` operations.
    ///
    /// ```swift
    /// range.satisfies.all { $0 > 0 }
    /// range.satisfies.any { $0 == 5 }
    /// range.satisfies.none { $0 < 0 }
    /// ```
    @inlinable
    public var satisfies: Property<Sequence.Satisfies, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Satisfies, Self>.View(&self)
        }
    }

    /// Access to `.first` operations.
    ///
    /// ```swift
    /// range.first { $0 > 5 }  // First element > 5
    /// ```
    @inlinable
    public var first: Property<Sequence.First, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.First, Self>.View(&self)
        }
    }

    /// Returns the count of elements satisfying the predicate.
    ///
    /// ```swift
    /// range.count(where: { $0 % 2 == 0 })  // Count of even elements
    /// ```
    ///
    /// - Parameter predicate: A closure that takes an element and returns
    ///   `true` if the element should be counted.
    /// - Returns: The number of elements satisfying the predicate.
    ///
    /// - Note: For total count, use the `count` property which is O(1).
    @inlinable
    public func count(where predicate: (Bound) -> Bool) -> Range.Index.Count {
        var count = 0
        var iterator = makeIterator()
        while let element = iterator.next() {
            if predicate(element) { count += 1 }
        }
        return Range.Index.Count(__unchecked: (), count)
    }

    /// Access to `.reduce` operations.
    ///
    /// ```swift
    /// range.reduce.into(0) { $0 += $1 }
    /// range.reduce.from(1) { $0 * $1 }
    /// ```
    @inlinable
    public var reduce: Property<Sequence.Reduce, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Reduce, Self>.View(&self)
        }
    }

    /// Access to `.contains` operations.
    ///
    /// ```swift
    /// range.contains { $0 == 5 }
    /// ```
    @inlinable
    public var contains: Property<Sequence.Contains, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Contains, Self>.View(&self)
        }
    }
}

// MARK: - Sequence Property Accessors for Range.Lazy.Reversed

extension Range.Lazy.Reversed where Bound: Copyable {

    /// Access to `.satisfies` operations.
    ///
    /// ```swift
    /// range.reversed().satisfies.all { $0 > 0 }
    /// range.reversed().satisfies.any { $0 == 5 }
    /// range.reversed().satisfies.none { $0 < 0 }
    /// ```
    @inlinable
    public var satisfies: Property<Sequence.Satisfies, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Satisfies, Self>.View(&self)
        }
    }

    /// Access to `.first` operations.
    ///
    /// ```swift
    /// range.reversed().first { $0 > 5 }  // First element > 5 (in reverse order)
    /// ```
    @inlinable
    public var first: Property<Sequence.First, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.First, Self>.View(&self)
        }
    }

    /// Returns the count of elements satisfying the predicate.
    ///
    /// ```swift
    /// range.reversed().count(where: { $0 % 2 == 0 })  // Count of even elements
    /// ```
    ///
    /// - Parameter predicate: A closure that takes an element and returns
    ///   `true` if the element should be counted.
    /// - Returns: The number of elements satisfying the predicate.
    ///
    /// - Note: For total count, use the `count` property which is O(1).
    @inlinable
    public func count(where predicate: (Bound) -> Bool) -> Range.Index.Count {
        var count = 0
        var iterator = makeIterator()
        while let element = iterator.next() {
            if predicate(element) { count += 1 }
        }
        return Range.Index.Count(__unchecked: (), count)
    }

    /// Access to `.reduce` operations.
    ///
    /// ```swift
    /// range.reversed().reduce.into(0) { $0 += $1 }
    /// range.reversed().reduce.from(1) { $0 * $1 }
    /// ```
    @inlinable
    public var reduce: Property<Sequence.Reduce, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Reduce, Self>.View(&self)
        }
    }

    /// Access to `.contains` operations.
    ///
    /// ```swift
    /// range.reversed().contains { $0 == 5 }
    /// ```
    @inlinable
    public var contains: Property<Sequence.Contains, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Contains, Self>.View(&self)
        }
    }
}
