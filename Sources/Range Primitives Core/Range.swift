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

@_exported public import Vector_Primitives

/// Deprecated namespace — use `Vector<Bound>` directly.
///
/// `Range.Lazy<Bound>` has been renamed to `Vector<Bound>` in swift-vector-primitives.
/// This shim provides backward compatibility during migration.
@available(*, deprecated, renamed: "Vector")
public enum Range {
    @available(*, deprecated, renamed: "Vector")
    public typealias Lazy<Bound: ~Copyable> = Vector<Bound>

    @available(*, deprecated, message: "Use Vector<Bound>.Index instead")
    public typealias Index = Index_Primitives.Index<Range>
}
