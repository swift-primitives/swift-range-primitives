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

/// Creates a lazy range from an index to a typed count, producing typed indices.
///
/// This operator enables clean iteration patterns with phantom-typed indices:
///
/// ```swift
/// let count = try Index<Element>.Count(10)
///
/// // Iterate over indices 0..<10
/// (.zero..<count).forEach { index in
///     // index is Index<Element>
///     process(storage.read(at: index))
/// }
/// ```
///
/// The returned `Range.Lazy` transforms range positions into typed indices
/// on-demand, avoiding the need to store `~Copyable` values.
///
/// - Parameters:
///   - lhs: The lower bound (typed index).
///   - rhs: The typed count representing the upper bound.
/// - Returns: A lazy range that produces `Index<Tag>` values.
@inlinable
public func ..< <Tag: ~Copyable>(
    lhs: Index<Tag>,
    rhs: Index<Tag>.Count
) -> Range.Lazy<Index<Tag>> {
    let start = Range.Index(lhs)
    let end = Range.Index(rhs)
    // Index and Count are both non-negative, and Index < Count is the expected pattern
    // No validation needed - start is always <= end when lhs.position <= rhs (count as position)
    return Range.Lazy(
        __unchecked: (),
        start: start,
        end: end,
        transform: { Index<Tag>($0) }
    )
}
