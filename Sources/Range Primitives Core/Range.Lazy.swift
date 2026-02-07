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
public import Index_Primitives

extension Range {

    /// The index type for range bounds.
    ///
    /// Uses `Index<Range>` to provide a range-local index domain, ensuring
    /// type safety through phantom typing.
    public typealias Index = Index_Primitives.Index<Range>

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
    /// var range = Range.Lazy(count: try .init(10)) { position in
    ///     Index<Node>(__unchecked: (), position.position)
    /// }
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

        public var start: Range.Index

        public var end: Range.Index

        @Inlined public var count: Range.Index.Count

        @usableFromInline
        let transform: @Sendable (Range.Index) -> Bound

        // MARK: - Nested Iterator

        /// Iterator for `Range.Lazy`.
        ///
        /// Declared inline (not in extension) to inherit `Bound: ~Copyable`
        /// from the outer type.
        public struct Iterator: ~Copyable {
            @usableFromInline
            var current: Range.Index

            @usableFromInline
            let end: Range.Index

            @usableFromInline
            let transform: @Sendable (Range.Index) -> Bound

            @inlinable
            init(current: Range.Index, end: Range.Index, transform: @escaping @Sendable (Range.Index) -> Bound) {
                self.current = current
                self.end = end
                self.transform = transform
            }

            /// Advances to the next element and returns it, or `nil` if exhausted.
            @inlinable
            public mutating func next() -> Bound? {
                guard current < end else { return nil }
                let result = transform(current)
                // Proof: current < end, so current + 1 <= end
                current = current + .one
                return result
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
        /// var range = Range.Lazy(count: try .init(5)) { position in
        ///     Index<Node>(__unchecked: (), position.position)
        /// }
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
            var start: Range.Index

            @usableFromInline
            var end: Range.Index

            @Inlined public var count: Range.Index.Count

            @usableFromInline
            let transform: @Sendable (Range.Index) -> Bound

            /// Iterator for `Range.Lazy.Reversed`.
            ///
            /// Uses a check-before-decrement pattern with an `exhausted` flag
            /// to avoid underflow when reaching index zero.
            public struct Iterator: ~Copyable {
                @usableFromInline
                var current: Range.Index

                @usableFromInline
                let start: Range.Index

                @usableFromInline
                let transform: @Sendable (Range.Index) -> Bound

                @usableFromInline
                var exhausted: Bool

                /// Creates an iterator from range bounds.
                ///
                /// Derives exhaustion from the range: empty (start == end) means
                /// immediately exhausted; non-empty means current = end - 1.
                @inlinable
                init(start: Range.Index, end: Range.Index, transform: @escaping @Sendable (Range.Index) -> Bound) {
                    self.start = start
                    self.transform = transform

                    if start == end {
                        // Empty range: exhausted immediately
                        self.current = start  // arbitrary but stable
                        self.exhausted = true
                    } else {
                        // Non-empty: start at end - 1
                        // Safe: start < end, so end > 0
                        self.current = try! end.predecessor.exact()
                        self.exhausted = false
                    }
                }

                /// Advances to the next element and returns it, or `nil` if exhausted.
                @inlinable
                public mutating func next() -> Bound? {
                    guard !exhausted else { return nil }

                    let result = transform(current)

                    if current == start {
                        exhausted = true
                    } else {
                        // Safe: current > start >= 0, so current > 0
                        current = try! current.predecessor.exact()
                    }

                    return result
                }
            }

            @usableFromInline
            init(
                start: Range.Index,
                end: Range.Index,
                count: Range.Index.Count,
                transform: @escaping @Sendable (Range.Index) -> Bound
            ) {
                self.start = start
                self.end = end
                self.count = count
                self.transform = transform
            }

            /// Internal unchecked initializer for operations that have already validated bounds.
            @usableFromInline
            init(__unchecked: Void, start: Range.Index, end: Range.Index, transform: @escaping @Sendable (Range.Index) -> Bound) {
                self.start = start
                self.end = end
                // Safe: caller guarantees end >= start, so distance.forward never throws
                self.count = Range.Index.Count(try! start.position.distance.forward(to: end.position))
                self.transform = transform
            }

            /// A Boolean value indicating whether the range is empty.
            @inlinable
            public var isEmpty: Bool { count == .zero }

            /// Returns an iterator over the range elements in reverse order.
            ///
            /// The range is consumed by this operation.
            @inlinable
            public consuming func makeIterator() -> Iterator {
                Iterator(start: start, end: end, transform: transform)
            }

            // MARK: - Internal Iteration

            @inlinable
            mutating func _borrowingForEach<E: Swift.Error>(_ body: (borrowing Bound) throws(E) -> Void) throws(E) {
                guard !isEmpty else { return }
                // Safe: !isEmpty means end > start >= 0, so end > 0
                var i = try! end.predecessor.exact()
                while i >= start {
                    let bound = transform(i)
                    try body(bound)
                    if i == start { break }
                    // Safe: i > start >= 0, so i > 0
                    i = try! i.predecessor.exact()
                }
            }

            @inlinable
            mutating func _consumingDrain(_ body: (consuming Bound) -> Void) {
                guard !isEmpty else { return }
                // Safe: !isEmpty means end > start >= 0, so end > 0
                var i = try! end.predecessor.exact()
                while i >= start {
                    body(transform(i))
                    if i == start { break }
                    // Safe: i > start >= 0, so i > 0
                    i = try! i.predecessor.exact()
                }
                // Mark as empty
                start = end
                count = .zero
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
            /// var reversed = Range.Lazy(count: try .init(10)) { $0 }.reversed()
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

        /// Creates a lazy range from zero to count.
        ///
        /// This is the canonical constructor for zero-based ranges.
        ///
        /// - Parameters:
        ///   - count: The number of elements in the range.
        ///   - transform: A function that converts a range position to the bound type.
        @inlinable
        public init(
            count: Range.Index.Count,
            transform: @escaping @Sendable (Range.Index) -> Bound
        ) {
            self.start = .zero
            self.end = .zero + count
            self.count = count
            self.transform = transform
        }

        /// Creates a lazy range with explicit bounds.
        ///
        /// - Parameters:
        ///   - start: The start index (inclusive).
        ///   - end: The end index (exclusive).
        ///   - transform: A function that converts a range position to the bound type.
        /// - Throws: `Range.Error.invalidBounds` if start > end.
        @inlinable
        public init(
            start: Range.Index,
            end: Range.Index,
            transform: @escaping @Sendable (Range.Index) -> Bound
        ) throws(Range.Error) {
            guard start <= end else {
                throw .invalidBounds(start: start, end: end)
            }
            self.start = start
            self.end = end
            // Safe after validation: end >= start, so distance.forward never throws
            self.count = Range.Index.Count(try! start.position.distance.forward(to: end.position))
            self.transform = transform
        }

        /// Internal unchecked initializer for operations that have already validated bounds.
        ///
        /// Used by Drop/Prefix operations to construct adjusted ranges in O(1).
        @usableFromInline
        package init(
            __unchecked: Void,
            start: Range.Index,
            end: Range.Index,
            transform: @escaping @Sendable (Range.Index) -> Bound
        ) {
            self.start = start
            self.end = end
            // Safe: caller guarantees end >= start, so distance.forward never throws
            self.count = Range.Index.Count(try! start.position.distance.forward(to: end.position))
            self.transform = transform
        }

        // MARK: - Properties


        /// A Boolean value indicating whether the range is empty.
        @inlinable
        public var isEmpty: Bool { count == .zero }

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
        /// var range = Range.Lazy(count: try .init(5)) { position in
        ///     Index<Node>(__unchecked: (), position.position)
        /// }
        /// var reversed = range.reversed()
        /// reversed.forEach { print($0) }
        /// // Prints indices for positions: 4, 3, 2, 1, 0
        /// ```
        @inlinable
        public consuming func reversed() -> Reversed {
            Reversed(start: start, end: end, count: count, transform: transform)
        }

        // MARK: - Internal Iteration

        @inlinable
        mutating func _borrowingForEach<E: Swift.Error>(_ body: (borrowing Bound) throws(E) -> Void) throws(E) {
            var i = start
            while i < end {
                let bound = transform(i)
                try body(bound)
                // Proof: i < end, so i + 1 <= end
                i += .one
            }
        }

        @inlinable
        mutating func _consumingDrain(_ body: (consuming Bound) -> Void) {
            var i = start
            while i < end {
                body(transform(i))
                // Proof: i < end, so i + 1 <= end
                i += .one
            }
            // Mark as empty
            start = end
            count = .zero
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
        /// var range = Range.Lazy(count: try .init(10)) { $0 }
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
