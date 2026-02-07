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

extension Range_Primitives_Core.Range {
    /// Tag type for `.forEach` property extensions on `Range.Lazy`.
    ///
    /// Use this tag with `Property.View` to enable borrowing iteration
    /// via the `.forEach { }` pattern, consistent with Sequence and Collection primitives.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// var range = Range.Lazy(0..<10) { Index(__unchecked: (), position: $0) }
    ///
    /// // Borrowing iteration (elements borrowed, range survives)
    /// range.forEach { index in
    ///     print(index)
    /// }
    ///
    /// // Explicit borrowing form
    /// range.forEach.borrowing { index in
    ///     print(index)
    /// }
    /// ```
    ///
    /// ## Available Operations
    ///
    /// | Operation | Description |
    /// |-----------|-------------|
    /// | `.forEach { }` | Borrowing iteration via `callAsFunction` |
    /// | `.forEach.borrowing { }` | Explicit borrowing iteration |
    public enum ForEach {}
}
