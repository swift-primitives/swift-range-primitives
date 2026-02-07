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

/// Property extensions for borrowing iteration on `Range.Lazy`.
///
/// These extensions work on owned `Property` (not `.View`) because `forEach`
/// is read-only traversal that doesn't need to mutate the range. This enables
/// fluent usage on temporaries: `(0..<count).forEach { }`.
extension Property where Tag == Range_Primitives_Core.Range.ForEach {

    /// Borrowing iteration: `.forEach { }`
    ///
    /// Iterates over all elements, borrowing each to the closure.
    ///
    /// ```swift
    /// (0..<count).forEach { print($0) }
    /// ```
    ///
    /// - Parameter body: A closure called with each element as a borrowed value.
    /// - Throws: Rethrows any error thrown by the closure.
    @inlinable
    public func callAsFunction<Bound: ~Copyable, E: Swift.Error>(
        _ body: (borrowing Bound) throws(E) -> Void
    ) throws(E) where Base == Range.Lazy<Bound> {
        var copy = base
        try copy._borrowingForEach(body)
    }

    /// Explicit borrowing iteration: `.forEach.borrowing { }`
    ///
    /// Same as `callAsFunction`, but with explicit naming for clarity.
    ///
    /// ```swift
    /// (0..<count).forEach.borrowing { print($0) }
    /// ```
    ///
    /// - Parameter body: A closure called with each element as a borrowed value.
    /// - Throws: Rethrows any error thrown by the closure.
    @inlinable
    public func borrowing<Bound: ~Copyable, E: Swift.Error>(
        _ body: (borrowing Bound) throws(E) -> Void
    ) throws(E) where Base == Range.Lazy<Bound> {
        var copy = base
        try copy._borrowingForEach(body)
    }

    /// Borrowing iteration on reversed range: `.forEach { }`
    ///
    /// ```swift
    /// range.reversed().forEach { print($0) }  // Prints in reverse order
    /// ```
    ///
    /// - Parameter body: A closure called with each element as a borrowed value.
    /// - Throws: Rethrows any error thrown by the closure.
    @inlinable
    public func callAsFunction<Bound: ~Copyable, E: Swift.Error>(
        _ body: (borrowing Bound) throws(E) -> Void
    ) throws(E) where Base == Range.Lazy<Bound>.Reversed {
        var copy = base
        try copy._borrowingForEach(body)
    }

    /// Explicit borrowing iteration on reversed range: `.forEach.borrowing { }`
    ///
    /// - Parameter body: A closure called with each element as a borrowed value.
    /// - Throws: Rethrows any error thrown by the closure.
    @inlinable
    public func borrowing<Bound: ~Copyable, E: Swift.Error>(
        _ body: (borrowing Bound) throws(E) -> Void
    ) throws(E) where Base == Range.Lazy<Bound>.Reversed {
        var copy = base
        try copy._borrowingForEach(body)
    }
}
