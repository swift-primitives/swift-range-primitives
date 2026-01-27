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

// MARK: - Range.Index + Count → Range.Index (Point + Scalar → Point)

/// Advances a range index by a count.
///
/// This operation is total because `Count` is always non-negative.
/// The only failure mode is UInt overflow (which traps).
///
/// - Parameters:
///   - lhs: The range index to advance.
///   - rhs: The count to advance by.
/// - Returns: The advanced range index.
@inlinable
public func + (lhs: Range.Index, rhs: Range.Index.Count) -> Range.Index {
    // Total: lhs.position >= 0, rhs.count >= 0, so result >= 0
    Range.Index(__unchecked: (), Ordinal.Position(lhs.position.rawValue + rhs.count.rawValue))
}

/// Advances a range index by a count (commutative).
@inlinable
public func + (lhs: Range.Index.Count, rhs: Range.Index) -> Range.Index {
    rhs + lhs
}

/// Advances a range index by a count in place.
@inlinable
public func += (lhs: inout Range.Index, rhs: Range.Index.Count) {
    lhs = lhs + rhs
}

// MARK: - Clamped Advancement

extension Range.Index {
    /// Advances by a count, clamping to a bound.
    ///
    /// Use this for bounded operations like `drop`/`prefix` where advancing
    /// beyond the end should clamp rather than overflow.
    ///
    /// ```swift
    /// let newStart = base.start.advanced(by: count, clampedTo: base.end)
    /// ```
    ///
    /// - Parameters:
    ///   - count: The count to advance by.
    ///   - bound: The maximum position to clamp to.
    /// - Returns: The advanced position, clamped to `bound` if it would exceed it.
    @inlinable
    public func advanced(by count: Range.Index.Count, clampedTo bound: Range.Index) -> Range.Index {
        let advanced = position.rawValue + count.count.rawValue
        let clamped = Swift.min(advanced, bound.position.rawValue)
        return Range.Index(__unchecked: (), Ordinal.Position(clamped))
    }

    /// Retreats by a count, clamping to a bound.
    ///
    /// Use this for bounded operations where retreating beyond the start
    /// should clamp rather than underflow.
    ///
    /// - Parameters:
    ///   - count: The count to retreat by.
    ///   - bound: The minimum position to clamp to.
    /// - Returns: The retreated position, clamped to `bound` if it would go below it.
    @inlinable
    public func retreated(by count: Range.Index.Count, clampedTo bound: Range.Index) -> Range.Index {
        if count.count.rawValue >= position.rawValue - bound.position.rawValue {
            return bound
        }
        return Range.Index(__unchecked: (), Ordinal.Position(position.rawValue - count.count.rawValue))
    }
}
