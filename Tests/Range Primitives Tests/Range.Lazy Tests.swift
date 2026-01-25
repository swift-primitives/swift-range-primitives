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

@testable import Range_Primitives
import Sequence_Primitives

// MARK: - Test Structure

enum RangeLazyTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Performance {}
}

// MARK: - Unit Tests

extension RangeLazyTests.Unit {

    @Test("init creates range with correct bounds")
    func initWithBounds() {
        let range = Range.Lazy(0..<10) { $0 }
        #expect(range.count == 10)
        #expect(!range.isEmpty)
    }

    @Test("count property returns correct value")
    func countProperty() {
        let range = Range.Lazy(5..<15) { $0 }
        #expect(range.count == 10)
    }

    @Test("isEmpty returns true for empty range")
    func isEmptyTrue() {
        let range = Range.Lazy(5..<5) { $0 }
        #expect(range.isEmpty)
        #expect(range.count == 0)
    }

    @Test("isEmpty returns false for non-empty range")
    func isEmptyFalse() {
        let range = Range.Lazy(0..<1) { $0 }
        #expect(!range.isEmpty)
    }

    @Test("transform applies correctly")
    func transformApplies() {
        var range = Range.Lazy(0..<5) { $0 * 2 }
        var results: [Int] = []
        range.forEach { results.append($0) }
        #expect(results == [0, 2, 4, 6, 8])
    }

    @Test("makeIterator produces correct sequence")
    func makeIterator() {
        let range = Range.Lazy(0..<3) { $0 + 10 }
        var iterator = range.makeIterator()
        #expect(iterator.next() == 10)
        #expect(iterator.next() == 11)
        #expect(iterator.next() == 12)
        #expect(iterator.next() == nil)
    }

    @Test("reversed produces elements in reverse order")
    func reversed() {
        var range = Range.Lazy(0..<5) { $0 }
        var reversed = range.reversed()
        var results: [Int] = []
        reversed.forEach { results.append($0) }
        #expect(results == [4, 3, 2, 1, 0])
    }

    // MARK: - Sequence.Protocol Conformance Tests

    @Test("satisfies.all returns true when all match")
    func satisfiesAllTrue() {
        var range = Range.Lazy(0..<10) { $0 }
        #expect(range.satisfies.all { $0 >= 0 })
    }

    @Test("satisfies.all returns false when one doesn't match")
    func satisfiesAllFalse() {
        var range = Range.Lazy(0..<10) { $0 }
        #expect(!range.satisfies.all { $0 > 5 })
    }

    @Test("satisfies.any returns true when one matches")
    func satisfiesAnyTrue() {
        var range = Range.Lazy(0..<10) { $0 }
        #expect(range.satisfies.any { $0 == 5 })
    }

    @Test("satisfies.any returns false when none match")
    func satisfiesAnyFalse() {
        var range = Range.Lazy(0..<10) { $0 }
        #expect(!range.satisfies.any { $0 > 100 })
    }

    @Test("satisfies.none returns true when none match")
    func satisfiesNoneTrue() {
        var range = Range.Lazy(0..<10) { $0 }
        #expect(range.satisfies.none { $0 < 0 })
    }

    @Test("satisfies.none returns false when one matches")
    func satisfiesNoneFalse() {
        var range = Range.Lazy(0..<10) { $0 }
        #expect(!range.satisfies.none { $0 == 5 })
    }

    @Test("first returns matching element")
    func firstMatching() {
        var range = Range.Lazy(0..<10) { $0 * 2 }
        let result = range.first { $0 > 10 }
        #expect(result == 12)
    }

    @Test("first returns nil when no match")
    func firstNoMatch() {
        var range = Range.Lazy(0..<10) { $0 }
        let result = range.first { $0 > 100 }
        #expect(result == nil)
    }

    @Test("count(where:) returns correct count")
    func countWhere() {
        var range = Range.Lazy(0..<10) { $0 }
        let evenCount = range.count(where: { $0 % 2 == 0 })
        #expect(evenCount == 5)
    }

    @Test("reduce.into accumulates correctly")
    func reduceInto() {
        var range = Range.Lazy(1..<6) { $0 }
        let sum = range.reduce.into(0) { $0 += $1 }
        #expect(sum == 15)
    }

    @Test("reduce.from combines correctly")
    func reduceFrom() {
        var range = Range.Lazy(1..<5) { $0 }
        let product = range.reduce.from(1) { $0 * $1 }
        #expect(product == 24)
    }

    @Test("contains returns true when predicate matches")
    func containsTrue() {
        var range = Range.Lazy(0..<10) { $0 }
        #expect(range.contains { $0 == 7 })
    }

    @Test("contains returns false when predicate doesn't match")
    func containsFalse() {
        var range = Range.Lazy(0..<10) { $0 }
        #expect(!range.contains { $0 == 100 })
    }
}

// MARK: - Edge Case Tests

extension RangeLazyTests.EdgeCase {

    @Test("empty range forEach does nothing")
    func emptyRangeForEach() {
        var range = Range.Lazy(0..<0) { $0 }
        var count = 0
        range.forEach { _ in count += 1 }
        #expect(count == 0)
    }

    @Test("empty range satisfies.all returns true")
    func emptyRangeSatisfiesAll() {
        var range = Range.Lazy(0..<0) { $0 }
        #expect(range.satisfies.all { _ in false })
    }

    @Test("empty range satisfies.any returns false")
    func emptyRangeSatisfiesAny() {
        var range = Range.Lazy(0..<0) { $0 }
        #expect(!range.satisfies.any { _ in true })
    }

    @Test("empty range first returns nil")
    func emptyRangeFirst() {
        var range = Range.Lazy(0..<0) { $0 }
        #expect(range.first { _ in true } == nil)
    }

    @Test("empty range count(where:) returns zero")
    func emptyRangeCountWhere() {
        var range = Range.Lazy(0..<0) { $0 }
        #expect(range.count(where: { _ in true }) == 0)
    }

    @Test("single element range works correctly")
    func singleElementRange() {
        var range = Range.Lazy(0..<1) { $0 * 10 }
        #expect(range.count == 1)
        #expect(range.first { _ in true } == 0)

        var results: [Int] = []
        range.forEach { results.append($0) }
        #expect(results == [0])
    }

    @Test("large range count is efficient (O(1))")
    func largeRangeCount() {
        let range = Range.Lazy(0..<1_000_000) { $0 }
        #expect(range.count == 1_000_000)
    }

    @Test("negative transform values work")
    func negativeTransform() {
        var range = Range.Lazy(0..<5) { -$0 }
        var results: [Int] = []
        range.forEach { results.append($0) }
        #expect(results == [0, -1, -2, -3, -4])
    }
}

// MARK: - Reversed Tests

enum RangeLazyReversedTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

extension RangeLazyReversedTests.Unit {

    @Test("reversed count matches original")
    func reversedCount() {
        let range = Range.Lazy(0..<10) { $0 }
        let reversed = range.reversed()
        #expect(reversed.count == 10)
    }

    @Test("reversed isEmpty matches original")
    func reversedIsEmpty() {
        let range = Range.Lazy(5..<5) { $0 }
        let reversed = range.reversed()
        #expect(reversed.isEmpty)
    }

    @Test("reversed iterator produces correct order")
    func reversedIterator() {
        let range = Range.Lazy(0..<3) { $0 }
        let reversed = range.reversed()
        var iterator = reversed.makeIterator()
        #expect(iterator.next() == 2)
        #expect(iterator.next() == 1)
        #expect(iterator.next() == 0)
        #expect(iterator.next() == nil)
    }

    @Test("reversed satisfies.all works correctly")
    func reversedSatisfiesAll() {
        let range = Range.Lazy(0..<10) { $0 }
        var reversed = range.reversed()
        #expect(reversed.satisfies.all { $0 >= 0 && $0 < 10 })
    }

    @Test("reversed first finds from end")
    func reversedFirst() {
        let range = Range.Lazy(0..<10) { $0 }
        var reversed = range.reversed()
        let result = reversed.first { $0 < 5 }
        #expect(result == 4)
    }

    @Test("reversed count(where:) works correctly")
    func reversedCountWhere() {
        let range = Range.Lazy(0..<10) { $0 }
        var reversed = range.reversed()
        #expect(reversed.count(where: { $0 % 2 == 0 }) == 5)
    }

    @Test("reversed reduce.into accumulates in reverse order")
    func reversedReduceInto() {
        let range = Range.Lazy(1..<4) { $0 }
        var reversed = range.reversed()
        var order: [Int] = []
        _ = reversed.reduce.into(0) { acc, val in
            order.append(val)
            acc += val
        }
        #expect(order == [3, 2, 1])
    }
}

extension RangeLazyReversedTests.EdgeCase {

    @Test("empty reversed range works")
    func emptyReversed() {
        let range = Range.Lazy(0..<0) { $0 }
        var reversed = range.reversed()
        #expect(reversed.isEmpty)
        #expect(reversed.count == 0)
        #expect(reversed.first { _ in true } == nil)
    }

    @Test("single element reversed works")
    func singleElementReversed() {
        let range = Range.Lazy(0..<1) { $0 * 5 }
        var reversed = range.reversed()
        #expect(reversed.count == 1)
        var results: [Int] = []
        reversed.forEach { results.append($0) }
        #expect(results == [0])
    }
}
