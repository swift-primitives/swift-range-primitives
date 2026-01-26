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

extension Range.Lazy where Bound == Int {
    /// Creates a lazy range from a Swift.Range<Int> for testing convenience.
    ///
    /// - Warning: This initializer is for testing only. Production code should
    ///   use the typed `Range.Index` initializers.
//    @available(*, deprecated, message: "Test convenience only. Use typed Range.Index initializers in production.")
    @_disfavoredOverload
    public init(
        _ range: Swift.Range<Int>,
        transform: @escaping @Sendable (Range.Index) -> Int
    ) {
        self.init(
            __unchecked: (),
            start: Range.Index(__unchecked: (), range.lowerBound),
            end: Range.Index(__unchecked: (), range.upperBound),
            transform: { transform($0) }
        )
    }
    
//    @available(*, deprecated, message: "Test convenience only. Use typed Range.Index initializers in production.")
    @_disfavoredOverload
    public init(
        _ range: Swift.Range<Int>,
        transform: @escaping @Sendable (Int) -> Int
    ) {
        self.init(
            __unchecked: (),
            start: Range.Index(__unchecked: (), range.lowerBound),
            end: Range.Index(__unchecked: (), range.upperBound),
            transform: { transform($0.position.rawValue) }
        )
    }

    /// Creates a lazy range from a Swift.Range<Int> with identity transform.
    ///
    /// - Warning: This initializer is for testing only.
//    @available(*, deprecated, message: "Test convenience only. Use typed Range.Index initializers in production.")
    @_disfavoredOverload
    public init(
        _ range: Swift.Range<Int>
    ) {
        self.init(
            __unchecked: (),
            start: Range.Index(__unchecked: (), range.lowerBound),
            end: Range.Index(__unchecked: (), range.upperBound),
            transform: { $0.position.rawValue }
        )
    }
}

// MARK: - Range.Index.Count Comparison with Int

//extension Range.Index.Count {
//    /// Compares count with an integer for testing convenience.
////    @available(*, deprecated, message: "Test convenience only. Use typed comparisons in production.")
//    @_disfavoredOverload
//    public static func == (lhs: Self, rhs: Int) -> Bool {
//        lhs.rawValue == rhs
//    }
//
//    /// Compares count with an integer for testing convenience.
////    @available(*, deprecated, message: "Test convenience only. Use typed comparisons in production.")
//    @_disfavoredOverload
//    public static func == (lhs: Int, rhs: Self) -> Bool {
//        lhs == rhs.rawValue
//    }
//}

//// MARK: - Range.Index.Count ExpressibleByIntegerLiteral
//
//extension Range.Index.Count: ExpressibleByIntegerLiteral {
//    @available(*, deprecated, message: "Literal initialization bypasses validation. Use typed initializers.")
//    @_disfavoredOverload
//    public init(integerLiteral value: Int) {
//        self.init(__unchecked: (), value)
//    }
//}
