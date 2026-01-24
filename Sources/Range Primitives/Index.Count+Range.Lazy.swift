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

/// Creates a lazy range from an integer to a typed count, producing typed indices.
///
/// This operator enables clean iteration patterns with phantom-typed indices:
///
/// ```swift
/// let count: Index<Element>.Count = 10
///
/// // Iterate over indices 0..<10
/// (0..<count).forEach { index in
///     // index is Index<Element>
///     process(storage.read(at: index))
/// }
/// ```
///
/// The returned `Range.Lazy` transforms integer positions into typed indices
/// on-demand, avoiding the need to store `~Copyable` values.
///
/// - Parameters:
///   - lhs: The lower bound (must be 0 or positive).
///   - rhs: The typed count representing the upper bound.
/// - Returns: A lazy range that produces `Index<Tag>` values.
@inlinable
public func ..< <Tag: ~Copyable>(
    lhs: Int,
    rhs: Index<Tag>.Count
) -> Range.Lazy<Index<Tag>> {
    Range.Lazy(lhs..<rhs.rawValue) {
        Index<Tag>(__unchecked: (), position: $0)
    }
}
