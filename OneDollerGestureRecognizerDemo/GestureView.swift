import UIKit

enum GestureViewMode {
    case Detect
    case Register
}

protocol GestureViewDelegate {
    func detect(name: String, score: Float)
}

class GestureView: UIView {
    var gestureRecognizer: OneDollerGestureRecognizer = OneDollerGestureRecognizer()
    var path: UIBezierPath = UIBezierPath()
    var resamplePath: UIBezierPath = UIBezierPath()
    var mode: GestureViewMode = GestureViewMode.Register
    var delegate: GestureViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }

    func commonInit() {
        self.path.lineCapStyle = kCGLineCapRound
        self.path.miterLimit = 0.0
        self.path.lineWidth = 5.0
        
        self.resamplePath.lineCapStyle = kCGLineCapRound
        self.resamplePath.miterLimit = 0.0
        self.resamplePath.lineWidth = 5.0
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.gestureRecognizer.reset()
        self.cleanup()
        
        let touch = touches.anyObject() as UITouch
        let point = touch.locationInView(self)
        self.gestureRecognizer.addPoint(point)
        self.path.moveToPoint(point)
        
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let point = touch.locationInView(self)
        self.gestureRecognizer.addPoint(point)
        self.path.addLineToPoint(point)
        self.setNeedsDisplay()
        
        super.touchesMoved(touches, withEvent: event)
    }

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.anyObject() as UITouch!
        var point = touch.locationInView(self)
        self.gestureRecognizer.addPoint(point)
        
        switch self.mode {
        case .Register:
            var resampledPoints = self.gestureRecognizer.serialize()
            self.drawResample(resampledPoints)
        case .Detect:
            self.gestureRecognizer.detect { (name, score) -> Void in
                println("matched name: \(name!), score: \(score!)")
                if let delegate = self.delegate {
                    delegate.detect(name!, score: score!)
                }
                self.cleanup()
            }
        }

        super.touchesEnded(touches, withEvent: event)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        UIColor.whiteColor().setStroke()
        self.path.strokeWithBlendMode(kCGBlendModeNormal, alpha: 0.5)
        
        if !self.resamplePath.empty {
            UIColor.greenColor().setStroke()
            self.resamplePath.strokeWithBlendMode(kCGBlendModeNormal, alpha: 0.5)
        }
    }
    
    func drawResample(resamplePoints: [CGPoint]) {
        for i in 0..<resamplePoints.count {
            var pointInView: CGPoint = resamplePoints[i]
            pointInView.x = pointInView.x * 100.0 + UIScreen.mainScreen().applicationFrame.width / 2;
            pointInView.y = pointInView.y * 100.0 + UIScreen.mainScreen().applicationFrame.height / 2;
            if i == 0 {
                self.resamplePath.moveToPoint(pointInView)
            } else {
                self.resamplePath.addLineToPoint(pointInView)
            }
        }
        self.setNeedsDisplay()
        
#if DEBUG
        println("[")
        for i in 0..<resamplePoints.count {
            println(NSString(format: "CGPointMake(%0.2f, %0.2f),", Float(resamplePoints[i].x), Float(resamplePoints[i].y)))
        }
        println("]")
#endif
    }
    
    func cleanup() {
        if !self.path.empty || !self.resamplePath.empty {
            self.path.removeAllPoints()
            self.resamplePath.removeAllPoints()
            self.setNeedsDisplay()
        }
    }
    
    func registerTemplate() {
        var templates: [String: [CGPoint]] = [
            "Triangle": [
                CGPointMake(0.56, 0.13),
                CGPointMake(0.47, 0.16),
                CGPointMake(0.38, 0.21),
                CGPointMake(0.29, 0.26),
                CGPointMake(0.20, 0.31),
                CGPointMake(0.11, 0.35),
                CGPointMake(0.01, 0.39),
                CGPointMake(-0.08, 0.44),
                CGPointMake(-0.16, 0.49),
                CGPointMake(-0.25, 0.55),
                CGPointMake(-0.27, 0.47),
                CGPointMake(-0.26, 0.37),
                CGPointMake(-0.26, 0.26),
                CGPointMake(-0.27, 0.15),
                CGPointMake(-0.27, 0.04),
                CGPointMake(-0.26, -0.07),
                CGPointMake(-0.27, -0.18),
                CGPointMake(-0.28, -0.29),
                CGPointMake(-0.29, -0.40),
                CGPointMake(-0.29, -0.51),
                CGPointMake(-0.29, -0.61),
                CGPointMake(-0.22, -0.54),
                CGPointMake(-0.14, -0.46),
                CGPointMake(-0.06, -0.40),
                CGPointMake(0.02, -0.33),
                CGPointMake(0.10, -0.27),
                CGPointMake(0.19, -0.21),
                CGPointMake(0.27, -0.15),
                CGPointMake(0.36, -0.10),
                CGPointMake(0.44, -0.04),
                CGPointMake(0.52, 0.01),
            ],
            "Circle": [
                CGPointMake(0.48, -0.09),
                CGPointMake(0.48, -0.26),
                CGPointMake(0.44, -0.40),
                CGPointMake(0.38, -0.53),
                CGPointMake(0.30, -0.62),
                CGPointMake(0.22, -0.70),
                CGPointMake(0.13, -0.77),
                CGPointMake(0.04, -0.77),
                CGPointMake(-0.06, -0.76),
                CGPointMake(-0.15, -0.74),
                CGPointMake(-0.23, -0.67),
                CGPointMake(-0.31, -0.57),
                CGPointMake(-0.38, -0.46),
                CGPointMake(-0.41, -0.31),
                CGPointMake(-0.44, -0.15),
                CGPointMake(-0.45, 0.01),
                CGPointMake(-0.46, 0.17),
                CGPointMake(-0.46, 0.34),
                CGPointMake(-0.41, 0.47),
                CGPointMake(-0.34, 0.58),
                CGPointMake(-0.26, 0.67),
                CGPointMake(-0.17, 0.72),
                CGPointMake(-0.08, 0.77),
                CGPointMake(0.02, 0.78),
                CGPointMake(0.11, 0.78),
                CGPointMake(0.20, 0.74),
                CGPointMake(0.28, 0.64),
                CGPointMake(0.33, 0.51),
                CGPointMake(0.38, 0.37),
                CGPointMake(0.41, 0.21),
                CGPointMake(0.41, 0.05),
            ],
            "Star": [
                CGPointMake(0.49, -0.11),
                CGPointMake(0.35, 0.01),
                CGPointMake(0.22, 0.16),
                CGPointMake(0.08, 0.29),
                CGPointMake(-0.06, 0.41),
                CGPointMake(-0.20, 0.55),
                CGPointMake(-0.34, 0.66),
                CGPointMake(-0.34, 0.58),
                CGPointMake(-0.26, 0.34),
                CGPointMake(-0.19, 0.08),
                CGPointMake(-0.12, -0.17),
                CGPointMake(-0.05, -0.41),
                CGPointMake(0.05, -0.64),
                CGPointMake(0.12, -0.76),
                CGPointMake(0.13, -0.48),
                CGPointMake(0.15, -0.20),
                CGPointMake(0.18, 0.07),
                CGPointMake(0.20, 0.35),
                CGPointMake(0.22, 0.62),
                CGPointMake(0.22, 0.68),
                CGPointMake(0.12, 0.46),
                CGPointMake(0.02, 0.24),
                CGPointMake(-0.09, 0.05),
                CGPointMake(-0.20, -0.15),
                CGPointMake(-0.30, -0.36),
                CGPointMake(-0.41, -0.54),
                CGPointMake(-0.29, -0.51),
                CGPointMake(-0.14, -0.41),
                CGPointMake(0.00, -0.31),
                CGPointMake(0.16, -0.26),
                CGPointMake(0.31, -0.23),
            ],
            "S": [
                CGPointMake(0.12, -1.02),
                CGPointMake(0.18, -1.03),
                CGPointMake(0.24, -0.95),
                CGPointMake(0.30, -0.86),
                CGPointMake(0.35, -0.74),
                CGPointMake(0.38, -0.61),
                CGPointMake(0.40, -0.46),
                CGPointMake(0.40, -0.30),
                CGPointMake(0.39, -0.16),
                CGPointMake(0.35, -0.03),
                CGPointMake(0.30, 0.08),
                CGPointMake(0.24, 0.16),
                CGPointMake(0.17, 0.18),
                CGPointMake(0.11, 0.12),
                CGPointMake(0.05, 0.04),
                CGPointMake(-0.01, -0.04),
                CGPointMake(-0.07, -0.12),
                CGPointMake(-0.14, -0.17),
                CGPointMake(-0.21, -0.18),
                CGPointMake(-0.28, -0.14),
                CGPointMake(-0.33, -0.05),
                CGPointMake(-0.38, 0.06),
                CGPointMake(-0.40, 0.20),
                CGPointMake(-0.40, 0.35),
                CGPointMake(-0.39, 0.51),
                CGPointMake(-0.35, 0.64),
                CGPointMake(-0.31, 0.76),
                CGPointMake(-0.27, 0.88),
                CGPointMake(-0.21, 0.96),
                CGPointMake(-0.14, 0.97),
                CGPointMake(-0.07, 0.97),
            ]
        ]
        for (name, samples) in templates {
            self.gestureRecognizer.addTemplate(name, samples: samples)
        }
    }
}
