# Range

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Sequence-like terminal operations on `Swift.Range` for Swift — `.forEach { }`, `.map { }`, `.filter { }`, `.reduce(_:_:)`, `.contains(where:)`, `.first(where:)`, `.allSatisfy { }`, and `.compactMap { }` — provided directly on the standard library's `Swift.Range` with typed-throws preservation and Property-backed fluent accessors.

The standard library's `Swift.Range<Bound>` conforms to `Swift.Sequence` only when `Bound: Strideable` and `Bound.Stride: SignedInteger`. The terminal operations in this package use the same constraint shape, plus fluent `.<op>` `Property<Tag, Base>` accessors for composition with other primitives.

This package is part of the **data-structures cohort** (`data-structures-launch-2026`) — a dependency of the typed-indexing Story 2 packages (notably vector-primitives). Range depends only on swift-property for the fluent `Property<Tag, Base>` accessor machinery.

---

## Quick Start

```swift
import Range

let range = 1..<11

// Terminal operations directly on Swift.Range.
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
    .package(url: "https://github.com/swift-molecules/swift-range.git", branch: "main"),
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Range", package: "swift-range"),
    ]
)
```

The package is pre-1.0 — until 0.1.0 is tagged, depend on `branch: "main"` rather than `from: "0.1.0"`. Requires Swift 6.4 and macOS 27 / iOS 27 / tvOS 27 / watchOS 27 / visionOS 27 (or the matching Linux / Windows toolchain).

---

## Architecture

The core and standard-library integration products are Foundation-free. Foundation is isolated to the Apple Foundation integration product.

| Product | When to import | What's in it |
|---------|---------------|--------------|
| `Range` | Default for application code | Extension files providing `.forEach`, `.map`, `.filter`, `.reduce`, `.contains`, `.first`, `.allSatisfy`, `.compactMap` on `Swift.Range`. |
| `Range Standard Library Integration` | Standard-library integration surface | Reexports the core Range surface for integration consumers. |
| `Range Apple Foundation Integration` | Apple-platform integration surface | Reexports Range and its standard-library integration alongside Foundation. |

The terminal-operation surface mirrors `Swift.Sequence`'s API directly — each method shares the protocol's signature and semantics. The difference is the entry point: where `Sequence.map { }` requires the range to satisfy stdlib's full `Sequence` protocol (and `Strideable` arithmetic), the per-range overloads here work for any `Swift.Range<Bound>` where `Bound: Strideable, Bound.Stride: SignedInteger`.

---

## Platform Support

| Platform | CI | Status |
|----------|-----|--------|
| macOS 27 | Yes | Full support |
| iOS / tvOS / watchOS / visionOS | — | Supported |
| Linux | Yes | Full support |
| Windows | Yes | Full support |

---

## Stability

Pre-1.0. The public API may change while the package remains on `branch: "main"`; consumers should expect breaking changes to surface in commit messages until the first tag. Once tagged, the package follows institute SemVer: post-1.0 breaking changes ship behind a major bump.

---

## Related Packages

Direct dependency:

- [swift-property](https://github.com/swift-atoms/swift-property) — `Property<Tag, Base>`, the phantom-tagged fluent-accessor machinery the terminal operations compose with.

Cohort siblings (Story 2 — Typed indexing and sequences) — see [`data-structures-launch-2026`](https://github.com/swift-institute) for the cohort narrative.

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public release.*
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
