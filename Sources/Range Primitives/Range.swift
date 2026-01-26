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

/// Namespace for range-related types designed for `~Copyable` bounds.
///
/// ## The Index Domain Concept
///
/// `Range.Lazy` operates over a **Copyable index domain** (`Index<Range>`), from which
/// `~Copyable` bounds are generated on demand. This separation is the architectural core:
///
/// | Aspect | Index Domain | Bound Projection |
/// |--------|--------------|------------------|
/// | Type | `Index<Range>` (Copyable) | `Bound: ~Copyable` |
/// | Storage | Stored directly | Never stored |
/// | Count | O(1): cached at init | N/A |
///
/// ## Integration with Affine Primitives
///
/// When `Bound` is `Index<Tag>`, Range.Lazy integrates with the Affine type system:
/// - Subscript access uses `Index<Tag>.Offset` (typed displacement)
/// - Count comparisons use `Index<Tag>.Count`
/// - Bounds are phantom-typed `Index<Tag>` values
///
/// ## Why Range.Lazy Exists
///
/// Swift's `Range<Bound>` requires `Bound: Strideable` for iteration, which implies `Copyable`.
/// `Range.Lazy` provides iteration over `~Copyable` bounds without this limitation.
///
/// ## Lazy vs LazySequence
///
/// Unlike `LazySequence`, which defers traversal of **stored** elements, `Range.Lazy`
/// **generates** values on demand from an integer index domain. No `Bound` values are
/// ever stored — they are created fresh by the transform function at each access.
public enum Range {}

// MARK: - Range.Error

extension Range {
    /// Errors that can occur in range operations.
    public enum Error: Swift.Error, Hashable, Sendable {
        /// The bounds are invalid (start > end).
        case invalidBounds(start: Range.Index, end: Range.Index)
    }
}
