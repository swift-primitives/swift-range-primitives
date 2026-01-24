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

extension Range {
    /// A lazy range that produces `~Copyable` bounds on-demand.
    ///
    /// `Range.Lazy` stores integer bounds internally and applies a transformation
    /// function to produce typed bounds. This enables range-based iteration over
    /// `~Copyable` types without requiring `Sequence` conformance.
    ///
    /// ## Iteration Patterns
    ///
    /// Since `~Copyable` types cannot conform to `Sequence`, use closure-based
    /// iteration instead of `for-in`:
    ///
    /// ```swift
    /// let range = Range.Lazy(0..<count) { Index(__unchecked: (), position: $0) }
    ///
    /// // Borrowing iteration
    /// range.forEach { index in
    ///     print(index)
    /// }
    ///
    /// // Consuming iteration
    /// range.drain { index in
    ///     consume(index)
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
    /// The `Iterator` type is declared inline (not in an extension) so that it
    /// properly inherits the `~Copyable` constraint from `Bound`. This matches
    /// the pattern used by `Array.Static` and `Array.Storage`.
    public struct Lazy<Bound: ~Copyable>: ~Copyable {
        @usableFromInline
        let start: Int

        @usableFromInline
        let end: Int

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

        // MARK: - Properties

        /// The number of elements in the range.
        @inlinable
        public var count: Int { end - start }

        /// A Boolean value indicating whether the range is empty.
        @inlinable
        public var isEmpty: Bool { start >= end }

        // MARK: - Iteration Methods

        /// Returns an iterator over the range elements.
        ///
        /// The range is consumed by this operation.
        @inlinable
        public consuming func makeIterator() -> Iterator {
            Iterator(current: start, end: end, transform: transform)
        }

        /// Calls the given closure on each element in the range.
        ///
        /// The closure receives each element as a borrowed value.
        /// The range is consumed by this operation.
        ///
        /// - Parameter body: A closure that takes a borrowed element.
        @inlinable
        public consuming func forEach(_ body: (borrowing Bound) -> Void) {
            for i in start..<end {
                let bound = transform(i)
                body(bound)
            }
        }

        /// Calls the given closure on each element, consuming each element.
        ///
        /// The closure receives each element as an owned value.
        /// The range is consumed by this operation.
        ///
        /// - Parameter body: A closure that takes ownership of each element.
        @inlinable
        public consuming func drain(_ body: (consuming Bound) -> Void) {
            for i in start..<end {
                body(transform(i))
            }
        }
    }
}

// MARK: - Sendable

extension Range.Lazy: Sendable where Bound: Sendable {}
extension Range.Lazy.Iterator: Sendable where Bound: Sendable {}
