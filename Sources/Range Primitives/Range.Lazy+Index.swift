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

public import Index_Primitives

// MARK: - Typed Subscript for Index Bounds

extension Range.Lazy {
    /// Returns the index at the given typed offset from start.
    ///
    /// This subscript uses `Index<Tag>.Offset` for type-safe access when
    /// the bound type is `Index<Tag>`.
    ///
    /// This is a **generative** subscript: each access calls the transform
    /// function and produces a fresh `Index<Tag>` value. No caching occurs.
    ///
    /// - Important: The offset must be non-negative and less than `count`.
    ///   Repeated subscripting at the same offset regenerates the value.
    ///
    /// - Precondition: `offset.rawValue >= 0 && offset.rawValue < count`
    @inlinable
    public subscript<Tag: ~Copyable>(offset: Index<Tag>.Offset) -> Index<Tag>
    where Bound == Index<Tag> {
        precondition(offset.rawValue >= 0, "Offset must be non-negative")
        precondition(offset.rawValue < count, "Offset out of bounds")
        return transform(start + offset.rawValue)
    }
}

// MARK: - Typed Subscript for Reversed Index Bounds

extension Range.Lazy.Reversed {
    /// Returns the index at the given typed offset from the reversed start.
    ///
    /// - Important: This regenerates the value; no caching occurs.
    /// - Precondition: `offset.rawValue >= 0 && offset.rawValue < count`
    @inlinable
    public subscript<Tag: ~Copyable>(offset: Index<Tag>.Offset) -> Index<Tag>
    where Bound == Index<Tag> {
        precondition(offset.rawValue >= 0, "Offset must be non-negative")
        precondition(offset.rawValue < count, "Offset out of bounds")
        return transform(end - 1 - offset.rawValue)
    }
}
