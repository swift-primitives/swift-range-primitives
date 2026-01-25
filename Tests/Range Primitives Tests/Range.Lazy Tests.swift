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

// MARK: - Invariant Tests (Brutal)

enum RangeLazyInvariantTests {
    @Suite struct Iterator {}
    @Suite struct Consistency {}
    @Suite struct Drain {}
    @Suite struct Symmetry {}
    @Suite struct Boundaries {}
}

// MARK: - Iterator Invariants

extension RangeLazyInvariantTests.Iterator {

    @Test("INVARIANT: Iterator returns nil forever after exhaustion")
    func iteratorExhaustion() {
        let range = Range.Lazy(0..<3) { $0 }
        var iterator = range.makeIterator()

        // Exhaust the iterator
        _ = iterator.next()
        _ = iterator.next()
        _ = iterator.next()

        // Must return nil forever
        for _ in 0..<100 {
            #expect(iterator.next() == nil)
        }
    }

    @Test("INVARIANT: Reversed iterator returns nil forever after exhaustion")
    func reversedIteratorExhaustion() {
        let range = Range.Lazy(0..<3) { $0 }
        var iterator = range.reversed().makeIterator()

        // Exhaust
        _ = iterator.next()
        _ = iterator.next()
        _ = iterator.next()

        // Must return nil forever
        for _ in 0..<100 {
            #expect(iterator.next() == nil)
        }
    }

    @Test("INVARIANT: Empty iterator returns nil immediately and forever")
    func emptyIteratorAlwaysNil() {
        let range = Range.Lazy(0..<0) { $0 }
        var iterator = range.makeIterator()

        for _ in 0..<100 {
            #expect(iterator.next() == nil)
        }
    }

    @Test("INVARIANT: Iterator count matches range.count exactly")
    func iteratorCountMatchesProperty() {
        for size in [0, 1, 2, 10, 100, 1000] {
            let range = Range.Lazy(0..<size) { $0 }
            var iterator = range.makeIterator()
            var iteratedCount = 0

            while iterator.next() != nil {
                iteratedCount += 1
            }

            #expect(iteratedCount == range.count,
                   "Size \(size): iterated \(iteratedCount) but count is \(range.count)")
        }
    }

    @Test("INVARIANT: Reversed iterator count matches range.count exactly")
    func reversedIteratorCountMatchesProperty() {
        for size in [0, 1, 2, 10, 100, 1000] {
            let range = Range.Lazy(0..<size) { $0 }
            var iterator = range.reversed().makeIterator()
            var iteratedCount = 0

            while iterator.next() != nil {
                iteratedCount += 1
            }

            #expect(iteratedCount == range.count,
                   "Size \(size): reversed iterated \(iteratedCount) but count is \(range.count)")
        }
    }
}

// MARK: - Consistency Invariants

extension RangeLazyInvariantTests.Consistency {

    @Test("INVARIANT: contains(predicate) == (first(predicate) != nil)")
    func containsEqualsFirstNotNil() {
        for size in [0, 1, 5, 20] {
            var range1 = Range.Lazy(0..<size) { $0 }
            var range2 = Range.Lazy(0..<size) { $0 }

            // Test with predicate that matches
            let containsEven = range1.contains { $0 % 2 == 0 }
            let firstEven = range2.first { $0 % 2 == 0 }
            #expect(containsEven == (firstEven != nil),
                   "Size \(size): contains(even) = \(containsEven), first != nil = \(firstEven != nil)")

            // Test with predicate that never matches
            var range3 = Range.Lazy(0..<size) { $0 }
            var range4 = Range.Lazy(0..<size) { $0 }
            let containsNegative = range3.contains { $0 < 0 }
            let firstNegative = range4.first { $0 < 0 }
            #expect(containsNegative == (firstNegative != nil))
        }
    }

    @Test("INVARIANT: satisfies.any(p) == !satisfies.none(p)")
    func satisfiesAnyEqualsNotNone() {
        for size in [0, 1, 5, 20] {
            // Predicate that matches some elements
            var range1 = Range.Lazy(0..<size) { $0 }
            var range2 = Range.Lazy(0..<size) { $0 }
            let anyEven = range1.satisfies.any { $0 % 2 == 0 }
            let noneEven = range2.satisfies.none { $0 % 2 == 0 }
            #expect(anyEven == !noneEven,
                   "Size \(size): any(even) = \(anyEven), none(even) = \(noneEven)")

            // Predicate that matches no elements
            var range3 = Range.Lazy(0..<size) { $0 }
            var range4 = Range.Lazy(0..<size) { $0 }
            let anyNegative = range3.satisfies.any { $0 < 0 }
            let noneNegative = range4.satisfies.none { $0 < 0 }
            #expect(anyNegative == !noneNegative)
        }
    }

    @Test("INVARIANT: satisfies.all(p) implies satisfies.any(p) for non-empty")
    func allImpliesAnyForNonEmpty() {
        for size in [1, 5, 20] {
            var range1 = Range.Lazy(0..<size) { $0 }
            var range2 = Range.Lazy(0..<size) { $0 }

            let allNonNegative = range1.satisfies.all { $0 >= 0 }
            let anyNonNegative = range2.satisfies.any { $0 >= 0 }

            if allNonNegative {
                #expect(anyNonNegative,
                       "Size \(size): all(>=0) is true but any(>=0) is false")
            }
        }
    }

    @Test("INVARIANT: count(where: { true }) == count property")
    func countWhereAlwaysTrueEqualsCount() {
        for size in [0, 1, 5, 100] {
            var range = Range.Lazy(0..<size) { $0 }
            let countWhere = range.count(where: { _ in true })
            #expect(countWhere == size,
                   "Size \(size): count(where: true) = \(countWhere)")
        }
    }

    @Test("INVARIANT: count(where: { false }) == 0")
    func countWhereAlwaysFalseIsZero() {
        for size in [0, 1, 5, 100] {
            var range = Range.Lazy(0..<size) { $0 }
            let countWhere = range.count(where: { _ in false })
            #expect(countWhere == 0,
                   "Size \(size): count(where: false) = \(countWhere)")
        }
    }

    @Test("INVARIANT: reduce.into(initial) { } returns initial for empty range")
    func reduceEmptyReturnsInitial() {
        var range = Range.Lazy(0..<0) { $0 }
        let result = range.reduce.into(42) { acc, _ in acc += 1 }
        #expect(result == 42)
    }

    @Test("INVARIANT: reduce.from(initial) { } returns initial for empty range")
    func reduceFromEmptyReturnsInitial() {
        var range = Range.Lazy(0..<0) { $0 }
        let result = range.reduce.from(42) { _, _ in 0 }
        #expect(result == 42)
    }

    @Test("INVARIANT: Transform is deterministic - same index gives same value")
    func transformDeterminism() {
        let range = Range.Lazy(0..<5) { i in
            i * 7 + 3
        }

        // Iterate multiple times and verify same values
        var results1: [Int] = []
        var results2: [Int] = []

        var iter1 = range.makeIterator()
        while let v = iter1.next() { results1.append(v) }

        var iter2 = range.makeIterator()
        while let v = iter2.next() { results2.append(v) }

        #expect(results1 == results2)
        #expect(results1 == [3, 10, 17, 24, 31])
    }
}

// MARK: - Drain Invariants

extension RangeLazyInvariantTests.Drain {

    @Test("INVARIANT: drain empties the range completely")
    func drainEmptiesRange() {
        var range = Range.Lazy(0..<10) { $0 }
        var drained: [Int] = []

        range.drain { drained.append($0) }

        #expect(drained.count == 10)
        #expect(range.isEmpty)
        #expect(range.count == 0)
    }

    @Test("INVARIANT: drain on empty range does nothing")
    func drainEmptyRange() {
        var range = Range.Lazy(0..<0) { $0 }
        var drainCount = 0

        range.drain { _ in drainCount += 1 }

        #expect(drainCount == 0)
        #expect(range.isEmpty)
    }

    @Test("INVARIANT: double drain yields nothing second time")
    func doubleDrain() {
        var range = Range.Lazy(0..<5) { $0 }
        var first: [Int] = []
        var second: [Int] = []

        range.drain { first.append($0) }
        range.drain { second.append($0) }

        #expect(first == [0, 1, 2, 3, 4])
        #expect(second == [])
    }

    @Test("INVARIANT: reversed drain empties the range completely")
    func reversedDrainEmptiesRange() {
        var range = Range.Lazy(0..<10) { $0 }
        var reversed = range.reversed()
        var drained: [Int] = []

        reversed.drain { drained.append($0) }

        #expect(drained == [9, 8, 7, 6, 5, 4, 3, 2, 1, 0])
        #expect(reversed.isEmpty)
        #expect(reversed.count == 0)
    }
}

// MARK: - Symmetry Invariants

extension RangeLazyInvariantTests.Symmetry {

    @Test("INVARIANT: Forward + Reversed cover all elements exactly once")
    func forwardAndReversedCoverAll() {
        for size in [0, 1, 5, 20] {
            var forward: [Int] = []
            var backward: [Int] = []

            var range1 = Range.Lazy(0..<size) { $0 }
            range1.forEach { forward.append($0) }

            var range2 = Range.Lazy(0..<size) { $0 }
            var reversed = range2.reversed()
            reversed.forEach { backward.append($0) }

            #expect(forward.count == size)
            #expect(backward.count == size)
            #expect(Set(forward) == Set(backward),
                   "Forward and reversed should cover same elements")
            #expect(forward == backward.reversed(),
                   "Reversed should be exact reverse of forward")
        }
    }

    @Test("INVARIANT: reduce forward and reversed give same sum")
    func reduceSymmetry() {
        for size in [0, 1, 5, 20] {
            var range1 = Range.Lazy(0..<size) { $0 }
            let range2 = Range.Lazy(0..<size) { $0 }

            let forwardSum = range1.reduce.into(0) { $0 += $1 }
            var reversed = range2.reversed()
            let backwardSum = reversed.reduce.into(0) { $0 += $1 }

            #expect(forwardSum == backwardSum,
                   "Size \(size): forward sum \(forwardSum) != backward sum \(backwardSum)")
        }
    }

    @Test("INVARIANT: count(where:) same for forward and reversed")
    func countWhereSymmetry() {
        for size in [0, 1, 5, 20] {
            var range1 = Range.Lazy(0..<size) { $0 }
            var range2 = Range.Lazy(0..<size) { $0 }

            let forwardCount = range1.count(where: { $0 % 2 == 0 })
            let backwardCount = range2.reversed().count(where: { $0 % 2 == 0 })

            #expect(forwardCount == backwardCount)
        }
    }

    @Test("INVARIANT: satisfies.all same for forward and reversed")
    func satisfiesAllSymmetry() {
        for size in [0, 1, 5, 20] {
            var range1 = Range.Lazy(0..<size) { $0 }
            let range2 = Range.Lazy(0..<size) { $0 }

            let forwardAll = range1.satisfies.all { $0 >= 0 }
            var reversed = range2.reversed()
            let backwardAll = reversed.satisfies.all { $0 >= 0 }

            #expect(forwardAll == backwardAll)
        }
    }
}

// MARK: - Boundary Invariants

extension RangeLazyInvariantTests.Boundaries {

    @Test("INVARIANT: Offset ranges work correctly")
    func offsetRanges() {
        let range = Range.Lazy(100..<105) { $0 }
        var results: [Int] = []
        var iter = range.makeIterator()
        while let v = iter.next() { results.append(v) }

        #expect(results == [100, 101, 102, 103, 104])
        #expect(range.count == 5)
    }

    @Test("INVARIANT: Large offset ranges work correctly")
    func largeOffsetRanges() {
        let start = 1_000_000
        let range = Range.Lazy(start..<(start + 5)) { $0 }

        #expect(range.count == 5)

        var iter = range.makeIterator()
        #expect(iter.next() == 1_000_000)
        #expect(iter.next() == 1_000_001)
    }

    @Test("INVARIANT: Transform with overflow-safe arithmetic")
    func overflowSafeTransform() {
        // Use transforms that don't overflow
        let range = Range.Lazy(0..<5) { Int.max - 10 + $0 }
        var results: [Int] = []
        var iter = range.makeIterator()
        while let v = iter.next() { results.append(v) }

        #expect(results.count == 5)
        #expect(results[0] == Int.max - 10)
        #expect(results[4] == Int.max - 6)
    }

    @Test("INVARIANT: Negative start ranges work")
    func negativeStartRanges() {
        let range = Range.Lazy(-5..<5) { $0 }
        #expect(range.count == 10)

        var results: [Int] = []
        var iter = range.makeIterator()
        while let v = iter.next() { results.append(v) }

        #expect(results == [-5, -4, -3, -2, -1, 0, 1, 2, 3, 4])
    }

    @Test("INVARIANT: Complex transform maintains invariants")
    func complexTransform() {
        // Transform: triangular numbers
        let range = Range.Lazy(1..<6) { n in n * (n + 1) / 2 }

        var results: [Int] = []
        var iter = range.makeIterator()
        while let v = iter.next() { results.append(v) }

        #expect(results == [1, 3, 6, 10, 15])
        #expect(range.count == 5)
    }

    @Test("INVARIANT: first returns first matching, not any matching")
    func firstReturnsFirstNotAny() {
        var range = Range.Lazy(0..<100) { $0 }
        let result = range.first { $0 > 50 }
        #expect(result == 51, "first should return 51, not any value > 50")
    }

    @Test("INVARIANT: reversed first returns last matching from original")
    func reversedFirstReturnsLast() {
        var range = Range.Lazy(0..<100) { $0 }
        var reversed = range.reversed()
        let result = reversed.first { $0 < 50 }
        #expect(result == 49, "reversed first should return 49 (last element < 50)")
    }
}

// MARK: - Stress Tests

enum RangeLazyStressTests {
    @Suite struct Stress {}
}

extension RangeLazyStressTests.Stress {

    @Test("STRESS: Many small ranges maintain invariants")
    func manySmallRanges() {
        for i in 0..<100 {
            let range = Range.Lazy(i..<(i + 10)) { $0 * 2 }
            #expect(range.count == 10)

            var sum = 0
            var iter = range.makeIterator()
            while let v = iter.next() { sum += v }

            let expected = (i..<(i + 10)).map { $0 * 2 }.reduce(0, +)
            #expect(sum == expected, "Range starting at \(i): sum \(sum) != expected \(expected)")
        }
    }

    @Test("STRESS: Alternating forward/reversed operations")
    func alternatingOperations() {
        for size in [1, 5, 10, 50] {
            var forwardSum = 0
            var reversedSum = 0

            for i in 0..<10 {
                if i % 2 == 0 {
                    var range = Range.Lazy(0..<size) { $0 }
                    forwardSum += range.reduce.into(0) { $0 += $1 }
                } else {
                    let range = Range.Lazy(0..<size) { $0 }
                    var reversed = range.reversed()
                    reversedSum += reversed.reduce.into(0) { $0 += $1 }
                }
            }

            #expect(forwardSum == reversedSum,
                   "Size \(size): forward \(forwardSum) != reversed \(reversedSum)")
        }
    }

    @Test("STRESS: Predicate operations on various sizes")
    func predicateStress() {
        for size in [0, 1, 2, 10, 100, 500] {
            var range1 = Range.Lazy(0..<size) { $0 }
            var range2 = Range.Lazy(0..<size) { $0 }
            var range3 = Range.Lazy(0..<size) { $0 }

            // These should all be consistent
            let countEven = range1.count(where: { $0 % 2 == 0 })
            let anyEven = range2.satisfies.any { $0 % 2 == 0 }
            let allEven = range3.satisfies.all { $0 % 2 == 0 }

            // Verify relationships
            if size == 0 {
                #expect(countEven == 0)
                #expect(!anyEven)
                #expect(allEven) // vacuously true
            } else if size == 1 {
                #expect(countEven == 1) // 0 is even
                #expect(anyEven)
                #expect(allEven) // only 0, which is even
            } else {
                #expect(countEven > 0)
                #expect(anyEven)
                #expect(!allEven) // 1 is odd
            }
        }
    }
}
