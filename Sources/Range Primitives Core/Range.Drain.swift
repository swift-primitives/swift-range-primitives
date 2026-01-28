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
    /// Tag type for `.drain` property extensions on `Range.Lazy`.
    ///
    /// Use this tag with `Property.View` to enable consuming iteration
    /// via the `.drain { }` pattern, consistent with Sequence and Collection primitives.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// var range = Range.Lazy(0..<10) { Index(__unchecked: (), position: $0) }
    ///
    /// // Consuming iteration (elements passed with ownership)
    /// range.drain { index in
    ///     consume(index)
    /// }
    /// // range is now empty
    /// ```
    ///
    /// ## Drain Semantics
    ///
    /// Unlike borrowing iteration, draining:
    /// - Passes elements with ownership to the closure
    /// - Empties the range after iteration
    /// - The range survives but is in an empty state
    ///
    /// ## Available Operations
    ///
    /// | Operation | Description |
    /// |-----------|-------------|
    /// | `.drain { }` | Consuming iteration via `callAsFunction` |
    public enum Drain {}
}
