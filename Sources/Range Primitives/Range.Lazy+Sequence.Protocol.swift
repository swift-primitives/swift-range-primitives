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

public import Sequence_Primitives

// MARK: - Conditional IteratorProtocol Conformance
//
// Note: Conditional Copyable conformances for Range.Lazy.Iterator and
// Range.Lazy.Reversed.Iterator are defined in Range.Lazy.swift (same file
// as the type definitions, as required by Swift).

extension Range.Lazy.Iterator: IteratorProtocol where Bound: Copyable {}

extension Range.Lazy.Reversed.Iterator: IteratorProtocol where Bound: Copyable {}

// MARK: - Swift.Sequence Conformance

extension Range.Lazy: Swift.Sequence where Bound: Copyable {
    @inlinable
    public var underestimatedCount: Int { end - start }
}

extension Range.Lazy.Reversed: Swift.Sequence where Bound: Copyable {
    @inlinable
    public var underestimatedCount: Int { end - start }
}

// MARK: - Conditional Sequence.Protocol Conformance for Range.Lazy

extension Range.Lazy: Sequence.`Protocol` where Bound: Copyable {
    public typealias Element = Bound

    /// Returns an iterator over the range elements.
    ///
    /// This conformance is only available when `Bound: Copyable` because
    /// `Sequence.Protocol.Element` implicitly requires `Copyable` per SE-0427.
    @inlinable
    public borrowing func makeIterator() -> Iterator {
        Iterator(current: start, end: end, transform: transform)
    }
}

// MARK: - Sequence.Clearable for consuming operations

extension Range.Lazy: Sequence.Clearable where Bound: Copyable {
    @inlinable
    public mutating func removeAll() {
        start = end
    }
}

// MARK: - Conditional Sequence.Protocol Conformance for Range.Lazy.Reversed

extension Range.Lazy.Reversed: Sequence.`Protocol` where Bound: Copyable {
    public typealias Element = Bound

    /// Returns an iterator over the reversed range elements.
    @inlinable
    public borrowing func makeIterator() -> Iterator {
        Iterator(current: end - 1, start: start, transform: transform)
    }
}

extension Range.Lazy.Reversed: Sequence.Clearable where Bound: Copyable {
    @inlinable
    public mutating func removeAll() {
        start = end
    }
}

