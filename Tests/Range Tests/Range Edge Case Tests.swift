internal import Range
import Testing

extension `Range Tests`.`Edge Case` {

    @Test
    func `an empty range maps, filters and searches to nothing`() throws(Fault) {
        let empty = 5..<5
        #expect(try empty.map { (i: Int) throws(Fault) in i } == [])
        #expect(try empty.filter { (_: Int) throws(Fault) in true } == [])
        #expect(try empty.first { (_: Int) throws(Fault) in true } == nil)
        #expect(try empty.contains { (_: Int) throws(Fault) in true } == false)
        #expect(try empty.allSatisfy { (_: Int) throws(Fault) in false } == true)
        #expect(try empty.reduce(42) { (acc: Int, i: Int) throws(Fault) in acc + i } == 42)
        #expect(try empty.compactMap { (i: Int) throws(Fault) -> Int? in i } == [])
    }

    @Test
    func `a range ending at Int max visits its last element without overflowing`() throws(Fault) {
        let top = (Int.max - 2)..<Int.max
        #expect(try top.map { (i: Int) throws(Fault) in i } == [Int.max - 2, Int.max - 1])
        #expect(try top.first { (i: Int) throws(Fault) in i == Int.max - 1 } == Int.max - 1)
        var visited: [Int] = []
        try top.forEach { (i: Int) throws(Fault) in visited.append(i) }
        #expect(visited == [Int.max - 2, Int.max - 1])
    }

    @Test
    func `the full UInt8 range up to 255 has 255 elements`() throws(Fault) {
        let bytes: Range<UInt8> = 0..<255
        #expect(try bytes.map { (b: UInt8) throws(Fault) in b }.count == 255)
        #expect(try bytes.reduce(0) { (acc: Int, b: UInt8) throws(Fault) in acc + Int(b) } == 254 * 255 / 2)
    }

    @Test
    func `the first matching element is the lowest one`() throws(Fault) {
        #expect(try (0..<100).first { (i: Int) throws(Fault) in i % 7 == 6 } == 6)
    }

    @Test
    func `map bounds keeps an order-preserving transform's range`() {
        let range = (2..<5).map.bounds { $0 * 10 }
        #expect(range == 20..<50)
    }
}
