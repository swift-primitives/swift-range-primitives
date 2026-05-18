# ``Range_Primitives``

@Metadata {
    @DisplayName("Range Primitives")
    @TitleHeading("Swift Institute — Primitives Layer")
}

Sequence-like terminal operations on `Swift.Range` — `.forEach`, `.map`, `.filter`, `.reduce`, `.contains`, `.first`, `.allSatisfy`, `.compactMap` — provided directly on the stdlib range type without going through `Sequence` conformance.

## Overview

`Swift.Range<Bound>` conforms to `Swift.Sequence` only when `Bound: Strideable` and `Bound.Stride: SignedInteger`. The terminal operations in this package extend that surface with explicit method forms that work in the same constraint shape, plus the fluent `.<op>` Property.Inout accessors layered on top for composability with other Swift Institute primitives.

## Topics

### Terminal Operations

- ``Swift/Range/forEach(_:)-2nblb``
- ``Swift/Range/map(_:)-9dwxs``
- ``Swift/Range/filter(_:)-7p2xy``
- ``Swift/Range/reduce(_:_:)-3hcwa``
- ``Swift/Range/contains(where:)-5g6t1``
- ``Swift/Range/first(where:)-2u7jt``
- ``Swift/Range/allSatisfy(_:)-9zvxe``
- ``Swift/Range/compactMap(_:)-7lvkn``
