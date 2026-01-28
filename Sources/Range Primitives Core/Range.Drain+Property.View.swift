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

/// Property.View extensions for consuming iteration on `Range.Lazy`.
extension Property.View where Base: ~Copyable, Tag == Range.Drain {

    /// Consuming iteration: `.drain { }`
    ///
    /// Iterates over all elements, passing each with ownership to the closure.
    /// The range is empty after this call.
    ///
    /// ```swift
    /// var range = Range.Lazy(0..<10) { $0 * 2 }
    /// range.drain { consume($0) }
    /// // range is now empty
    /// ```
    ///
    /// - Parameter body: A closure called with each element (ownership transferred).
    @_lifetime(&self)
    @inlinable
    public mutating func callAsFunction<Bound: ~Copyable>(
        _ body: (consuming Bound) -> Void
    ) where Base == Range.Lazy<Bound> {
        unsafe base.pointee._consumingDrain(body)
    }

    /// Consuming iteration on reversed range: `.drain { }`
    ///
    /// Iterates over all elements in reverse order, passing each with ownership.
    /// The range is empty after this call.
    ///
    /// ```swift
    /// var reversed = Range.Lazy(0..<10) { $0 * 2 }.reversed()
    /// reversed.drain { consume($0) }  // Consumes: 18, 16, 14, ..., 0
    /// // reversed is now empty
    /// ```
    ///
    /// - Parameter body: A closure called with each element (ownership transferred).
    @_lifetime(&self)
    @inlinable
    public mutating func callAsFunction<Bound: ~Copyable>(
        _ body: (consuming Bound) -> Void
    ) where Base == Range.Lazy<Bound>.Reversed {
        unsafe base.pointee._consumingDrain(body)
    }
}
