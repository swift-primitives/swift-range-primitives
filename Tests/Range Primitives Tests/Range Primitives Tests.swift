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

internal import Range_Primitives
import Testing

enum Fault: Swift.Error, Equatable {
    case oops(Int)
}

@Suite
struct `Range Primitives Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Range Primitives Tests`.Unit {

    @Test
    func `forEach preserves typed throws`() {
        do throws(Fault) {
            try (0..<3).forEach { (i: Int) throws(Fault) in
                if i == 1 { throw .oops(i) }
            }
            Issue.record("expected throw")
        } catch {
            let e: Fault = error
            #expect(e == .oops(1))
        }
    }

    @Test
    func `map preserves typed throws`() {
        do throws(Fault) {
            let _: [String] = try (0..<3).map { (i: Int) throws(Fault) -> String in
                if i == 2 { throw .oops(i) }
                return "v\(i)"
            }
            Issue.record("expected throw")
        } catch {
            let e: Fault = error
            #expect(e == .oops(2))
        }
    }

    @Test
    func `map.bounds transforms both endpoints`() {
        let r: Swift.Range<Int> = 0..<3
        let doubled: Swift.Range<Int> = r.map.bounds { $0 * 2 }
        #expect(doubled.lowerBound == 0)
        #expect(doubled.upperBound == 6)
    }

    @Test
    func `filter preserves typed throws`() {
        do throws(Fault) {
            let _: [Int] = try (0..<5).filter { (i: Int) throws(Fault) in
                if i == 3 { throw .oops(i) }
                return i.isMultiple(of: 2)
            }
            Issue.record("expected throw")
        } catch {
            let e: Fault = error
            #expect(e == .oops(3))
        }
    }

    @Test
    func `reduce preserves typed throws`() {
        do throws(Fault) {
            let _: Int = try (0..<5).reduce(0) { (acc: Int, i: Int) throws(Fault) in
                if i == 2 { throw .oops(i) }
                return acc + i
            }
            Issue.record("expected throw")
        } catch {
            let e: Fault = error
            #expect(e == .oops(2))
        }
    }

    @Test
    func `allSatisfy, contains, first, compactMap preserve typed throws`() {
        do throws(Fault) {
            _ = try (0..<3).allSatisfy { (i: Int) throws(Fault) in
                if i == 1 { throw .oops(i) }
                return true
            }
            Issue.record("expected throw")
        } catch {
            #expect((error as Fault) == .oops(1))
        }

        do throws(Fault) {
            _ = try (0..<3).contains { (i: Int) throws(Fault) in
                if i == 1 { throw .oops(i) }
                return false
            }
            Issue.record("expected throw")
        } catch {
            #expect((error as Fault) == .oops(1))
        }

        do throws(Fault) {
            _ = try (0..<3).first { (i: Int) throws(Fault) in
                if i == 1 { throw .oops(i) }
                return false
            }
            Issue.record("expected throw")
        } catch {
            #expect((error as Fault) == .oops(1))
        }

        do throws(Fault) {
            let _: [Int] = try (0..<3).compactMap { (i: Int) throws(Fault) -> Int? in
                if i == 1 { throw .oops(i) }
                return nil
            }
            Issue.record("expected throw")
        } catch {
            #expect((error as Fault) == .oops(1))
        }
    }
}

extension `Range Primitives Tests`.`Edge Case` {

    @Test
    func `non-throwing forEach resolves to stdlib`() {
        var collected: [Int] = []
        (0..<3).forEach { collected.append($0) }
        #expect(collected == [0, 1, 2])
    }
}
