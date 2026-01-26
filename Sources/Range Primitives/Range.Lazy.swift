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

extension Range {
    /// A lazy range that produces `~Copyable` bounds on-demand.
    ///
    /// `Range.Lazy` stores integer bounds internally and applies a transformation
    /// function to produce typed bounds. This enables range-based iteration over
    /// `~Copyable` types without requiring `Sequence` conformance.
    ///
    /// ## Regeneration Semantics
    ///
    /// Each iteration step or subscript access calls the transform function.
    /// Values are **not cached** — they are created fresh at each access.
    ///
    /// ## Conditional Sequence.Protocol Conformance
    ///
    /// `Range.Lazy` conditionally conforms to `Sequence.Protocol` when `Bound: Copyable`:
    ///
    /// | Bound | Sequence.Protocol | Available Operations |
    /// |-------|-------------------|---------------------|
    /// | `Copyable` | Conforms | `.satisfies.all`, `.first`, `.countWhere`, `.reduce`, `.contains` |
    /// | `~Copyable` | Does not conform | `.forEach`, `.drain` only |
    ///
    /// This conditional conformance exists because `Sequence.Protocol.Element`
    /// implicitly requires `Copyable` per SE-0427.
    ///
    /// For `~Copyable` bounds, use the closure-based `.forEach` and `.drain` patterns.
    ///
    /// ## Why Property.View (Not Direct Methods)
    ///
    /// The `.forEach` and `.drain` patterns use `Property.View` because it is
    /// **mandatory**, not stylistic. Property.View enables consuming iteration
    /// while preserving borrow checking and lifetime guarantees. Direct mutating
    /// methods would require `var` binding at call sites and lose lifetime safety.
    ///
    /// ## Affine Type Integration
    ///
    /// When `Bound` is `Index<Tag>`, subscript access uses `Index<Tag>.Offset`
    /// for type-safe offsets, integrating with swift-affine-primitives and
    /// swift-index-primitives.
    ///
    /// ## Iteration Patterns
    ///
    /// ```swift
    /// var range = Range.Lazy(0..<count) { Index(__unchecked: (), position: $0) }
    ///
    /// // Borrowing iteration (range survives)
    /// range.forEach { index in
    ///     print(index)
    /// }
    ///
    /// // Consuming iteration (range becomes empty)
    /// range.drain { index in
    ///     consume(index)
    /// }
    ///
    /// // Reversed iteration
    /// var reversed = range.reversed()
    /// reversed.forEach { index in
    ///     print(index)  // Prints in reverse order
    /// }
    ///
    /// // Manual iteration
    /// var iterator = range.makeIterator()
    /// while let index = iterator.next() {
    ///     process(index)
    /// }
    /// ```
    ///
    /// ## Design Note
    ///
    /// The `Iterator` and `Reversed` types are declared inline (not in extensions)
    /// so that they properly inherit the `~Copyable` constraint from `Bound`. This
    /// matches the pattern used by `Array.Static` and `Array.Storage`.
    public struct Lazy<Bound: ~Copyable> {
        
        public var start: Int

        public var end: Int

        @usableFromInline
        let transform: @Sendable (Int) -> Bound

        // MARK: - Nested Iterator

        /// Iterator for `Range.Lazy`.
        ///
        /// Declared inline (not in extension) to inherit `Bound: ~Copyable`
        /// from the outer type.
        public struct Iterator: ~Copyable {
            @usableFromInline
            var current: Int

            @usableFromInline
            let end: Int

            @usableFromInline
            let transform: @Sendable (Int) -> Bound

            @inlinable
            init(current: Int, end: Int, transform: @escaping @Sendable (Int) -> Bound) {
                self.current = current
                self.end = end
                self.transform = transform
            }

            /// Advances to the next element and returns it, or `nil` if exhausted.
            @inlinable
            public mutating func next() -> Bound? {
                guard current < end else { return nil }
                defer { current += 1 }
                return transform(current)
            }
        }

        // MARK: - Nested Reversed

        /// A reversed view of a lazy range.
        ///
        /// Iterates from `end-1` down to `start` (inclusive on both ends in the
        /// transformed result).
        ///
        /// ## Usage
        ///
        /// ```swift
        /// var range = Range.Lazy(0..<5) { Index(__unchecked: (), position: $0) }
        /// var reversed = range.reversed()
        /// reversed.forEach { print($0) }
        /// // Prints indices for positions: 4, 3, 2, 1, 0
        /// ```
        ///
        /// ## Iteration Order
        ///
        /// For a range `0..<n`, the reversed range yields positions in order:
        /// `n-1, n-2, ..., 1, 0`
        ///
        /// ## Design Note
        ///
        /// Declared inline (not in extension) to inherit `Bound: ~Copyable`
        /// from the outer type.
        public struct Reversed {
            @usableFromInline
            var start: Int

            @usableFromInline
            var end: Int

            @usableFromInline
            let transform: @Sendable (Int) -> Bound

            /// Iterator for `Range.Lazy.Reversed`.
            public struct Iterator: ~Copyable {
                @usableFromInline
                var current: Int

                @usableFromInline
                let start: Int

                @usableFromInline
                let transform: @Sendable (Int) -> Bound

                @inlinable
                init(current: Int, start: Int, transform: @escaping @Sendable (Int) -> Bound) {
                    self.current = current
                    self.start = start
                    self.transform = transform
                }

                /// Advances to the next element and returns it, or `nil` if exhausted.
                @inlinable
                public mutating func next() -> Bound? {
                    guard current >= start else { return nil }
                    defer { current -= 1 }
                    return transform(current)
                }
            }

            @usableFromInline
            init(start: Int, end: Int, transform: @escaping @Sendable (Int) -> Bound) {
                self.start = start
                self.end = end
                self.transform = transform
            }

            /// The number of elements in the range.
            @inlinable
            public var count: Int { end - start }

            /// A Boolean value indicating whether the range is empty.
            @inlinable
            public var isEmpty: Bool { start >= end }

            /// Returns an iterator over the range elements in reverse order.
            ///
            /// The range is consumed by this operation.
            @inlinable
            public consuming func makeIterator() -> Iterator {
                Iterator(current: end - 1, start: start, transform: transform)
            }

            // MARK: - Internal Iteration

            @inlinable
            mutating func _borrowingForEach(_ body: (borrowing Bound) -> Void) {
                var i = end - 1
                while i >= start {
                    let bound = transform(i)
                    body(bound)
                    i -= 1
                }
            }

            @inlinable
            mutating func _consumingDrain(_ body: (consuming Bound) -> Void) {
                var i = end - 1
                while i >= start {
                    body(transform(i))
                    i -= 1
                }
                // Mark as empty
                start = end
            }

            // MARK: - Property Accessors

            /// Access to `.forEach` operations.
            ///
            /// ```swift
            /// // Works on temporaries
            /// range.reversed().forEach { print($0) }
            ///
            /// // Fluent API
            /// range.reversed().forEach.borrowing { print($0) }
            /// ```
            @inlinable
            public var forEach: Property<Range.ForEach, Self> {
                Property(self)
            }

            /// Access to `.drain` operations.
            ///
            /// Requires a mutable binding because drain empties the range.
            ///
            /// ```swift
            /// var reversed = Range.Lazy(0..<10) { $0 }.reversed()
            /// reversed.drain { consume($0) }
            /// // reversed is now empty
            /// ```
            @inlinable
            public var drain: Property<Range.Drain, Self>.View {
                mutating _read {
                    yield unsafe Property<Range.Drain, Self>.View(&self)
                }
                mutating _modify {
                    var view = unsafe Property<Range.Drain, Self>.View(&self)
                    yield &view
                }
            }
        }

        // MARK: - Initializers

        /// Creates a lazy range with the given integer bounds and transformation.
        ///
        /// - Parameters:
        ///   - range: The integer range to iterate over.
        ///   - transform: A function that converts an integer position to the bound type.
        @inlinable
        public init(_ range: Swift.Range<Int>, transform: @escaping @Sendable (Int) -> Bound) {
            self.start = range.lowerBound
            self.end = range.upperBound
            self.transform = transform
        }

        /// Internal initializer for direct bounds construction.
        ///
        /// Used by Drop/Prefix operations to construct adjusted ranges in O(1).
        @usableFromInline
        init(start: Int, end: Int, transform: @escaping @Sendable (Int) -> Bound) {
            self.start = start
            self.end = end
            self.transform = transform
        }

        // MARK: - Properties

        /// The number of elements in the range.
        @inlinable
        public var count: Int { end - start }

        /// A Boolean value indicating whether the range is empty.
        @inlinable
        public var isEmpty: Bool { start >= end }

        // MARK: - Iterator Factory

        /// Returns an iterator over the range elements.
        ///
        /// The range is consumed by this operation.
        @inlinable
        public consuming func makeIterator() -> Iterator {
            Iterator(current: start, end: end, transform: transform)
        }

        // MARK: - Reversed Factory

        /// Returns a reversed view of this range.
        ///
        /// The reversed range iterates from `end-1` down to `start`.
        ///
        /// ```swift
        /// var range = Range.Lazy(0..<5) { Index(__unchecked: (), position: $0) }
        /// var reversed = range.reversed()
        /// reversed.forEach { print($0) }
        /// // Prints indices for positions: 4, 3, 2, 1, 0
        /// ```
        @inlinable
        public consuming func reversed() -> Reversed {
            Reversed(start: start, end: end, transform: transform)
        }

        // MARK: - Internal Iteration

        @inlinable
        mutating func _borrowingForEach(_ body: (borrowing Bound) -> Void) {
            for i in start..<end {
                let bound = transform(i)
                body(bound)
            }
        }

        @inlinable
        mutating func _consumingDrain(_ body: (consuming Bound) -> Void) {
            for i in start..<end {
                body(transform(i))
            }
            // Mark as empty
            start = end
        }

        // MARK: - Property Accessors

        /// Access to `.forEach` operations.
        ///
        /// ```swift
        /// // Works on temporaries
        /// (0..<count).forEach { print($0) }
        ///
        /// // Fluent API
        /// (0..<count).forEach.borrowing { print($0) }
        /// ```
        @inlinable
        public var forEach: Property<Range.ForEach, Self> {
            Property(self)
        }

        /// Access to `.drain` operations.
        ///
        /// Requires a mutable binding because drain empties the range.
        ///
        /// ```swift
        /// var range = Range.Lazy(0..<10) { Index(__unchecked: (), position: $0) }
        /// range.drain { consume($0) }
        /// // range is now empty
        /// ```
        @inlinable
        public var drain: Property<Range.Drain, Self>.View {
            mutating _read {
                yield unsafe Property<Range.Drain, Self>.View(&self)
            }
            mutating _modify {
                var view = unsafe Property<Range.Drain, Self>.View(&self)
                yield &view
            }
        }
    }
}

// MARK: - Sendable

extension Range.Lazy: Sendable where Bound: Sendable {}
extension Range.Lazy.Iterator: Sendable where Bound: Sendable {}
extension Range.Lazy.Reversed: Sendable where Bound: Sendable {}
extension Range.Lazy.Reversed.Iterator: Sendable where Bound: Sendable {}

// MARK: - Conditional Copyable

// The iterators are declared as ~Copyable to support ~Copyable bounds, but their
// stored properties (Int, function type) are always Copyable. When Bound: Copyable,
// the iterators can safely conform to Copyable, enabling IteratorProtocol conformance.

extension Range.Lazy.Iterator: Copyable where Bound: Copyable {}
extension Range.Lazy.Reversed.Iterator: Copyable where Bound: Copyable {}
