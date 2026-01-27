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

// MARK: - UnsafeRawPointer + Range.Index

extension UnsafeRawPointer {
    /// Returns a pointer offset by the specified range index position.
    @inlinable
    public func advanced(
        by index: Range.Index
    ) -> Self {
        unsafe self.advanced(by: Int(index.position.rawValue))
    }
}

