---
name: range-primitives
description: |
  Range iteration primitives with first-class ~Copyable support.
  ALWAYS apply when working with range types or iteration over bounds.

layer: implementation

requires:
  - primitives
  - memory
  - naming

applies_to:
  - swift
  - swift-primitives
  - swift-range-primitives
---

# Range Primitives

First-class ~Copyable and Copyable range iteration primitives.

---

## Core Design Decisions

### [RNG-001] Lazy Range for ~Copyable Bounds

**Statement**: `Range.Lazy<Bound>` MUST support `~Copyable` bound types.

```swift
public struct Range<Bound: ~Copyable & Comparable>: ~Copyable {
    public struct Lazy: ~Copyable {
        // Supports borrowing and consuming iteration
    }
}
```

### [RNG-002] Separate Range from Iterator

**Statement**: Ranges MUST NOT be iterators. Iteration MUST be via separate types.

| Type | Role |
|------|------|
| `Range<Bound>` | Value representing bounds |
| `Range.Lazy<Bound>` | Lazy iteration adapter |
| `Range.Lazy.Iterator` | Actual iterator |

### [RNG-003] Dual Iteration Modes

**Statement**: Range iteration MUST support both borrowing and consuming patterns.

```swift
// Borrowing iteration - values remain valid
range.forEach { (element: borrowing Bound) in ... }

// Consuming iteration - takes ownership
range.drain { (element: consuming Bound) in ... }
```

### [RNG-004] Custom Operators for Index Bounds

**Statement**: Custom operators MAY be provided for `Index<Tag>.Count` bounds.

```swift
// Creates Range.Lazy<Index<Tag>>
let range = 0..<count  // where count: Index<Tag>.Count
```

---

## Type Hierarchy

```
Range<Bound: ~Copyable & Comparable>
├── .Lazy<Bound>         // Lazy iteration adapter
│   └── .Iterator        // Forward iterator
└── .Closed<Bound>       // Closed range variant
    └── .Lazy<Bound>
```

---

## Iteration Patterns

### Borrowing Iteration

```swift
// Elements borrowed, not consumed
range.lazy.forEach { element in
    print(element)  // borrowing access
}
```

### Consuming Iteration

```swift
// Elements consumed one by one
range.lazy.drain { element in
    process(element)  // consuming access
}
```

### Manual Iteration

```swift
var iterator = range.lazy.makeIterator()
while let element = iterator.next() {
    // Process element
}
```

### Reverse Iteration

```swift
range.lazy.reversed().forEach { element in
    // Process in reverse order
}
```

---

## Prior Art Integration

| Swift Institute | Swift Stdlib | Rust |
|-----------------|--------------|------|
| `Range.Lazy<B>` | `Range<B>` (Copyable only) | `Range<T>` + `IntoIterator` |
| `forEach` | `for...in` | `for_each` |
| `drain` | N/A | `drain` |

---

## Cross-References

| Topic | Skill |
|-------|-------|
| Index bounds | **index-primitives** |
| Memory ownership | **memory** |
| Sequence patterns | **sequence-primitives** |

Full design: `Research/range-primitives-design.md`
