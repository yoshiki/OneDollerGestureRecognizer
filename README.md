# OneDollerGestureRecognizer

A library to recognize gesture using the [$1 Unistroke Recognizer](http://depts.washington.edu/aimgroup/proj/dollar/) in Swift. This library is a port of [GLGestureRecognizer](https://github.com/preble/GLGestureRecognizer) to Swift.

The $1 Unistroke Recognizer is a simple gesture recognition algorithm. You can detect gesture easily using this library.

# Installation

Drop in the OneDollerGestureRecognizer/ directory to your Xcode project.

Or via CocoaPods,

`pod 'OneDollerGestureRecognizer', :git => 'https://github.com/yoshiki/OneDollerGestureRecognizer.git'`

# Usage

## Initialize

```swift
let recognizer = OneDollerGestureRecognizer()
```

## Add point

A `point` is CGPoint.

```swift
recognizer.addPoint(point)
```

## Get sampling data

```swift
var result = recognizer.serialize()
println(result.samples) // A data sampled
println(result.center)  // A center point sampled
println(result.radians) // A radians sampled
```

## Add template

A `name` is a template name. A `samples` is `Array` that include points of template.

```swift
let name = "Some Gesture"
let samples = [ CGPointMake(0, 0), CGPointMake(0, 0), ... ]; // Samples must have 32 values.
recognizer.addTemplate(name, samples: samples)
```

## Detect gesture

Detect gesture choose from templates.

```swift
recognizer.detect { (name, score) -> Void in
    println("Matched template name: \(name)")
    println("Score: \(score)")
}
```

## Reset all points

Reset all points added till then.

```swift
recognizer.reset()
```

# License

OneDollerGestureRecognizer is released udner the MIT license. See LICENSE for details.

