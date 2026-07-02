# Range Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Sequence-like terminal operations on `Swift.Range` for Swift — `.forEach { }`, `.map { }`, `.filter { }`, `.reduce(_:_:)`, `.contains(where:)`, `.first(where:)`, `.allSatisfy { }`, `.compactMap { }`, provided directly on stdlib's `Swift.Range` without going through `Sequence` conformance. The methods are ergonomic surface for the common case where a numeric range is the iteration target and an Array allocation for the materialized values is unnecessary.

Stdlib's `Swift.Range<Bound>` conforms to `Swift.Sequence` only when `Bound: Strideable` and `Bound.Stride: SignedInteger` — i.e. for integer ranges. The terminal operations in this package extend that surface with explicit method forms that work in the same constraint shape, plus the fluent `.<op>` Property.Inout accessors layered on top for composability with other primitives.

This package is part of the **data-structures cohort** (`data-structures-launch-2026`) — a dependency of the typed-indexing Story 2 packages (notably vector-primitives). Range depends only on swift-property-primitives for the fluent Property.Inout accessor machinery.

---

## Quick Start

```swift
import Range_Primitives

let range = 1...10

// Terminal operations directly on Swift.Range — no Array allocation.
let sum = range.reduce(0, +)                     // 55
let evens = range.filter { $0 % 2 == 0 }         // [2, 4, 6, 8, 10]
let doubled = range.map { $0 * 2 }               // [2, 4, ..., 20]
let hasNegative = range.contains { $0 < 0 }      // false
let firstBig = range.first { $0 > 7 }            // Optional(8)
let allPositive = range.allSatisfy { $0 > 0 }    // true

// forEach is the canonical iteration form.
range.forEach { print($0) }                      // 1 ... 10
```

---

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-range-primitives.git", branch: "main"),
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Range Primitives", package: "swift-range-primitives"),
    ]
)
```

The package is pre-1.0 — until 0.1.0 is tagged, depend on `branch: "main"` rather than `from: "0.1.0"`. Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

One library product. Foundation-free. No concurrency surface. No platform conditionals.

| Product | When to import | What's in it |
|---------|---------------|--------------|
| `Range Primitives` | Default for application code | Extension files providing `.forEach`, `.map`, `.filter`, `.reduce`, `.contains`, `.first`, `.allSatisfy`, `.compactMap` on `Swift.Range`. |

The terminal-operation surface mirrors `Swift.Sequence`'s API directly — each method shares the protocol's signature and semantics. The difference is the entry point: where `Sequence.map { }` requires the range to satisfy stdlib's full `Sequence` protocol (and `Strideable` arithmetic), the per-range overloads here work for any `Swift.Range<Bound>` where `Bound: Strideable, Bound.Stride: SignedInteger`.

---

## Platform Support

| Platform | CI | Status |
|----------|-----|--------|
| macOS 26 | Yes | Full support |
| iOS / tvOS / watchOS / visionOS | — | Supported |
| Linux | Yes | Full support |
| Windows | Yes | Full support |

---

## Stability

Pre-1.0. The public API may change while the package remains on `branch: "main"`; consumers should expect breaking changes to surface in commit messages until the first tag. Once tagged, the package follows institute SemVer: post-1.0 breaking changes ship behind a major bump.

---

## Related Packages

Direct dependency:

- [swift-property-primitives](https://github.com/swift-primitives/swift-property-primitives) — `Property<Tag, Base>.Inout`, the phantom-tagged fluent-accessor machinery the terminal operations compose with.

Cohort siblings (Story 2 — Typed indexing and sequences) — see [`data-structures-launch-2026`](https://github.com/swift-institute) for the cohort narrative.

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public release.*
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
