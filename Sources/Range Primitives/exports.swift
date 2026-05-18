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

// MARK: - Range Primitives
//
// Property-accessor bridges onto `Swift.Range` that express constraints
// stdlib's existing methods cannot — most commonly typed-throws
// preservation past stdlib's `rethrows` erasure on `Sequence.forEach`,
// `.map`, `.filter`, `.reduce`, `.allSatisfy`, `.contains(where:)`,
// `.first(where:)`, and `.compactMap`. Also hosts bound-transformation
// (`range.map.bounds { (Bound) -> T }`) for typed-Index integration.
//
// Scope: extensions on `Swift.Range` only. The package introduces no
// ecosystem range type; the institute's typed iteration carrier is
// `Vector<Bound>` in `swift-vector-primitives`.
//
// Mechanism: each verb is declared as a Property accessor — a computed
// `var` returning `Property<Tag, Swift.Range<Bound>>` — that coexists
// with stdlib's inherited method of the same name. Swift's overload
// resolution selects the Property path when the closure shape requires
// the institute constraint; non-throwing call sites continue to resolve
// to stdlib's inherited method.

@_exported public import Property_Primitives
