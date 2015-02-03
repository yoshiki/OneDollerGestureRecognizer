import Foundation

public struct Vector2D {
    var x = 0.0, y = 0.0
}

public class DollerGestureRecognizer {
    public var touchPoints: Array<Vector2D>?
    public var resampledPoints: Array<Vector2D>?
    public var templates: Array<AnyObject>?
    
    public init() {
        
    }
    
    public func addPoint(x _: Float, y: Float) {
        
    }
    
    public func reset() {
    }
    
    public func find(completion: (name: String?, score: Float?) -> Void) {
        completion(name: "NaN", score: 0.0)
    }
}