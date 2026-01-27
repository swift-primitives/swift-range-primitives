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
        unsafe self.init(start: start, count: Int(count.rawValue))
    }
}
