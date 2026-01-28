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

public import Range_Primitives
import Index_Primitives_Test_Support

// MARK: - Range.Lazy Convenience Initializer

extension Range.Lazy where Bound == UInt {
    /// Creates a lazy range from a Swift.Range<Int> for testing convenience.
    ///
    /// The transform receives the position as `UInt` for test convenience.
    ///
    /// - Warning: This initializer is for testing only. Production code should
    ///   use the typed `Range.Index` initializers.
    public init(
        _ range: Swift.Range<UInt>,
        transform: @escaping @Sendable (UInt) -> UInt = { $0 }
    ) {
        // Safe: Swift.Range guarantees upperBound >= lowerBound
        self.init(
            __unchecked: (),
            start: Range.Index(__unchecked: (), Ordinal(range.lowerBound)),
            end: Range.Index(__unchecked: (), Ordinal(range.upperBound)),
            transform: { transform($0.position.rawValue) }
        )
    }

    @inlinable
    public init(
        count: Range.Index.Count,
        transform: @escaping @Sendable (Int) -> Bound = { $0.magnitude }
    ) {
        self.init(count: count, transform: \.position.rawValue)
    }

    public init(
        start: Range.Index,
        end: Range.Index,
        transform: @escaping @Sendable (Int) -> Bound = { $0.magnitude }
    ) throws(Range.Error) {
        try self.init(start: start, end: end, transform: \.position.rawValue)
    }
}

extension Range.Error {
    /// Errors for domain-range initialization over Int.
    public enum Int: Swift.Error {
        /// The range count exceeds UInt.max (range too large for ordinal space).
        case countOverflow
    }
}

extension Range.Lazy where Bound == Int {
    /// Creates a lazy range over an integer domain interval.
    ///
    /// This initializer treats `range` as a **domain interval** (e.g., `-500..<500`),
    /// not as ordinal positions. Internally, ordinal positions `0..<count` are used,
    /// with offset translation to produce domain values.
    ///
    /// - Parameters:
    ///   - range: The integer domain interval.
    ///   - transform: A function applied to each domain value.
    /// - Throws: `Range.Error.Int.countOverflow` if the range count exceeds `UInt.max`.
    ///
    /// - Warning: This initializer is for testing only. Production code should
    ///   use the typed `Range.Index` initializers.
    public init(
        _ range: Swift.Range<Swift.Int>,
        transform: @escaping @Sendable (Swift.Int) -> Swift.Int = { $0 }
    ) throws(Range.Error.Int) {
        // Calculate count (guaranteed non-negative by Range invariant)
        let distance = range.upperBound - range.lowerBound

        // Check if count fits in UInt (ordinal space)
        guard distance >= .zero, UInt(bitPattern: distance) <= UInt.max else {
            throw .countOverflow
        }
        let count = UInt(distance)

        // Offset translation: ordinal position -> domain value
        let offset = range.lowerBound

        // Safe: start is .zero and end is count, so end >= start
        self.init(
            __unchecked: (),
            start: Range.Index(__unchecked: (), .zero),
            end: Range.Index(__unchecked: (), Ordinal(count)),
            transform: { transform(offset + Swift.Int(bitPattern: $0.position.rawValue)) }
        )
    }
}
