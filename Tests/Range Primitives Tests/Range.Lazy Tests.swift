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
    func `init creates range with correct bounds`() throws {
        let range: Range.Lazy = try Range.Lazy(0..<10) { $0 }
        #expect(range.count == 10)
        #expect(!range.isEmpty)
    }

    @Test
    func `count property returns correct value`() throws {
        let range = try Range.Lazy(5..<15) { $0 }
        #expect(range.count == 10)
    }

    @Test
    func `isEmpty returns true for empty range`() throws {
        let range = try Range.Lazy(5..<5) { $0 }
        #expect(range.isEmpty)
        #expect(range.count == 0)
    }

    @Test
    func `isEmpty returns false for non-empty range`() throws {
        let range = try Range.Lazy(0..<1) { $0 }
        #expect(!range.isEmpty)
    }

    @Test
    func `transform applies correctly`() throws {
        let range = try Range.Lazy(0..<5) { $0 * 2 }
        var results: [Int] = []
        range.forEach { results.append($0) }
        #expect(results == [0, 2, 4, 6, 8])
    }

    @Test
    func `makeIterator produces correct sequence`() throws {
        let range = try Range.Lazy(0..<3) { $0 + 10 }
        var iterator = range.makeIterator()
        #expect(iterator.next() == 10)
        #expect(iterator.next() == 11)
        #expect(iterator.next() == 12)
        #expect(iterator.next() == nil)
    }

    @Test
    func `reversed produces elements in reverse order`() throws {
        let range = try Range.Lazy(0..<5) { $0 }
        let reversed = range.reversed()
        var results: [Int] = []
        reversed.forEach { results.append($0) }
        #expect(results == [4, 3, 2, 1, 0])
    }

    // MARK: - Sequence.Protocol Conformance Tests

    @Test
    func `satisfies.all returns true when all match`() throws {
        var range = try Range.Lazy(0..<10) { $0 }
        #expect(range.satisfies.all { $0 >= 0 })
    }

    @Test
    func `satisfies.all returns false when one doesn't match`() throws {
        var range = try Range.Lazy(0..<10) { $0 }
        #expect(!range.satisfies.all { $0 > 5 })
    }

    @Test
    func `satisfies.any returns true when one matches`() throws {
        var range = try Range.Lazy(0..<10) { $0 }
        #expect(range.satisfies.any { $0 == 5 })
    }

    @Test
    func `satisfies.any returns false when none match`() throws {
        var range = try Range.Lazy(0..<10) { $0 }
        #expect(!range.satisfies.any { $0 > 100 })
    }

    @Test
    func `satisfies.none returns true when none match`() throws {
        var range = try Range.Lazy(0..<10) { $0 }
        #expect(range.satisfies.none { $0 < 0 })
    }

    @Test
    func `satisfies.none returns false when one matches`() throws {
        var range = try Range.Lazy(0..<10) { $0 }
        #expect(!range.satisfies.none { $0 == 5 })
    }

    @Test
    func `first returns matching element`() throws {
        var range = try Range.Lazy(0..<10) { $0 * 2 }
        let result = range.first { $0 > 10 }
        #expect(result == 12)
    }

    @Test
    func `first returns nil when no match`() throws {
        var range = try Range.Lazy(0..<10) { $0 }
        let result = range.first { $0 > 100 }
        #expect(result == nil)
    }

    @Test
    func `count(where:) returns correct count`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
        let evenCount = range.count(where: { $0 % 2 == 0 })
        #expect(evenCount == 5)
    }

    @Test
    func `reduce.into accumulates correctly`() throws {
        var range = try Range.Lazy(1..<6) { $0 }
        let sum = range.reduce.into(0) { $0 += $1 }
        #expect(sum == 15)
    }

    @Test
    func `reduce.from combines correctly`() throws {
        var range = try Range.Lazy(1..<5) { $0 }
        let product = range.reduce.from(1) { $0 * $1 }
        #expect(product == 24)
    }

    @Test
    func `contains returns true when predicate matches`() throws {
        var range = try Range.Lazy(0..<10) { $0 }
        #expect(range.contains { $0 == 7 })
    }

    @Test
    func `contains returns false when predicate doesn't match`() throws {
        var range = try Range.Lazy(0..<10) { $0 }
        #expect(!range.contains { $0 == 100 })
    }
}

// MARK: - Edge Case Tests

extension RangeLazyTests.EdgeCase {

    @Test
    func `empty range forEach does nothing`() throws {
        let range = try Range.Lazy(0..<0) { $0 }
        var count = 0
        range.forEach { _ in count += 1 }
        #expect(count == 0)
    }

    @Test
    func `empty range satisfies.all returns true`() throws {
        var range = try Range.Lazy(0..<0) { $0 }
        #expect(range.satisfies.all { _ in false })
    }

    @Test
    func `empty range satisfies.any returns false`() throws {
        var range = try Range.Lazy(0..<0) { $0 }
        #expect(!range.satisfies.any { _ in true })
    }

    @Test
    func `empty range first returns nil`() throws {
        var range = try Range.Lazy(0..<0) { $0 }
        #expect(range.first { _ in true } == nil)
    }

    @Test
    func `empty range count(where:) returns zero`() throws {
        let range = try Range.Lazy(0..<0) { $0 }
        #expect(range.count(where: { _ in true }) == 0)
    }

    @Test
    func `single element range works correctly`() throws {
        var range = try Range.Lazy(0..<1) { $0 * 10 }
        #expect(range.count == 1)
        #expect(range.first { _ in true } == 0)

        var results: [Int] = []
        range.forEach { results.append($0) }
        #expect(results == [0])
    }

    @Test
    func `large range count is efficient (O(1))`() throws {
        let range = try Range.Lazy(0..<1_000_000) { $0 }
        #expect(range.count == 1_000_000)
    }

    @Test
    func `negative transform values work`() throws {
        let range = try Range.Lazy(0..<5) { -$0 }
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
    func `reversed count matches original`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
        let reversed = range.reversed()
        #expect(reversed.count == 10)
    }

    @Test
    func `reversed isEmpty matches original`() throws {
        let range = try Range.Lazy(5..<5) { $0 }
        let reversed = range.reversed()
        #expect(reversed.isEmpty)
    }

    @Test
    func `reversed iterator produces correct order`() throws {
        let range = try Range.Lazy(0..<3) { $0 }
        let reversed = range.reversed()
        var iterator = reversed.makeIterator()
        #expect(iterator.next() == 2)
        #expect(iterator.next() == 1)
        #expect(iterator.next() == 0)
        #expect(iterator.next() == nil)
    }

    @Test
    func `reversed satisfies.all works correctly`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
        var reversed = range.reversed()
        #expect(reversed.satisfies.all { $0 >= 0 && $0 < 10 })
    }

    @Test
    func `reversed first finds from end`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
        var reversed = range.reversed()
        let result = reversed.first { $0 < 5 }
        #expect(result == 4)
    }

    @Test
    func `reversed count(where:) works correctly`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
        let reversed = range.reversed()
        #expect(reversed.count(where: { $0 % 2 == 0 }) == 5)
    }

    @Test
    func `reversed reduce.into accumulates in reverse order`() throws {
        let range = try Range.Lazy(1..<4) { $0 }
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
    func `empty reversed range works`() throws {
        let range = try Range.Lazy(0..<0) { $0 }
        var reversed = range.reversed()
        #expect(reversed.isEmpty)
        #expect(reversed.count == 0)
        #expect(reversed.first { _ in true } == nil)
    }

    @Test
    func `single element reversed works`() throws {
        let range = try Range.Lazy(0..<1) { $0 * 5 }
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
    func `INVARIANT: Iterator returns nil forever after exhaustion`() throws {
        let range = try Range.Lazy(0..<3) { $0 }
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
    func `INVARIANT: Reversed iterator returns nil forever after exhaustion`() throws {
        let range = try Range.Lazy(0..<3) { $0 }
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
    func `INVARIANT: Empty iterator returns nil immediately and forever`() throws {
        let range = try Range.Lazy(0..<0) { $0 }
        var iterator = range.makeIterator()

        for _ in 0..<100 {
            #expect(iterator.next() == nil)
        }
    }

    @Test
    func `INVARIANT: Iterator count matches range.count exactly`() throws {
        for size in [0, 1, 2, 10, 100, 1000] {
            let range = try Range.Lazy(0..<size) { $0 }
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
    func `INVARIANT: Reversed iterator count matches range.count exactly`() throws {
        for size in [0, 1, 2, 10, 100, 1000] {
            let range = try Range.Lazy(0..<size) { $0 }
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
    func `INVARIANT: contains(predicate) == (first(predicate) != nil)`() throws {
        for size in [0, 1, 5, 20] {
            var range1 = try Range.Lazy(0..<size) { $0 }
            var range2 = try Range.Lazy(0..<size) { $0 }

            // Test with predicate that matches
            let containsEven = range1.contains { $0 % 2 == 0 }
            let firstEven = range2.first { $0 % 2 == 0 }
            #expect(containsEven == (firstEven != nil),
                   "Size \(size): contains(even) = \(containsEven), first != nil = \(firstEven != nil)")

            // Test with predicate that never matches
            var range3 = try Range.Lazy(0..<size) { $0 }
            var range4 = try Range.Lazy(0..<size) { $0 }
            let containsNegative = range3.contains { $0 < 0 }
            let firstNegative = range4.first { $0 < 0 }
            #expect(containsNegative == (firstNegative != nil))
        }
    }

    @Test
    func `INVARIANT: satisfies.any(p) == !satisfies.none(p)`() throws {
        for size in [0, 1, 5, 20] {
            // Predicate that matches some elements
            var range1 = try Range.Lazy(0..<size) { $0 }
            var range2 = try Range.Lazy(0..<size) { $0 }
            let anyEven = range1.satisfies.any { $0 % 2 == 0 }
            let noneEven = range2.satisfies.none { $0 % 2 == 0 }
            #expect(anyEven == !noneEven,
                   "Size \(size): any(even) = \(anyEven), none(even) = \(noneEven)")

            // Predicate that matches no elements
            var range3 = try Range.Lazy(0..<size) { $0 }
            var range4 = try Range.Lazy(0..<size) { $0 }
            let anyNegative = range3.satisfies.any { $0 < 0 }
            let noneNegative = range4.satisfies.none { $0 < 0 }
            #expect(anyNegative == !noneNegative)
        }
    }

    @Test
    func `INVARIANT: satisfies.all(p) implies satisfies.any(p) for non-empty`() throws {
        for size in [1, 5, 20] {
            var range1 = try Range.Lazy(0..<size) { $0 }
            var range2 = try Range.Lazy(0..<size) { $0 }

            let allNonNegative = range1.satisfies.all { $0 >= 0 }
            let anyNonNegative = range2.satisfies.any { $0 >= 0 }

            if allNonNegative {
                #expect(anyNonNegative,
                       "Size \(size): all(>=0) is true but any(>=0) is false")
            }
        }
    }

    @Test
    func `INVARIANT: count(where: { true }) == count property`() throws {
        for size in [0, 1, 5, 100] {
            let range = try Range.Lazy(0..<size) { $0 }
            let countWhere = range.count(where: { _ in true })
            let bool = try countWhere == Range.Index.Count(size)
            #expect(bool,
                   "Size \(size): count(where: true) = \(countWhere)")
        }
    }

    @Test
    func `INVARIANT: count(where: { false }) == 0`() throws {
        for size in [0, 1, 5, 100] {
            let range = try Range.Lazy(0..<size) { $0 }
            let countWhere = range.count(where: { _ in false })
            #expect(countWhere == 0,
                   "Size \(size): count(where: false) = \(countWhere)")
        }
    }

    @Test
    func `INVARIANT: reduce.into(initial) { } returns initial for empty range`() throws {
        var range = try Range.Lazy(0..<0) { $0 }
        let result = range.reduce.into(42) { acc, _ in acc += 1 }
        #expect(result == 42)
    }

    @Test
    func `INVARIANT: reduce.from(initial) { } returns initial for empty range`() throws {
        var range = try Range.Lazy(0..<0) { $0 }
        let result = range.reduce.from(42) { _, _ in 0 }
        #expect(result == 42)
    }

    @Test
    func `INVARIANT: Transform is deterministic - same index gives same value`() throws {
        let range = try Range.Lazy(0..<5) { i in
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
    func `INVARIANT: drain empties the range completely`() throws {
        var range = try Range.Lazy(0..<10) { $0 }
        var drained: [Int] = []

        range.drain { drained.append($0) }

        #expect(drained.count == 10)
        #expect(range.isEmpty)
        #expect(range.count == 0)
    }

    @Test
    func `INVARIANT: drain on empty range does nothing`() throws {
        var range = try Range.Lazy(0..<0) { $0 }
        var drainCount = 0

        range.drain { _ in drainCount += 1 }

        #expect(drainCount == 0)
        #expect(range.isEmpty)
    }

    @Test
    func `INVARIANT: double drain yields nothing second time`() throws {
        var range = try Range.Lazy(0..<5) { $0 }
        var first: [Int] = []
        var second: [Int] = []

        range.drain { first.append($0) }
        range.drain { second.append($0) }

        #expect(first == [0, 1, 2, 3, 4])
        #expect(second == [])
    }

    @Test
    func `INVARIANT: reversed drain empties the range completely`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
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
    func `INVARIANT: Forward + Reversed cover all elements exactly once`() throws {
        for size in [0, 1, 5, 20] {
            var forward: [Int] = []
            var backward: [Int] = []

            let range1 = try Range.Lazy(0..<size) { $0 }
            range1.forEach { forward.append($0) }

            let range2 = try Range.Lazy(0..<size) { $0 }
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
    func `INVARIANT: reduce forward and reversed give same sum`() throws {
        for size in [0, 1, 5, 20] {
            var range1 = try Range.Lazy(0..<size) { $0 }
            let range2 = try Range.Lazy(0..<size) { $0 }

            let forwardSum = range1.reduce.into(0) { $0 += $1 }
            var reversed = range2.reversed()
            let backwardSum = reversed.reduce.into(0) { $0 += $1 }

            #expect(forwardSum == backwardSum,
                   "Size \(size): forward sum \(forwardSum) != backward sum \(backwardSum)")
        }
    }

    @Test
    func `INVARIANT: count(where:) same for forward and reversed`() throws {
        for size in [0, 1, 5, 20] {
            let range1 = try Range.Lazy(0..<size) { $0 }
            let range2 = try Range.Lazy(0..<size) { $0 }

            let forwardCount = range1.count(where: { $0 % 2 == 0 })
            let backwardCount = range2.reversed().count(where: { $0 % 2 == 0 })

            #expect(forwardCount == backwardCount)
        }
    }

    @Test
    func `INVARIANT: satisfies.all same for forward and reversed`() throws {
        for size in [0, 1, 5, 20] {
            var range1 = try Range.Lazy(0..<size) { $0 }
            let range2 = try Range.Lazy(0..<size) { $0 }

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
    func `INVARIANT: Offset ranges work correctly`() throws {
        let range = try Range.Lazy(100..<105) { $0 }
        var results: [Int] = []
        var iter = range.makeIterator()
        while let v = iter.next() { results.append(v) }

        #expect(results == [100, 101, 102, 103, 104])
        #expect(range.count == 5)
    }

    @Test
    func `INVARIANT: Large offset ranges work correctly`() throws {
        let start = 1_000_000
        let range = try Range.Lazy(start..<(start + 5)) { $0 }

        #expect(range.count == 5)

        var iter = range.makeIterator()
        #expect(iter.next() == 1_000_000)
        #expect(iter.next() == 1_000_001)
    }

    @Test
    func `INVARIANT: Transform with overflow-safe arithmetic`() throws {
        // Use transforms that don't overflow
        let range = try Range.Lazy(0..<5) { Int.max - 10 + $0 }
        var results: [Int] = []
        var iter = range.makeIterator()
        while let v = iter.next() { results.append(v) }

        #expect(results.count == 5)
        #expect(results[0] == Int.max - 10)
        #expect(results[4] == Int.max - 6)
    }

    @Test
    func `INVARIANT: Negative start ranges work`() throws {
        let range = try Range.Lazy(-5..<5) { $0 }
        #expect(range.count == 10)

        var results: [Int] = []
        var iter = range.makeIterator()
        while let v = iter.next() { results.append(v) }

        #expect(results == [-5, -4, -3, -2, -1, 0, 1, 2, 3, 4])
    }

    @Test
    func `INVARIANT: Complex transform maintains invariants`() throws {
        // Transform: triangular numbers
        let range = try Range.Lazy(1..<6) { n in n * (n + 1) / 2 }

        var results: [Int] = []
        var iter = range.makeIterator()
        while let v = iter.next() { results.append(v) }

        #expect(results == [1, 3, 6, 10, 15])
        #expect(range.count == 5)
    }

    @Test
    func `INVARIANT: first returns first matching, not any matching`() throws {
        var range = try Range.Lazy(0..<100) { $0 }
        let result = range.first { $0 > 50 }
        #expect(result == 51, "first should return 51, not any value > 50")
    }

    @Test
    func `INVARIANT: reversed first returns last matching from original`() throws {
        let range = try Range.Lazy(0..<100) { $0 }
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
    func `STRESS: Many small ranges maintain invariants`() throws {
        for i in 0..<100 {
            let range = try Range.Lazy(i..<(i + 10)) { $0 * 2 }
            #expect(range.count == 10)

            var sum = 0
            var iter = range.makeIterator()
            while let v = iter.next() { sum += v }

            let expected = (i..<(i + 10)).map { $0 * 2 }.reduce(0, +)
            #expect(sum == expected, "Range starting at \(i): sum \(sum) != expected \(expected)")
        }
    }

    @Test
    func `STRESS: Alternating forward/reversed operations`() throws {
        for size in [1, 5, 10, 50] {
            var forwardSum = 0
            var reversedSum = 0

            for i in 0..<10 {
                if i % 2 == 0 {
                    var range = try Range.Lazy(0..<size) { $0 }
                    forwardSum += range.reduce.into(0) { $0 += $1 }
                } else {
                    let range = try Range.Lazy(0..<size) { $0 }
                    var reversed = range.reversed()
                    reversedSum += reversed.reduce.into(0) { $0 += $1 }
                }
            }

            #expect(forwardSum == reversedSum,
                   "Size \(size): forward \(forwardSum) != reversed \(reversedSum)")
        }
    }

    @Test
    func `STRESS: Predicate operations on various sizes`() throws {
        for size in [0, 1, 2, 10, 100, 500] {
            let range1 = try Range.Lazy(0..<size) { $0 }
            var range2 = try Range.Lazy(0..<size) { $0 }
            var range3 = try Range.Lazy(0..<size) { $0 }

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
    func `drop.first returns Range.Lazy with adjusted start (O(1))`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
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
    func `drop.first with count >= size returns empty range`() throws {
        let range = try Range.Lazy(0..<5) { $0 }
        #expect(range.drop.first(5).isEmpty)
        #expect(range.drop.first(10).isEmpty)
    }

    @Test
    func `drop.first(0) returns equivalent range`() throws {
        let range = try Range.Lazy(0..<5) { $0 }
        let dropped = range.drop.first(0)
        #expect(dropped.count == 5)
    }

    @Test
    func `drop.while returns array (O(n))`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
        let result = range.drop.while { $0 < 5 }
        #expect(result == [5, 6, 7, 8, 9])
    }

    @Test
    func `drop.while with always-true predicate returns empty array`() throws {
        let range = try Range.Lazy(0..<5) { $0 }
        #expect(range.drop.while { _ in true } == [])
    }

    @Test
    func `drop.while with always-false predicate returns all elements`() throws {
        let range = try Range.Lazy(0..<5) { $0 }
        #expect(range.drop.while { _ in false } == [0, 1, 2, 3, 4])
    }

    @Test
    func `drop.first with transform`() throws {
        let range = try Range.Lazy(0..<5) { $0 * 2 }
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
    func `prefix.first returns Range.Lazy with adjusted end (O(1))`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
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
    func `prefix.first with count >= size returns equivalent range`() throws {
        let range = try Range.Lazy(0..<5) { $0 }
        #expect(range.prefix.first(5).count == 5)
        #expect(range.prefix.first(10).count == 5)
    }

    @Test
    func `prefix.first(0) returns empty range`() throws {
        let range = try Range.Lazy(0..<5) { $0 }
        #expect(range.prefix.first(0).isEmpty)
    }

    @Test
    func `prefix.while returns array (O(n))`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
        let result = range.prefix.while { $0 < 5 }
        #expect(result == [0, 1, 2, 3, 4])
    }

    @Test
    func `prefix.while with always-true predicate returns all elements`() throws {
        let range = try Range.Lazy(0..<5) { $0 }
        #expect(range.prefix.while { _ in true } == [0, 1, 2, 3, 4])
    }

    @Test
    func `prefix.while with always-false predicate returns empty array`() throws {
        let range = try Range.Lazy(0..<5) { $0 }
        #expect(range.prefix.while { _ in false } == [])
    }

    @Test
    func `prefix.first with transform`() throws {
        let range = try Range.Lazy(0..<5) { $0 * 2 }
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
    func `drop.first then prefix.first chains correctly (all O(1))`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
        let result = range.drop.first(2).prefix.first(3)

        #expect(result.count == 3)

        var results: [Int] = []
        let r = result
        r.forEach { results.append($0) }
        #expect(results == [2, 3, 4])
    }

    @Test
    func `prefix.first then drop.first chains correctly`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
        let result = range.prefix.first(5).drop.first(2)

        #expect(result.count == 3)

        var results: [Int] = []
        let r = result
        r.forEach { results.append($0) }
        #expect(results == [2, 3, 4])
    }

    @Test
    func `multiple drop.first calls accumulate correctly`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
        let result = range.drop.first(2).drop.first(3)

        #expect(result.count == 5)

        var results: [Int] = []
        let r = result
        r.forEach { results.append($0) }
        #expect(results == [5, 6, 7, 8, 9])
    }

    @Test
    func `multiple prefix.first calls take minimum`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
        let result = range.prefix.first(7).prefix.first(3)

        #expect(result.count == 3)

        var results: [Int] = []
        let r = result
        r.forEach { results.append($0) }
        #expect(results == [0, 1, 2])
    }

    @Test
    func `complex chaining maintains correct bounds`() throws {
        let range = try Range.Lazy(0..<20) { $0 }
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
    func `reversed drop.first skips from high end`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
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
    func `reversed prefix.first takes from high end`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
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
    func `reversed drop.while works correctly`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
        let reversed = range.reversed()

        // Iteration order: 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
        // Drop while > 5: drops 9, 8, 7, 6, keeps [5, 4, 3, 2, 1, 0]
        let result = reversed.drop.while { $0 > 5 }
        #expect(result == [5, 4, 3, 2, 1, 0])
    }

    @Test
    func `reversed prefix.while works correctly`() throws {
        let range = try Range.Lazy(0..<10) { $0 }
        let reversed = range.reversed()

        // Iteration order: 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
        // Prefix while > 5: takes [9, 8, 7, 6]
        let result = reversed.prefix.while { $0 > 5 }
        #expect(result == [9, 8, 7, 6])
    }

    @Test
    func `reversed empty range drop/prefix`() throws {
        let range = try Range.Lazy(0..<0) { $0 }
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

    @Test
    func `INVARIANT: drop.first(n) + prefix.first(m) maintains correct total`() throws {
        let sizes: [Range.Index.Count] = [0, 1, 5, 20, 100]

        for size in sizes {
            let range = try Range.Lazy(count: size) { $0.position.rawValue }

            // Structurally meaningful: empty, minimal, exact, overflow
            let dropCandidates: [Range.Index.Count] = [0, 1, size, size + 5]

            for dropCount in dropCandidates {
                let afterDrop = range.drop.first(dropCount)
                let remaining = size.subtract.saturating(dropCount)

                #expect(afterDrop.count == remaining)

                let prefixCandidates: [Range.Index.Count] = [0, 1, remaining, remaining + 5]

                for prefixCount in prefixCandidates {
                    let afterPrefix = afterDrop.prefix.first(prefixCount)
                    let expected = Swift.min(prefixCount, remaining)
                    #expect(afterPrefix.count == expected)
                }
            }
        }
    }

    @Test
    func `INVARIANT: drop.first preserves transform`() throws {
        let range = try Range.Lazy(0..<10) { $0 * 3 + 1 }
        let dropped = range.drop.first(3)

        var results: [Int] = []
        let d = dropped
        d.forEach { results.append($0) }

        // Indices 3, 4, 5, 6, 7, 8, 9 → transformed: 10, 13, 16, 19, 22, 25, 28
        #expect(results == [10, 13, 16, 19, 22, 25, 28])
    }

    @Test
    func `INVARIANT: prefix.first preserves transform`() throws {
        let range = try Range.Lazy(0..<10) { $0 * 3 + 1 }
        let prefixed = range.prefix.first(4)

        var results: [Int] = []
        let p = prefixed
        p.forEach { results.append($0) }

        // Indices 0, 1, 2, 3 → transformed: 1, 4, 7, 10
        #expect(results == [1, 4, 7, 10])
    }

    @Test
    func `INVARIANT: drop(0) and prefix(count) are identity operations`() throws {
        for size in [0, 1, 5, 20] {
            let range = try Range.Lazy(0..<size) { $0 }

            // drop.first(0) should be identity
            let afterDrop0 = range.drop.first(0)
            #expect(afterDrop0.count == range.count)

            // prefix.first(size) should be identity
            let afterPrefixAll = range.prefix.first(try Range.Index.Count(size))
            #expect(afterPrefixAll.count == range.count)

            // prefix.first(size + 100) should also be identity
            let afterPrefixMore = range.prefix.first(try Range.Index.Count(size + 100))
            #expect(afterPrefixMore.count == range.count)
        }
    }

    @Test
    func `INVARIANT: order of operations matters`() throws {
        let range = try Range.Lazy(0..<10) { $0 }

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

// MARK: - Cardinal Distance Invariant Tests
//
// These tests verify the principled approach of using cardinal distance
// (Ordinal.Position.distance.forward) instead of affine subtraction
// for computing range counts. Cardinal distance handles the full UInt range.

enum RangeLazyCardinalDistanceTests {
    @Suite struct Invariants {}
    @Suite struct LargeRanges {}
}

extension RangeLazyCardinalDistanceTests.Invariants {

    @Test
    func `INVARIANT: count equals cardinal distance between positions`() throws {
        let testCases: [(start: Range.Index, end: Range.Index)] = [
            (0, 0),       // empty
            (0, 1),       // single element
            (0, 100),     // normal range
            (50, 150),    // offset range
            (1000, 1000), // empty at offset
        ]

        for (start, end) in testCases {
            let cardinalDistance = try start.position.distance.forward(to: end.position)

            let range = try Range.Lazy(start: start, end: end) { $0.position.rawValue }

            #expect(range.count.rawValue == cardinalDistance)
        }
    }

    @Test
    func `INVARIANT: count matches iteration count exactly`() throws {
        let testCases: [(start: Range.Index, end: Range.Index)] = [
            (0, 0),
            (0, 1),
            (0, 10),
            (5, 15),
            (100, 100),
            (100, 105),
        ]

        for (start, end) in testCases {
            let range = try Range.Lazy(start: start, end: end) { $0.position.rawValue }

            var iterationCount: Range.Index.Count = 0
            range.forEach { _ in iterationCount += 1 }

            #expect(range.count == iterationCount)
        }
    }

    @Test
    func `INVARIANT: count preserved through drop and prefix`() throws {
        let range: Range.Lazy = Range.Lazy(count: 100) { $0.position.rawValue }

        let dropped = range.drop.first(30)
        #expect(dropped.count == 70)

        let droppedDistance = try dropped.start.position.distance.forward(to: dropped.end.position)
        #expect(dropped.count.rawValue == droppedDistance)

        let prefixed = range.prefix.first(40)
        #expect(prefixed.count == 40)

        let prefixedDistance = try prefixed.start.position.distance.forward(to: prefixed.end.position)
        #expect(prefixed.count.rawValue == prefixedDistance)
    }

    @Test
    func `INVARIANT: reversed range preserves count`() throws {
        let range: Range.Lazy = Range.Lazy(count: 100) { $0.position.rawValue }
        let reversed = range.reversed()

        #expect(reversed.count == range.count)

        var forwardCount: UInt = 0
        range.forEach { _ in forwardCount += 1 }

        var reversedCount: UInt = 0
        reversed.forEach { _ in reversedCount += 1 }

        #expect(forwardCount == reversedCount)
    }
}

extension RangeLazyCardinalDistanceTests.LargeRanges {

    @Test
    func `INVARIANT: ranges exceeding Int.max distance work`() throws {
        // Cardinal distance handles full UInt range.
        // Affine subtraction would fail for distances > Int.max.

        let intMax = Range.Index.Count(UInt(Int.max))
        

        // Distance exactly Int.max
        let rangeAtLimit = .zero..<intMax
        #expect(rangeAtLimit.count == intMax)

        // Distance Int.max + 1 (would FAIL with affine subtraction)
        let rangeBeyond = .zero..<(intMax + .one)
        #expect(rangeBeyond.count == intMax + .one)

        
        let x = intMax + 1000
        
        // Distance Int.max + 1000
        let rangeWellBeyond = .zero..<x
        #expect(rangeWellBeyond == (intMax + 1000))
    }

    @Test
    func `INVARIANT: offset ranges with large distances work`() throws {
        let intMax = UInt(Int.max)
        let start: UInt = 1000
        let distance = intMax + 500
        let end = start + distance

        let range = Range.Lazy(start..<end) { $0 }

        #expect(range.count == distance)

        let cardinalDistance = try range.start.position.distance.forward(to: range.end.position)
        #expect(range.count.rawValue == cardinalDistance)
    }

    @Test
    func `INVARIANT: ranges near UInt.max work`() throws {
        let max = UInt.max

        // Range ending near UInt.max
        let rangeNearMax = Range.Lazy((max - 100)..<max) { $0 }
        #expect(rangeNearMax.count == 100)

        // Empty range near UInt.max
        let emptyNearMax = Range.Lazy((max - 1)..<(max - 1)) { $0 }
        #expect(emptyNearMax.isEmpty)
        #expect(emptyNearMax.count == 0)
    }

    @Test
    func `INVARIANT: maximum possible range 0 to UInt.max`() throws {
        // The largest possible range
        let range = Range.Lazy(0..<UInt.max) { $0 }

        #expect(range.count == UInt.max)

        let distance = try range.start.position.distance.forward(to: range.end.position)
        #expect(distance.rawValue == UInt.max)
    }

    @Test
    func `INVARIANT: drop and prefix near UInt.max`() throws {
        let max = UInt.max
        let range = Range.Lazy((max - 50)..<max) { $0 }

        let dropped = range.drop.first(20)
        #expect(dropped.count == 30)

        let prefixed = range.prefix.first(15)
        #expect(prefixed.count == 15)
    }
}
