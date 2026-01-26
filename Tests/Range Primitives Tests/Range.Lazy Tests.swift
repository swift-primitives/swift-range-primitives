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
@testable import Range_Primitives

// MARK: - Test Structure


enum RangeLazyTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Performance {}
}

// MARK: - Unit Tests

extension RangeLazyTests.Unit {

    @Test
    func `init creates range with correct bounds`() {
        let range: Range.Lazy = Range.Lazy(0..<10) { $0 }
        #expect(range.count == 10)
        #expect(!range.isEmpty)
    }

    @Test
    func `count property returns correct value`() {
        let range = Range.Lazy(5..<15) { $0 }
        #expect(range.count == 10)
    }

    @Test
    func `isEmpty returns true for empty range`() {
        let range = Range.Lazy(5..<5) { $0 }
        #expect(range.isEmpty)
        #expect(range.count == 0)
    }

    @Test
    func `isEmpty returns false for non-empty range`() {
        let range = Range.Lazy(0..<1) { $0 }
        #expect(!range.isEmpty)
    }

    @Test
    func `transform applies correctly`() {
        let range = Range.Lazy(0..<5) { $0 * 2 }
        var results: [Int] = []
        range.forEach { results.append($0) }
        #expect(results == [0, 2, 4, 6, 8])
    }

    @Test
    func `makeIterator produces correct sequence`() {
        let range = Range.Lazy(0..<3) { $0 + 10 }
        var iterator = range.makeIterator()
        #expect(iterator.next() == 10)
        #expect(iterator.next() == 11)
        #expect(iterator.next() == 12)
        #expect(iterator.next() == nil)
    }

    @Test
    func `reversed produces elements in reverse order`() {
        let range = Range.Lazy(0..<5) { $0 }
        let reversed = range.reversed()
        var results: [Int] = []
        reversed.forEach { results.append($0) }
        #expect(results == [4, 3, 2, 1, 0])
    }

    // MARK: - Sequence.Protocol Conformance Tests

    @Test
    func `satisfies.all returns true when all match`() {
        var range = Range.Lazy(0..<10) { $0 }
        #expect(range.satisfies.all { $0 >= 0 })
    }

    @Test
    func `satisfies.all returns false when one doesn't match`() {
        var range = Range.Lazy(0..<10) { $0 }
        #expect(!range.satisfies.all { $0 > 5 })
    }

    @Test
    func `satisfies.any returns true when one matches`() {
        var range = Range.Lazy(0..<10) { $0 }
        #expect(range.satisfies.any { $0 == 5 })
    }

    @Test
    func `satisfies.any returns false when none match`() {
        var range = Range.Lazy(0..<10) { $0 }
        #expect(!range.satisfies.any { $0 > 100 })
    }

    @Test
    func `satisfies.none returns true when none match`() {
        var range = Range.Lazy(0..<10) { $0 }
        #expect(range.satisfies.none { $0 < 0 })
    }

    @Test
    func `satisfies.none returns false when one matches`() {
        var range = Range.Lazy(0..<10) { $0 }
        #expect(!range.satisfies.none { $0 == 5 })
    }

    @Test
    func `first returns matching element`() {
        var range = Range.Lazy(0..<10) { $0 * 2 }
        let result = range.first { $0 > 10 }
        #expect(result == 12)
    }

    @Test
    func `first returns nil when no match`() {
        var range = Range.Lazy(0..<10) { $0 }
        let result = range.first { $0 > 100 }
        #expect(result == nil)
    }

    @Test
    func `count(where:) returns correct count`() {
        let range = Range.Lazy(0..<10) { $0 }
        let evenCount = range.count(where: { $0 % 2 == 0 })
        #expect(evenCount == 5)
    }

    @Test
    func `reduce.into accumulates correctly`() {
        var range = Range.Lazy(1..<6) { $0 }
        let sum = range.reduce.into(0) { $0 += $1 }
        #expect(sum == 15)
    }

    @Test
    func `reduce.from combines correctly`() {
        var range = Range.Lazy(1..<5) { $0 }
        let product = range.reduce.from(1) { $0 * $1 }
        #expect(product == 24)
    }

    @Test
    func `contains returns true when predicate matches`() {
        var range = Range.Lazy(0..<10) { $0 }
        #expect(range.contains { $0 == 7 })
    }

    @Test
    func `contains returns false when predicate doesn't match`() {
        var range = Range.Lazy(0..<10) { $0 }
        #expect(!range.contains { $0 == 100 })
    }
}

// MARK: - Edge Case Tests

extension RangeLazyTests.EdgeCase {

    @Test
    func `empty range forEach does nothing`() {
        let range = Range.Lazy(0..<0) { $0 }
        var count = 0
        range.forEach { _ in count += 1 }
        #expect(count == 0)
    }

    @Test
    func `empty range satisfies.all returns true`() {
        var range = Range.Lazy(0..<0) { $0 }
        #expect(range.satisfies.all { _ in false })
    }

    @Test
    func `empty range satisfies.any returns false`() {
        var range = Range.Lazy(0..<0) { $0 }
        #expect(!range.satisfies.any { _ in true })
    }

    @Test
    func `empty range first returns nil`() {
        var range = Range.Lazy(0..<0) { $0 }
        #expect(range.first { _ in true } == nil)
    }

    @Test
    func `empty range count(where:) returns zero`() {
        let range = Range.Lazy(0..<0) { $0 }
        #expect(range.count(where: { _ in true }) == 0)
    }

    @Test
    func `single element range works correctly`() {
        var range = Range.Lazy(0..<1) { $0 * 10 }
        #expect(range.count == 1)
        #expect(range.first { _ in true } == 0)

        var results: [Int] = []
        range.forEach { results.append($0) }
        #expect(results == [0])
    }

    @Test
    func `large range count is efficient (O(1))`() {
        let range = Range.Lazy(0..<1_000_000) { $0 }
        #expect(range.count == 1_000_000)
    }

    @Test
    func `negative transform values work`() {
        let range = Range.Lazy(0..<5) { -$0 }
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

    @Test
    func `reversed count matches original`() {
        let range = Range.Lazy(0..<10) { $0 }
        let reversed = range.reversed()
        #expect(reversed.count == 10)
    }

    @Test
    func `reversed isEmpty matches original`() {
        let range = Range.Lazy(5..<5) { $0 }
        let reversed = range.reversed()
        #expect(reversed.isEmpty)
    }

    @Test
    func `reversed iterator produces correct order`() {
        let range = Range.Lazy(0..<3) { $0 }
        let reversed = range.reversed()
        var iterator = reversed.makeIterator()
        #expect(iterator.next() == 2)
        #expect(iterator.next() == 1)
        #expect(iterator.next() == 0)
        #expect(iterator.next() == nil)
    }

    @Test
    func `reversed satisfies.all works correctly`() {
        let range = Range.Lazy(0..<10) { $0 }
        var reversed = range.reversed()
        #expect(reversed.satisfies.all { $0 >= 0 && $0 < 10 })
    }

    @Test
    func `reversed first finds from end`() {
        let range = Range.Lazy(0..<10) { $0 }
        var reversed = range.reversed()
        let result = reversed.first { $0 < 5 }
        #expect(result == 4)
    }

    @Test
    func `reversed count(where:) works correctly`() {
        let range = Range.Lazy(0..<10) { $0 }
        let reversed = range.reversed()
        #expect(reversed.count(where: { $0 % 2 == 0 }) == 5)
    }

    @Test
    func `reversed reduce.into accumulates in reverse order`() {
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

    @Test
    func `empty reversed range works`() {
        let range = Range.Lazy(0..<0) { $0 }
        var reversed = range.reversed()
        #expect(reversed.isEmpty)
        #expect(reversed.count == 0)
        #expect(reversed.first { _ in true } == nil)
    }

    @Test
    func `single element reversed works`() {
        let range = Range.Lazy(0..<1) { $0 * 5 }
        let reversed = range.reversed()
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

    @Test
    func `INVARIANT: Iterator returns nil forever after exhaustion`() {
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

    @Test
    func `INVARIANT: Reversed iterator returns nil forever after exhaustion`() {
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

    @Test
    func `INVARIANT: Empty iterator returns nil immediately and forever`() {
        let range = Range.Lazy(0..<0) { $0 }
        var iterator = range.makeIterator()

        for _ in 0..<100 {
            #expect(iterator.next() == nil)
        }
    }

    @Test
    func `INVARIANT: Iterator count matches range.count exactly`() {
        for size in [0, 1, 2, 10, 100, 1000] {
            let range = Range.Lazy(0..<size) { $0 }
            var iterator = range.makeIterator()
            var iteratedCount: Range.Index.Count = 0

            while iterator.next() != nil {
                iteratedCount += 1
            }

            #expect(iteratedCount == range.count,
                   "Size \(size): iterated \(iteratedCount) but count is \(range.count)")
        }
    }

    @Test
    func `INVARIANT: Reversed iterator count matches range.count exactly`() {
        for size in [0, 1, 2, 10, 100, 1000] {
            let range = Range.Lazy(0..<size) { $0 }
            var iterator = range.reversed().makeIterator()
            var iteratedCount: Range.Index.Count = 0

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

    @Test
    func `INVARIANT: contains(predicate) == (first(predicate) != nil)`() {
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

    @Test
    func `INVARIANT: satisfies.any(p) == !satisfies.none(p)`() {
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

    @Test
    func `INVARIANT: satisfies.all(p) implies satisfies.any(p) for non-empty`() {
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

    @Test
    func `INVARIANT: count(where: { true }) == count property`() {
        for size in [0, 1, 5, 100] {
            let range = Range.Lazy(0..<size) { $0 }
            let countWhere = range.count(where: { _ in true })
            let bool = try! countWhere == Range.Index.Count(size)
            #expect(bool,
                   "Size \(size): count(where: true) = \(countWhere)")
        }
    }

    @Test
    func `INVARIANT: count(where: { false }) == 0`() {
        for size in [0, 1, 5, 100] {
            let range = Range.Lazy(0..<size) { $0 }
            let countWhere = range.count(where: { _ in false })
            #expect(countWhere == 0,
                   "Size \(size): count(where: false) = \(countWhere)")
        }
    }

    @Test
    func `INVARIANT: reduce.into(initial) { } returns initial for empty range`() {
        var range = Range.Lazy(0..<0) { $0 }
        let result = range.reduce.into(42) { acc, _ in acc += 1 }
        #expect(result == 42)
    }

    @Test
    func `INVARIANT: reduce.from(initial) { } returns initial for empty range`() {
        var range = Range.Lazy(0..<0) { $0 }
        let result = range.reduce.from(42) { _, _ in 0 }
        #expect(result == 42)
    }

    @Test
    func `INVARIANT: Transform is deterministic - same index gives same value`() {
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

    @Test
    func `INVARIANT: drain empties the range completely`() {
        var range = Range.Lazy(0..<10) { $0 }
        var drained: [Int] = []

        range.drain { drained.append($0) }

        #expect(drained.count == 10)
        #expect(range.isEmpty)
        #expect(range.count == 0)
    }

    @Test
    func `INVARIANT: drain on empty range does nothing`() {
        var range = Range.Lazy(0..<0) { $0 }
        var drainCount = 0

        range.drain { _ in drainCount += 1 }

        #expect(drainCount == 0)
        #expect(range.isEmpty)
    }

    @Test
    func `INVARIANT: double drain yields nothing second time`() {
        var range = Range.Lazy(0..<5) { $0 }
        var first: [Int] = []
        var second: [Int] = []

        range.drain { first.append($0) }
        range.drain { second.append($0) }

        #expect(first == [0, 1, 2, 3, 4])
        #expect(second == [])
    }

    @Test
    func `INVARIANT: reversed drain empties the range completely`() {
        let range = Range.Lazy(0..<10) { $0 }
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

    @Test
    func `INVARIANT: Forward + Reversed cover all elements exactly once`() {
        for size in [0, 1, 5, 20] {
            var forward: [Int] = []
            var backward: [Int] = []

            let range1 = Range.Lazy(0..<size) { $0 }
            range1.forEach { forward.append($0) }

            let range2 = Range.Lazy(0..<size) { $0 }
            let reversed = range2.reversed()
            reversed.forEach { backward.append($0) }

            #expect(forward.count == size)
            #expect(backward.count == size)
            #expect(Set(forward) == Set(backward),
                   "Forward and reversed should cover same elements")
            #expect(forward == backward.reversed(),
                   "Reversed should be exact reverse of forward")
        }
    }

    @Test
    func `INVARIANT: reduce forward and reversed give same sum`() {
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

    @Test
    func `INVARIANT: count(where:) same for forward and reversed`() {
        for size in [0, 1, 5, 20] {
            let range1 = Range.Lazy(0..<size) { $0 }
            let range2 = Range.Lazy(0..<size) { $0 }

            let forwardCount = range1.count(where: { $0 % 2 == 0 })
            let backwardCount = range2.reversed().count(where: { $0 % 2 == 0 })

            #expect(forwardCount == backwardCount)
        }
    }

    @Test
    func `INVARIANT: satisfies.all same for forward and reversed`() {
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

    @Test
    func `INVARIANT: Offset ranges work correctly`() {
        let range = Range.Lazy(100..<105) { $0 }
        var results: [Int] = []
        var iter = range.makeIterator()
        while let v = iter.next() { results.append(v) }

        #expect(results == [100, 101, 102, 103, 104])
        #expect(range.count == 5)
    }

    @Test
    func `INVARIANT: Large offset ranges work correctly`() {
        let start = 1_000_000
        let range = Range.Lazy(start..<(start + 5)) { $0 }

        #expect(range.count == 5)

        var iter = range.makeIterator()
        #expect(iter.next() == 1_000_000)
        #expect(iter.next() == 1_000_001)
    }

    @Test
    func `INVARIANT: Transform with overflow-safe arithmetic`() {
        // Use transforms that don't overflow
        let range = Range.Lazy(0..<5) { Int.max - 10 + $0 }
        var results: [Int] = []
        var iter = range.makeIterator()
        while let v = iter.next() { results.append(v) }

        #expect(results.count == 5)
        #expect(results[0] == Int.max - 10)
        #expect(results[4] == Int.max - 6)
    }

    @Test
    func `INVARIANT: Negative start ranges work`() {
        let range = Range.Lazy(-5..<5) { $0 }
        #expect(range.count == 10)

        var results: [Int] = []
        var iter = range.makeIterator()
        while let v = iter.next() { results.append(v) }

        #expect(results == [-5, -4, -3, -2, -1, 0, 1, 2, 3, 4])
    }

    @Test
    func `INVARIANT: Complex transform maintains invariants`() {
        // Transform: triangular numbers
        let range = Range.Lazy(1..<6) { n in n * (n + 1) / 2 }

        var results: [Int] = []
        var iter = range.makeIterator()
        while let v = iter.next() { results.append(v) }

        #expect(results == [1, 3, 6, 10, 15])
        #expect(range.count == 5)
    }

    @Test
    func `INVARIANT: first returns first matching, not any matching`() {
        var range = Range.Lazy(0..<100) { $0 }
        let result = range.first { $0 > 50 }
        #expect(result == 51, "first should return 51, not any value > 50")
    }

    @Test
    func `INVARIANT: reversed first returns last matching from original`() {
        let range = Range.Lazy(0..<100) { $0 }
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

    @Test
    func `STRESS: Many small ranges maintain invariants`() {
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

    @Test
    func `STRESS: Alternating forward/reversed operations`() {
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

    @Test
    func `STRESS: Predicate operations on various sizes`() {
        for size in [0, 1, 2, 10, 100, 500] {
            let range1 = Range.Lazy(0..<size) { $0 }
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

// MARK: - Drop/Prefix Tests

enum RangeLazyDropPrefixTests {
    @Suite struct Drop {}
    @Suite struct Prefix {}
    @Suite struct Chaining {}
    @Suite struct Reversed {}
}

// MARK: - Drop Tests

extension RangeLazyDropPrefixTests.Drop {

    @Test
    func `drop.first returns Range.Lazy with adjusted start (O(1))`() {
        let range = Range.Lazy(0..<10) { $0 }
        let dropped = range.drop.first(3)

        // Verify it's still a lazy range with correct count
        #expect(dropped.count == 7)

        // Verify contents
        var results: [Int] = []
        let d = dropped
        d.forEach { results.append($0) }
        #expect(results == [3, 4, 5, 6, 7, 8, 9])
    }

    @Test
    func `drop.first with count >= size returns empty range`() {
        let range = Range.Lazy(0..<5) { $0 }
        #expect(range.drop.first(5).isEmpty)
        #expect(range.drop.first(10).isEmpty)
    }

    @Test
    func `drop.first(0) returns equivalent range`() {
        let range = Range.Lazy(0..<5) { $0 }
        let dropped = range.drop.first(0)
        #expect(dropped.count == 5)
    }

    @Test
    func `drop.while returns array (O(n))`() {
        let range = Range.Lazy(0..<10) { $0 }
        let result = range.drop.while { $0 < 5 }
        #expect(result == [5, 6, 7, 8, 9])
    }

    @Test
    func `drop.while with always-true predicate returns empty array`() {
        let range = Range.Lazy(0..<5) { $0 }
        #expect(range.drop.while { _ in true } == [])
    }

    @Test
    func `drop.while with always-false predicate returns all elements`() {
        let range = Range.Lazy(0..<5) { $0 }
        #expect(range.drop.while { _ in false } == [0, 1, 2, 3, 4])
    }

    @Test
    func `drop.first with transform`() {
        let range = Range.Lazy(0..<5) { $0 * 2 }
        let dropped = range.drop.first(2)

        var results: [Int] = []
        let d = dropped
        d.forEach { results.append($0) }
        #expect(results == [4, 6, 8])
    }
}

// MARK: - Prefix Tests

extension RangeLazyDropPrefixTests.Prefix {

    @Test
    func `prefix.first returns Range.Lazy with adjusted end (O(1))`() {
        let range = Range.Lazy(0..<10) { $0 }
        let prefixed = range.prefix.first(3)

        // Verify it's still a lazy range with correct count
        #expect(prefixed.count == 3)

        // Verify contents
        var results: [Int] = []
        let p = prefixed
        p.forEach { results.append($0) }
        #expect(results == [0, 1, 2])
    }

    @Test
    func `prefix.first with count >= size returns equivalent range`() {
        let range = Range.Lazy(0..<5) { $0 }
        #expect(range.prefix.first(5).count == 5)
        #expect(range.prefix.first(10).count == 5)
    }

    @Test
    func `prefix.first(0) returns empty range`() {
        let range = Range.Lazy(0..<5) { $0 }
        #expect(range.prefix.first(0).isEmpty)
    }

    @Test
    func `prefix.while returns array (O(n))`() {
        let range = Range.Lazy(0..<10) { $0 }
        let result = range.prefix.while { $0 < 5 }
        #expect(result == [0, 1, 2, 3, 4])
    }

    @Test
    func `prefix.while with always-true predicate returns all elements`() {
        let range = Range.Lazy(0..<5) { $0 }
        #expect(range.prefix.while { _ in true } == [0, 1, 2, 3, 4])
    }

    @Test
    func `prefix.while with always-false predicate returns empty array`() {
        let range = Range.Lazy(0..<5) { $0 }
        #expect(range.prefix.while { _ in false } == [])
    }

    @Test
    func `prefix.first with transform`() {
        let range = Range.Lazy(0..<5) { $0 * 2 }
        let prefixed = range.prefix.first(3)

        var results: [Int] = []
        let p = prefixed
        p.forEach { results.append($0) }
        #expect(results == [0, 2, 4])
    }
}

// MARK: - Chaining Tests

extension RangeLazyDropPrefixTests.Chaining {

    @Test
    func `drop.first then prefix.first chains correctly (all O(1))`() {
        let range = Range.Lazy(0..<10) { $0 }
        let result = range.drop.first(2).prefix.first(3)

        #expect(result.count == 3)

        var results: [Int] = []
        let r = result
        r.forEach { results.append($0) }
        #expect(results == [2, 3, 4])
    }

    @Test
    func `prefix.first then drop.first chains correctly`() {
        let range = Range.Lazy(0..<10) { $0 }
        let result = range.prefix.first(5).drop.first(2)

        #expect(result.count == 3)

        var results: [Int] = []
        let r = result
        r.forEach { results.append($0) }
        #expect(results == [2, 3, 4])
    }

    @Test
    func `multiple drop.first calls accumulate correctly`() {
        let range = Range.Lazy(0..<10) { $0 }
        let result = range.drop.first(2).drop.first(3)

        #expect(result.count == 5)

        var results: [Int] = []
        let r = result
        r.forEach { results.append($0) }
        #expect(results == [5, 6, 7, 8, 9])
    }

    @Test
    func `multiple prefix.first calls take minimum`() {
        let range = Range.Lazy(0..<10) { $0 }
        let result = range.prefix.first(7).prefix.first(3)

        #expect(result.count == 3)

        var results: [Int] = []
        let r = result
        r.forEach { results.append($0) }
        #expect(results == [0, 1, 2])
    }

    @Test
    func `complex chaining maintains correct bounds`() {
        let range = Range.Lazy(0..<20) { $0 }
        let result = range
            .drop.first(5)      // 5..<20
            .prefix.first(10)   // 5..<15
            .drop.first(2)      // 7..<15
            .prefix.first(5)    // 7..<12

        #expect(result.count == 5)

        var results: [Int] = []
        let r = result
        r.forEach { results.append($0) }
        #expect(results == [7, 8, 9, 10, 11])
    }
}

// MARK: - Reversed Tests

extension RangeLazyDropPrefixTests.Reversed {

    @Test
    func `reversed drop.first skips from high end`() {
        let range = Range.Lazy(0..<10) { $0 }
        let reversed = range.reversed()
        let dropped = reversed.drop.first(3)

        // Original: [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
        // After drop.first(3): [6, 5, 4, 3, 2, 1, 0]
        #expect(dropped.count == 7)

        var results: [Int] = []
        let d = dropped
        d.forEach { results.append($0) }
        #expect(results == [6, 5, 4, 3, 2, 1, 0])
    }

    @Test
    func `reversed prefix.first takes from high end`() {
        let range = Range.Lazy(0..<10) { $0 }
        let reversed = range.reversed()
        let prefixed = reversed.prefix.first(3)

        // Original: [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
        // After prefix.first(3): [9, 8, 7]
        #expect(prefixed.count == 3)

        var results: [Int] = []
        let p = prefixed
        p.forEach { results.append($0) }
        #expect(results == [9, 8, 7])
    }

    @Test
    func `reversed drop.while works correctly`() {
        let range = Range.Lazy(0..<10) { $0 }
        let reversed = range.reversed()

        // Iteration order: 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
        // Drop while > 5: drops 9, 8, 7, 6, keeps [5, 4, 3, 2, 1, 0]
        let result = reversed.drop.while { $0 > 5 }
        #expect(result == [5, 4, 3, 2, 1, 0])
    }

    @Test
    func `reversed prefix.while works correctly`() {
        let range = Range.Lazy(0..<10) { $0 }
        let reversed = range.reversed()

        // Iteration order: 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
        // Prefix while > 5: takes [9, 8, 7, 6]
        let result = reversed.prefix.while { $0 > 5 }
        #expect(result == [9, 8, 7, 6])
    }

    @Test
    func `reversed empty range drop/prefix`() {
        let range = Range.Lazy(0..<0) { $0 }
        let reversed = range.reversed()

        #expect(reversed.drop.first(5).isEmpty)
        #expect(reversed.prefix.first(5).isEmpty)
        #expect(reversed.drop.while { _ in true } == [])
        #expect(reversed.prefix.while { _ in true } == [])
    }
}

// MARK: - Invariant Tests for Drop/Prefix

enum RangeLazyDropPrefixInvariantTests {
    @Suite struct Invariants {}
}

extension RangeLazyDropPrefixInvariantTests.Invariants {

//    @Test
//    func `INVARIANT: drop.first(n) + prefix.first(m) maintains correct total when m <= remaining`() {
//        for size in [0, 1, 5, 20, 100] {
//            for dropCount in try! [0, 1, size / 2, size, size + 5].map(Range.Index.Count.init) {
//                let range = Range.Lazy(0..<size) { $0 }
//                let afterDrop = range.drop.first(dropCount)
//                let remaining: Range.Index.Count = max(0, size - dropCount)
//
//                #expect(afterDrop.count == remaining,
//                       "Size \(size), drop \(dropCount): expected \(remaining), got \(afterDrop.count)")
//
//                for prefixCount in [0, 1, remaining / 2, remaining, remaining + 5] {
//                    let afterPrefix = afterDrop.prefix.first(try! Range.Index.Count(prefixCount))
//                    let expected = min(prefixCount, remaining)
//
//                    #expect(afterPrefix.count == expected,
//                           "Size \(size), drop \(dropCount), prefix \(prefixCount): expected \(expected), got \(afterPrefix.count)")
//                }
//            }
//        }
//    }

    @Test
    func `INVARIANT: drop.first preserves transform`() {
        let range = Range.Lazy(0..<10) { $0 * 3 + 1 }
        let dropped = range.drop.first(3)

        var results: [Int] = []
        let d = dropped
        d.forEach { results.append($0) }

        // Indices 3, 4, 5, 6, 7, 8, 9 → transformed: 10, 13, 16, 19, 22, 25, 28
        #expect(results == [10, 13, 16, 19, 22, 25, 28])
    }

    @Test
    func `INVARIANT: prefix.first preserves transform`() {
        let range = Range.Lazy(0..<10) { $0 * 3 + 1 }
        let prefixed = range.prefix.first(4)

        var results: [Int] = []
        let p = prefixed
        p.forEach { results.append($0) }

        // Indices 0, 1, 2, 3 → transformed: 1, 4, 7, 10
        #expect(results == [1, 4, 7, 10])
    }

    @Test
    func `INVARIANT: drop(0) and prefix(count) are identity operations`() {
        for size in [0, 1, 5, 20] {
            let range = Range.Lazy(0..<size) { $0 }

            // drop.first(0) should be identity
            let afterDrop0 = range.drop.first(0)
            #expect(afterDrop0.count == range.count)

            // prefix.first(size) should be identity
            let afterPrefixAll = range.prefix.first(try! Range.Index.Count(size))
            #expect(afterPrefixAll.count == range.count)

            // prefix.first(size + 100) should also be identity
            let afterPrefixMore = range.prefix.first(try! Range.Index.Count(size + 100))
            #expect(afterPrefixMore.count == range.count)
        }
    }

    @Test
    func `INVARIANT: order of operations matters`() {
        let range = Range.Lazy(0..<10) { $0 }

        // drop(3).prefix(4) vs prefix(4).drop(3) should differ
        let dropThenPrefix = range.drop.first(3).prefix.first(4)
        let prefixThenDrop = range.prefix.first(4).drop.first(3)

        var dtp: [Int] = []
        let dtpRange = dropThenPrefix
        dtpRange.forEach { dtp.append($0) }

        var ptd: [Int] = []
        let ptdRange = prefixThenDrop
        ptdRange.forEach { ptd.append($0) }

        // drop(3).prefix(4): [3, 4, 5, 6]
        // prefix(4).drop(3): [3]
        #expect(dtp == [3, 4, 5, 6])
        #expect(ptd == [3])
    }
}
