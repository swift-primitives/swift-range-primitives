//
//  File.swift
//  swift-range-primitives
//
//  Created by Coen ten Thije Boonkkamp on 27/01/2026.
//

// MARK: - UnsafeMutableRawPointer + Range.Index

extension UnsafeMutableRawPointer {
    /// Returns a pointer offset by the specified range index position.
    @inlinable
    public func advanced(
        by index: Range.Index
    ) -> Self {
        unsafe self.advanced(by: Int(bitPattern: index))
    }
}
