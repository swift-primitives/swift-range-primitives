//
//  File.swift
//  swift-range-primitives
//
//  Created by Coen ten Thije Boonkkamp on 27/01/2026.
//

// MARK: - UnsafeRawBufferPointer + Range.Index

extension UnsafeRawBufferPointer {
    /// Creates a buffer pointer from a start address and range count.
    @inlinable
    public init(
        start: UnsafeRawPointer?,
        count: Range.Index.Count
    ) {
        unsafe self.init(start: start, count: Int(bitPattern: count.count.rawValue))
    }

    /// Accesses the byte at the given range index.
    @inlinable
    public subscript(
        _ index: Range.Index
    ) -> UInt8 {
        unsafe self[Int(bitPattern: index.position.rawValue)]
    }
}
