import Foundation
import CoreGraphics

public class OneDollerGestureRecognizer {
    let n = 32 // number of sampling points
    var touchPoints = [CGPoint]()
    var templates = [String: [CGPoint]]()
    
    public func addPoint(point: CGPoint) {
        self.touchPoints.append(point)
    }
    
    public func reset() {
        self.touchPoints.removeAll(keepCapacity: false)
    }
    
    public func detect(completion: (name: String?, score: Float?) -> Void) {
        var resampledPoints = Resample(self.touchPoints, self.n)
        resampledPoints = RotateToZero(resampledPoints)
        resampledPoints = ScaleToSquare(resampledPoints)
        resampledPoints = TranslateToOrigin(resampledPoints)
        let result = Recognize(resampledPoints, self.templates)
        completion(name: result.name, score: result.score)
    }
    
    public func serialize() -> [CGPoint] {
        var resampledPoints = Resample(self.touchPoints, self.n)
        resampledPoints = RotateToZero(resampledPoints)
        resampledPoints = ScaleToSquare(resampledPoints)
        resampledPoints = TranslateToOrigin(resampledPoints)
        return resampledPoints
    }
    
    public func addTemplate(name: String, samples: [CGPoint]) {
        if let s = self.templates[name] {
            self.templates.updateValue(samples, forKey: name)
        } else {
            self.templates[name] = samples
        }
    }
    
}

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

func Centroid(points: [CGPoint]) -> CGPoint {
    var center = CGPointZero
    for point in points {
        center.x += point.x
        center.y += point.y
    }
    center.x /= CGFloat(points.count)
    center.y /= CGFloat(points.count)
    return center
}

func Distance(point1: CGPoint, point2: CGPoint) -> Float {
    let dx = Float(point2.x - point1.x)
    let dy = Float(point2.y - point1.y)
    return sqrtf(dx * dx + dy * dy)
}

func PathLength(points: [CGPoint]) -> Float {
    var d: Float = 0.0
    for i in 1..<points.count {
        d += Distance(points[i-1], points[i])
    }
    return d
}

func RotateToZero(points: [CGPoint]) -> [CGPoint] {
    let c = Centroid(points)
    let theta = Float(atan2(c.y - points[0].y, c.x - points[0].x))
    var newPoints: [CGPoint] = RotateBy(points, theta)
    return newPoints
}

func RotateBy(points: [CGPoint], theta: Float) -> [CGPoint] {
    let rotateTransform = CGAffineTransformMakeRotation(CGFloat(theta))
    var newPoints = [CGPoint]()
    for point in points {
        let newPoint = CGPointApplyAffineTransform(point, rotateTransform)
        newPoints.append(newPoint)
    }
    return newPoints
}

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

func ScaleToSquare(points: [CGPoint], size: Int = 2) -> [CGPoint] {
    var b = BoundingBox(points)
    var q = CGPointZero
    var newPoints = [CGPoint]()
    for point in points {
        q.x = point.x * (CGFloat(size) / b.width)
        q.y = point.y * (CGFloat(size) / b.height)
        newPoints.append(q)
    }
    return newPoints
}

func TranslateToOrigin(points: [CGPoint]) -> [CGPoint] {
    var c = Centroid(points)
    var q = CGPointZero
    var newPoints = [CGPoint]()
    for point in points {
        q.x = point.x - c.x
        q.y = point.y - c.y
        newPoints.append(q)
    }
    return newPoints
}

func Recognize(points: [CGPoint], templates: [String: [CGPoint]]) -> (name: String, score: Float) {
    var b = Float.infinity // best distance
    var n = "" // best template name
    for (name, template) in templates {
        var d = DistanceAtBestAngle(points, template)
        if d < b {
            b = d
            n = name
        }
    }
    var size: Float = 2
    var score = 1 - b / 0.5 * sqrtf(powf(size, 2) + powf(size, 2))
    return (n, score)
}

func DistanceAtBestAngle(points: [CGPoint], template: [CGPoint]) -> Float {
    var a = Float(-0.25 * M_PI) // theta A
    var b = -a // theta B
    var threshold: Float = 0.1 // theta delta
    let Phi = 1/2 * (-1.0 + sqrtf(5.0))
    var x1 = Phi * a + (1.0 - Phi) * b
    var f1 = DistanceAtAngle(points, template, x1)
    var x2 = (1.0 - Phi) * a + Phi * b
    var f2 = DistanceAtAngle(points, template, x2)
    while fabsf(Float(b - a)) > threshold {
        if f1 < f2 {
            b = x2
            x2 = x1
            f2 = f1
            x1 = Phi * a + (1.0 - Phi) * b
            f1 = DistanceAtAngle(points, template, x1)
        } else {
            a = x1
            x1 = x2
            f1 = f2
            x2 = (1.0 - Phi) * a + Phi * b
            f2 = DistanceAtAngle(points, template, x2)
        }
    }
    return min(f1, f2)
}

func DistanceAtAngle(points: [CGPoint], template: [CGPoint], theta: Float) -> Float {
    var newPoints = RotateBy(points, theta)
    var d = PathDistance(newPoints, template)
    return d
}

func PathDistance(A: [CGPoint], B: [CGPoint]) -> Float {
    var d: Float = 0.0
    for i in 0..<A.count {
        d += Distance(A[i], B[i])
    }
    return d / Float(A.count)
}
