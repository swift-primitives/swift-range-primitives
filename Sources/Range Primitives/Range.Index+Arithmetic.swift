//// ===----------------------------------------------------------------------===//
////
//// This source file is part of the swift-primitives open source project
////
//// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
//// Licensed under Apache License v2.0
////
//// See LICENSE for license information
////
//// ===----------------------------------------------------------------------===//
//
//public import Index_Primitives
//
//// MARK: - Clamped Advancement
////
//// Note: Basic arithmetic (Range.Index + Range.Index.Count, etc.) is provided by
//// Ordinal Primitives via Tagged<Tag, Ordinal> + Tagged<Tag, Cardinal> extensions.
//
//extension Range.Index {
//    /// Advances by a count, clamping to a bound.
//    ///
//    /// Use this for bounded operations like `drop`/`prefix` where advancing
//    /// beyond the end should clamp rather than overflow.
//    ///
//    /// ```swift
//    /// let newStart = base.start.advanced(by: count, clampedTo: base.end)
//    /// ```
//    ///
//    /// - Parameters:
//    ///   - count: The count to advance by.
//    ///   - bound: The maximum position to clamp to.
//    /// - Returns: The advanced position, clamped to `bound` if it would exceed it.
//    @inlinable
//    public func advanced(by count: Range.Index.Count, clampedTo bound: Range.Index) -> Range.Index {
//        self.advance.clamped(by: count, to: bound)
//    }
//
//    /// Retreats by a count, clamping to a bound.
//    ///
//    /// Use this for bounded operations where retreating beyond the start
//    /// should clamp rather than underflow.
//    ///
//    /// - Parameters:
//    ///   - count: The count to retreat by.
//    ///   - bound: The minimum position to clamp to.
//    /// - Returns: The retreated position, clamped to `bound` if it would go below it.
//    @inlinable
//    public func retreated(by count: Range.Index.Count, clampedTo bound: Range.Index) -> Range.Index {
//        self.retreat.clamped(by: count, to: bound)
//    }
//}
