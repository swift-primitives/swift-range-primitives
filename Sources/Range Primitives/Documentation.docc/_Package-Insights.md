# Range Primitives Insights

<!--
---
title: Range Primitives Insights
version: 1.0.0
last_updated: 2026-01-28
applies_to: [swift-range-primitives]
normative: false
---
-->

@Metadata {
    @TitleHeading("Range Primitives")
}

Design decisions, implementation patterns, and lessons learned specific to this package.

## Overview

This document captures insights that emerged during development of swift-range-primitives. These are not API requirements—they are recorded decisions and patterns that inform future work on this package.

**Document type**: Non-normative (recorded decisions, not requirements).

**Consolidation source**: Reflection entries tagged with `[Package: swift-range-primitives]`.

---

## The Typed Domain Pattern for Index Arithmetic

**Date**: 2026-01-28

**Context**: Refactoring Range.Lazy iteration to eliminate raw arithmetic patterns like `position.rawValue + 1`.

The original iterator code used raw arithmetic to advance positions:

```swift
current = Range.Index(__unchecked: (), Ordinal(current.position.rawValue + 1))
```

This extracts the raw value, performs integer arithmetic, wraps it back in Ordinal, then wraps that in Range.Index. Four operations to express "move to the next position." The pattern leaked the implementation abstraction and created visual noise.

The refactored version stays in the typed domain:

```swift
current += .one
```

No raw value extraction. No manual wrapping. The `+=` operator is defined on `Index<Tag>` taking `Index<Tag>.Count`, and `.one` resolves to `Index<Tag>.Count.one` via type inference. The type system handles the arithmetic while the call site expresses pure intent: "increment by one."

The elegance depends on infrastructure: `Index<Tag> += Index<Tag>.Count` defined in Cardinal Primitives as a Tagged extension, `Index<Tag>.Count.one` as a static constant, and Swift's inference selecting the right `.one` based on context. Infrastructure should be felt, not seen.

**Applies to**: `Range.Lazy.Iterator`, successor patterns, typed domain arithmetic.

---

## try! with Proof Comments Over Unchecked Variants

**Date**: 2026-01-28

**Context**: Deciding how to handle mathematically-safe but potentially-throwing operations in iteration code.

The predecessor pattern `try! i.predecessor.exact()` throws when `i == 0`. In iteration contexts, we often have proof that `i > 0`—the loop invariant guarantees it. Two approaches were considered:

1. Add `predecessor.unchecked()` that skips the check
2. Use `try!` with a comment explaining why it's safe

Adding `.unchecked()` creates API surface that invites misuse. Every unchecked variant is a potential bug site where someone uses it without valid proof. The throwing variant exists because the operation IS partial; pretending otherwise through an unchecked variant is dishonest.

The solution: `try! i.predecessor.exact()` with a proof comment:

```swift
// Safe: i > start >= 0, so i > 0
i = try! i.predecessor.exact()
```

The `try!` is explicit about forcing a partial operation. The comment documents why it's safe in this context. If the proof is wrong, the code crashes with a clear stack trace pointing at the `try!`. This is preferable to undefined behavior from an unchecked variant.

The comment isn't ceremony—it's documentation of the loop invariant. Future readers see both the assertion (try!) and its justification (the comment).

**Applies to**: `Range.Lazy.Reversed` iteration, predecessor patterns, proof-documented assertions.

---

## Topics

### Related Documents

- <doc:Range-Lazy>
- <doc:Range-Lazy-Reversed>
