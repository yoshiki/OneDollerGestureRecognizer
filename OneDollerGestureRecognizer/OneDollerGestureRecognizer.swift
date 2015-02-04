import Foundation
import CoreGraphics

public class OneDollerGestureRecognizer {
    let samplePoints = 32
    var touchPoints = [CGPoint]()
    var templates = [String: [CGPoint]]()
    
    public func addPoint(point: CGPoint) {
        self.touchPoints.append(point)
    }
    
    public func reset() {
        self.touchPoints.removeAll(keepCapacity: false)
    }
    
    public func detect(completion: (name: String?, score: Float?) -> Void) {
//        let result = Resample(self.touchPoints, self.samplePoints)
//        var bestTemplateName = ""
//        var best = Float.infinity
//        for (name, samples) in self.templates {
//            var template = [CGPoint]()
//            assert(self.samplePoints == samples.count, "Template size mismatch")
//            for i in 0..<self.samplePoints {
//                template.append(samples[i])
//            }
//            let score = DistanceAtBestAngle(result.samples, self.samplePoints, template)
//            if score < best {
//                bestTemplateName = name
//                best = score
//            }
//        }
//        var bestScore = best
//        completion(name: bestTemplateName, score: bestScore)
    }
    
//    public func serialize() -> (samples: [CGPoint], center: CGPoint, radians: Float) {
    public func serialize() {
//        let result = Resample(self.touchPoints, self.samplePoints)
//        return result
    }
    
    public func addTemplate(name: String, samples: [CGPoint]) {
        if let s = self.templates[name] {
            self.templates.updateValue(samples, forKey: name)
        } else {
            self.templates[name] = samples
        }
    }
    
}

func Recognize(points: [CGPoint], templates: [[CGPoint]]) {
    var best = Float.infinity
    for template in templates {
    }
}

//
func Resample(points: [CGPoint], n: Int) -> [CGPoint] {
    var origPoints = points
    var newPoints = [CGPoint]()
    let I = PathLength(origPoints) / (Float(n) - 1)
    var D: Float = 0.0
    newPoints.append(origPoints[0])
    for i in 1..<origPoints.count {
        var d = Distance(origPoints[i-1], origPoints[i])
        var q = CGPointZero
        if (D + d) >= I {
            q.x = origPoints[i-1].x + CGFloat((I-D)/d) * (origPoints[i].x - origPoints[i-1].x)
            q.y = origPoints[i-1].y + CGFloat((I-D)/d) * (origPoints[i].y - origPoints[i-1].y)
            newPoints.append(q)
            origPoints[i] = q
            D = 0.0
        } else {
            D = D + d
        }
    }
    return newPoints
}

//
func Centroid(points: [CGPoint]) -> CGPoint {
    var center = CGPointZero
    for i in 0..<points.count {
        let point = points[i]
        center.x += point.x
        center.y += point.y
    }
    center.x /= CGFloat(points.count)
    center.y /= CGFloat(points.count)
    return center
}

//
func Distance(point1: CGPoint, point2: CGPoint) -> Float {
    let dx = Float(point2.x - point1.x)
    let dy = Float(point2.y - point1.y)
    return sqrtf(dx * dx + dy * dy)
}

//
func PathLength(points: [CGPoint]) -> Float {
    var d: Float = 0.0
    for i in 1..<points.count {
        d += Distance(points[i-1], points[i])
    }
    return d
}

//
func RotateToZero(points: [CGPoint]) -> [CGPoint] {
    let c = Centroid(points)
    let theta = Float(atan2(c.y - points[0].y, c.x - points[0].x))
    var newPoints: [CGPoint] = RotateBy(points, theta)
    return newPoints
}

//
func RotateBy(points: [CGPoint], theta: Float) -> [CGPoint] {
    let rotateTransform = CGAffineTransformMakeRotation(CGFloat(theta))
    var newPoints = [CGPoint]()
    for point in points {
        let newPoint = CGPointApplyAffineTransform(point, rotateTransform)
        newPoints.append(newPoint)
    }
    return newPoints
}

//
func BoundingBox(points: [CGPoint]) -> CGSize {
    var lowerLeft = CGPointZero, upperRight = CGPointZero
    for point in points {
        if point.x < lowerLeft.x {
            lowerLeft.x = point.x
        }
        if point.y < lowerLeft.y {
            lowerLeft.y = point.y
        }
        if point.x > upperRight.x {
            upperRight.x = point.x
        }
        if point.y > upperRight.y {
            upperRight.y = point.y
        }
    }
    return CGSizeMake(upperRight.x - lowerLeft.x, lowerLeft.y - upperRight.y)
}

func Rotate(inout samples: [CGPoint], samplePoints: Int, radians: Float) {
    let rotateTransform = CGAffineTransformMakeRotation(CGFloat(radians))
    for i in 0..<samplePoints {
        let point0 = samples[i]
        let point = CGPointApplyAffineTransform(point0, rotateTransform)
        samples[i] = point
    }
}

func Scale(inout samples: [CGPoint], samplePoints: Int, xScale: CGFloat, yScale: CGFloat) {
    let scaleTransform = CGAffineTransformMakeScale(xScale, yScale)
    for i in 0..<samplePoints {
        let point0 = samples[i]
        let point = CGPointApplyAffineTransform(point0, scaleTransform)
        samples[i] = point
    }
}

func DistanceAtAngle(samples: [CGPoint], samplePoints: Int, template: [CGPoint], theta: Float) -> Float {
    let maxPoints = 128
    var newPoints = [CGPoint]()
    assert(samplePoints <= maxPoints, "`samplePoints` too large")
    for i in 0..<samplePoints {
        newPoints.append(samples[i])
    }
    Rotate(&newPoints, samplePoints, theta)
    return PathLength(newPoints)
}

func DistanceAtBestAngle(samples: [CGPoint], samplePoints: Int, template: [CGPoint]) -> Float {
    var a = Float(-0.25 * M_PI)
    var b = -a
    let threshold = 0.1
    let Phi = 0.5 * (-1.0 + sqrtf(5.0)) // Golden Ratio
    var x1 = Phi * a + (1.0 - Phi) * b
    var f1 = DistanceAtAngle(samples, samplePoints, template, x1)
    var x2 = (1.0 - Phi) * a + Phi * b
    var f2 = DistanceAtAngle(samples, samplePoints, template, x2)
    while fabs(Double(b - a)) > threshold {
        if f1 < f2 {
            b = x2
            x2 = x1
            f2 = f1
            x1 = Phi * a + (1.0 - Phi) * b
            f1 = DistanceAtAngle(samples, samplePoints, template, x1)
        } else {
            a = x1
            x1 = x2
            f1 = f2
            x2 = (1.0 - Phi) * a + Phi * b
            f2 = DistanceAtAngle(samples, samplePoints, template, x2)
        }
    }
    return min(f1, f2)
}
