//
//  File.swift
//  swift-range-primitives
//
//  Created by Coen ten Thije Boonkkamp on 27/01/2026.
//

// MARK: - UnsafeMutableRawBufferPointer + Range.Index

extension UnsafeMutableRawBufferPointer {
    /// Creates a mutable buffer pointer from a start address and range count.
    @inlinable
    public init(
        start: UnsafeMutableRawPointer?,
        count: Range.Index.Count
    ) {
        unsafe self.init(start: start, count: Int(bitPattern: count.count.rawValue))
    }

    /// Allocates uninitialized memory with range-typed count and alignment.
    @inlinable
    public static func allocate(
        count: Range.Index.Count,
        alignment: Range.Index.Count
    ) -> Self {
        Self.allocate(byteCount: Int(bitPattern: count.count.rawValue), alignment: Int(bitPattern: alignment.count.rawValue))
    }

    /// Accesses the byte at the given range index.
    @inlinable
    public subscript(
        _ index: Range.Index
    ) -> UInt8 {
        get { unsafe self[Int(bitPattern: index.position.rawValue)] }
        nonmutating set { unsafe self[Int(bitPattern: index.position.rawValue)] = newValue }
    }
}
