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
        let result = self.resample()
        var bestTemplateName = ""
        var best = Float.infinity
        for (name, samples) in self.templates {
            var template = [CGPoint]()
            assert(self.samplePoints == samples.count, "Template size mismatch")
            for i in 0..<self.samplePoints {
                template.append(samples[i])
            }
            let score = DistanceAtBestAngle(result.samples, self.samplePoints, template)
            if score < best {
                bestTemplateName = name
                best = score
            }
        }
        var bestScore = best
        completion(name: bestTemplateName, score: bestScore)
    }
    
    public func serialize() -> (samples: [CGPoint], center: CGPoint, radians: Float) {
        let result = self.resample()
        return result
    }
    
    public func addTemplate(name: String, samples: [CGPoint]) {
        if let s = self.templates[name] {
            self.templates.updateValue(samples, forKey: name)
        } else {
            self.templates[name] = samples
        }
    }
    
    func resample() -> (samples: [CGPoint], center: CGPoint, radians: Float) {
        var samples = [CGPoint]()
        let c = self.touchPoints.count
        
        for i in 0..<self.samplePoints {
            samples.append(self.touchPoints[max(0, (c-1)*i/(self.samplePoints-1))])
        }
        
        var center = Centroid(samples, self.samplePoints)
        var outCenter = center
        Translate(&samples, self.samplePoints, -center.x, -center.y) // Recenter
        
        // Now rotate the path around 0,0, since the points have been transformed to that point.
        // Find the angle of the first point:
        let firstPoint = samples[0]
        let firstPointAngle = Float(atan2(Double(firstPoint.y), Double(firstPoint.x)))
        var outRadians = firstPointAngle
        Rotate(&samples, self.samplePoints, -firstPointAngle)
        
        var lowerLeft = CGPointZero, upperRight = CGPointZero
        for i in 0..<self.samplePoints {
            let point = samples[i]
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
        
        let scale = 2.0 / max(upperRight.x - lowerLeft.x, upperRight.y - lowerLeft.y)
        Scale(&samples, self.samplePoints, scale, scale)
        
        center = Centroid(samples, self.samplePoints)
        Translate(&samples, self.samplePoints, -center.x, -center.y) // Recenter
        
        return (samples, outCenter, outRadians)
    }
}

func Centroid(samples: [CGPoint], samplePoints: Int) -> CGPoint {
    var center = CGPointZero
    for i in 0..<samplePoints {
        let point = samples[i]
        center.x += point.x
        center.y += point.y
    }
    center.x /= CGFloat(samplePoints)
    center.y /= CGFloat(samplePoints)
    return center
}

func Translate(inout samples: [CGPoint], samplePoints: Int, x: CGFloat, y: CGFloat) {
    for i in 0..<samplePoints {
        let point = samples[i]
        samples[i] = CGPointMake(point.x + x, point.y + y)
    }
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

func Distance(point1: CGPoint, point2: CGPoint) -> Float {
    let dx = Float(point2.x - point1.x)
    let dy = Float(point2.y - point1.y)
    return sqrtf(dx * dx + dy * dy)
}

func PathDistance(points1: [CGPoint], points2: [CGPoint], count: Int) -> Float {
    var d: Float = 0.0
    for i in 0..<count {
        d += Distance(points1[i], points2[i])
    }
    return d / Float(count)
}

func DistanceAtAngle(samples: [CGPoint], samplePoints: Int, template: [CGPoint], theta: Float) -> Float {
    let maxPoints = 128
    var newPoints = [CGPoint]()
    assert(samplePoints <= maxPoints, "`samplePoints` too large")
    for i in 0..<samplePoints {
        newPoints.append(samples[i])
    }
    Rotate(&newPoints, samplePoints, theta)
    return PathDistance(newPoints, template, samplePoints)
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
