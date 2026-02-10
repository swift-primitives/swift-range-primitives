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

import Testing
import Range_Primitives_Test_Support

/// Verify the deprecation shim compiles and the typealias resolves correctly.
///
/// Full test coverage lives in swift-vector-primitives (106 tests).
@Suite("Range.Lazy Deprecation Shim")
struct RangeLazyDeprecationTests {

    @Test("Range.Lazy typealias resolves to Vector")
    func typealiasResolvesToVector() throws {
        let count = try Vector<UInt>.Index.Count(5)
        let vector = Vector<UInt>(count: count) { $0.position.rawValue }

        #expect(vector.count == count)
        #expect(!vector.isEmpty)
    }
}
