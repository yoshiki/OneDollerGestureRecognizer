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
            var result = self.gestureRecognizer.serialize()
            self.drawResample(result.samples)
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
                CGPointMake(1.15, -0.00),
                CGPointMake(1.09, -0.02),
                CGPointMake(0.68, -0.33),
                CGPointMake(0.39, -0.57),
                CGPointMake(0.12, -0.78),
                CGPointMake(0.04, -0.83),
                CGPointMake(0.01, -0.84),
                CGPointMake(-0.25, -1.07),
                CGPointMake(-0.37, -1.17),
                CGPointMake(-0.40, -1.18),
                CGPointMake(-0.37, -1.06),
                CGPointMake(-0.37, -0.50),
                CGPointMake(-0.38, -0.19),
                CGPointMake(-0.40, 0.09),
                CGPointMake(-0.43, 0.26),
                CGPointMake(-0.45, 0.34),
                CGPointMake(-0.48, 0.51),
                CGPointMake(-0.50, 0.62),
                CGPointMake(-0.53, 0.71),
                CGPointMake(-0.55, 0.75),
                CGPointMake(-0.55, 0.78),
                CGPointMake(-0.56, 0.82),
                CGPointMake(-0.53, 0.82),
                CGPointMake(-0.42, 0.76),
                CGPointMake(-0.16, 0.65),
                CGPointMake(0.06, 0.54),
                CGPointMake(0.18, 0.44),
                CGPointMake(0.40, 0.29),
                CGPointMake(0.63, 0.16),
                CGPointMake(0.78, 0.08),
                CGPointMake(1.03, -0.02),
                CGPointMake(1.13, -0.05),
            ],
            "Circle": [
                CGPointMake(0.86, -0.00),
                CGPointMake(0.84, 0.15),
                CGPointMake(0.80, 0.27),
                CGPointMake(0.75, 0.36),
                CGPointMake(0.70, 0.46),
                CGPointMake(0.52, 0.62),
                CGPointMake(0.37, 0.73),
                CGPointMake(0.23, 0.82),
                CGPointMake(-0.00, 0.88),
                CGPointMake(-0.18, 0.89),
                CGPointMake(-0.35, 0.86),
                CGPointMake(-0.52, 0.78),
                CGPointMake(-0.65, 0.68),
                CGPointMake(-0.77, 0.54),
                CGPointMake(-0.88, 0.39),
                CGPointMake(-0.95, 0.27),
                CGPointMake(-0.96, 0.06),
                CGPointMake(-1.02, -0.33),
                CGPointMake(-1.03, -0.40),
                CGPointMake(-1.02, -0.51),
                CGPointMake(-0.89, -0.69),
                CGPointMake(-0.71, -0.79),
                CGPointMake(-0.39, -0.94),
                CGPointMake(-0.14, -1.00),
                CGPointMake(0.19, -1.00),
                CGPointMake(0.39, -0.98),
                CGPointMake(0.50, -0.93),
                CGPointMake(0.67, -0.69),
                CGPointMake(0.81, -0.44),
                CGPointMake(0.93, -0.12),
                CGPointMake(0.97, 0.00),
                CGPointMake(0.97, 0.06),
            ],
            "Star": [
                CGPointMake(0.95, 0.00),
                CGPointMake(0.72, -0.07),
                CGPointMake(0.14, -0.43),
                CGPointMake(-0.29, -0.69),
                CGPointMake(-0.61, -0.83),
                CGPointMake(-0.78, -0.89),
                CGPointMake(-0.73, -0.82),
                CGPointMake(-0.40, -0.14),
                CGPointMake(-0.20, 0.15),
                CGPointMake(-0.07, 0.34),
                CGPointMake(0.03, 0.50),
                CGPointMake(0.05, 0.55),
                CGPointMake(0.12, 0.67),
                CGPointMake(0.17, 0.68),
                CGPointMake(0.18, 0.57),
                CGPointMake(0.20, -0.10),
                CGPointMake(0.23, -0.76),
                CGPointMake(0.23, -0.84),
                CGPointMake(0.20, -0.80),
                CGPointMake(-0.14, -0.45),
                CGPointMake(-0.91, 0.40),
                CGPointMake(-1.05, 0.57),
                CGPointMake(-1.04, 0.60),
                CGPointMake(-0.90, 0.53),
                CGPointMake(-0.29, 0.36),
                CGPointMake(0.07, 0.27),
                CGPointMake(0.23, 0.23),
                CGPointMake(0.44, 0.17),
                CGPointMake(0.73, 0.10),
                CGPointMake(0.84, 0.06),
                CGPointMake(0.91, 0.05),
                CGPointMake(0.95, 0.02),
            ],
            "L": [
                CGPointMake(1.41, 0.00),
                CGPointMake(1.40, -0.00),
                CGPointMake(1.33, -0.03),
                CGPointMake(1.26, -0.05),
                CGPointMake(1.09, -0.10),
                CGPointMake(0.86, -0.18),
                CGPointMake(0.57, -0.24),
                CGPointMake(0.40, -0.28),
                CGPointMake(0.16, -0.33),
                CGPointMake(0.11, -0.35),
                CGPointMake(-0.03, -0.37),
                CGPointMake(-0.16, -0.38),
                CGPointMake(-0.19, -0.39),
                CGPointMake(-0.25, -0.40),
                CGPointMake(-0.26, -0.39),
                CGPointMake(-0.28, -0.40),
                CGPointMake(-0.28, -0.39),
                CGPointMake(-0.29, -0.37),
                CGPointMake(-0.30, -0.35),
                CGPointMake(-0.32, -0.23),
                CGPointMake(-0.35, -0.16),
                CGPointMake(-0.43, 0.09),
                CGPointMake(-0.49, 0.30),
                CGPointMake(-0.50, 0.34),
                CGPointMake(-0.52, 0.42),
                CGPointMake(-0.54, 0.51),
                CGPointMake(-0.55, 0.56),
                CGPointMake(-0.56, 0.58),
                CGPointMake(-0.57, 0.62),
                CGPointMake(-0.58, 0.64),
                CGPointMake(-0.58, 0.66),
                CGPointMake(-0.59, 0.67),
            ],
            "C": [
                CGPointMake(0.99, -0.00),
                CGPointMake(1.02, -0.05),
                CGPointMake(1.09, -0.21),
                CGPointMake(0.97, -0.74),
                CGPointMake(0.79, -1.06),
                CGPointMake(0.73, -1.14),
                CGPointMake(0.61, -1.21),
                CGPointMake(0.32, -1.14),
                CGPointMake(-0.01, -1.01),
                CGPointMake(-0.24, -0.91),
                CGPointMake(-0.49, -0.76),
                CGPointMake(-0.63, -0.59),
                CGPointMake(-0.79, -0.37),
                CGPointMake(-0.84, -0.26),
                CGPointMake(-0.87, -0.06),
                CGPointMake(-0.88, 0.06),
                CGPointMake(-0.84, 0.18),
                CGPointMake(-0.80, 0.27),
                CGPointMake(-0.70, 0.40),
                CGPointMake(-0.65, 0.44),
                CGPointMake(-0.55, 0.50),
                CGPointMake(-0.40, 0.61),
                CGPointMake(-0.16, 0.77),
                CGPointMake(-0.10, 0.78),
                CGPointMake(-0.00, 0.79),
                CGPointMake(0.05, 0.78),
                CGPointMake(0.22, 0.76),
                CGPointMake(0.31, 0.72),
                CGPointMake(0.42, 0.66),
                CGPointMake(0.45, 0.64),
                CGPointMake(0.49, 0.60),
                CGPointMake(0.51, 0.57),
            ],
            "S": [
                CGPointMake(0.77, -0.00),
                CGPointMake(0.93, -0.14),
                CGPointMake(1.02, -0.29),
                CGPointMake(1.03, -0.49),
                CGPointMake(0.93, -0.72),
                CGPointMake(0.82, -0.84),
                CGPointMake(0.73, -0.94),
                CGPointMake(0.56, -0.96),
                CGPointMake(0.39, -0.96),
                CGPointMake(0.22, -0.92),
                CGPointMake(0.04, -0.83),
                CGPointMake(-0.03, -0.73),
                CGPointMake(-0.07, -0.46),
                CGPointMake(-0.05, -0.26),
                CGPointMake(0.03, -0.12),
                CGPointMake(0.13, 0.05),
                CGPointMake(0.21, 0.23),
                CGPointMake(0.29, 0.43),
                CGPointMake(0.25, 0.69),
                CGPointMake(0.18, 0.84),
                CGPointMake(0.09, 0.94),
                CGPointMake(-0.32, 1.02),
                CGPointMake(-0.48, 1.00),
                CGPointMake(-0.66, 0.88),
                CGPointMake(-0.81, 0.73),
                CGPointMake(-0.94, 0.59),
                CGPointMake(-0.97, 0.51),
                CGPointMake(-0.95, 0.39),
                CGPointMake(-0.91, 0.25),
                CGPointMake(-0.87, 0.13),
                CGPointMake(-0.81, 0.01),
                CGPointMake(-0.76, -0.04),
            ],
            "W": [
                CGPointMake(1.19, 0.00),
                CGPointMake(1.15, -0.04),
                CGPointMake(1.05, -0.13),
                CGPointMake(0.58, -0.49),
                CGPointMake(0.29, -0.65),
                CGPointMake(0.18, -0.70),
                CGPointMake(0.10, -0.72),
                CGPointMake(0.07, -0.75),
                CGPointMake(0.04, -0.75),
                CGPointMake(0.02, -0.75),
                CGPointMake(0.02, -0.71),
                CGPointMake(0.06, -0.66),
                CGPointMake(0.15, -0.50),
                CGPointMake(0.22, -0.27),
                CGPointMake(0.29, 0.08),
                CGPointMake(0.34, 0.24),
                CGPointMake(0.37, 0.40),
                CGPointMake(0.36, 0.39),
                CGPointMake(0.33, 0.36),
                CGPointMake(0.07, 0.29),
                CGPointMake(-0.59, 0.11),
                CGPointMake(-0.69, 0.09),
                CGPointMake(-0.72, 0.07),
                CGPointMake(-0.78, 0.07),
                CGPointMake(-0.81, 0.07),
                CGPointMake(-0.79, 0.09),
                CGPointMake(-0.74, 0.13),
                CGPointMake(-0.48, 0.66),
                CGPointMake(-0.40, 0.85),
                CGPointMake(-0.32, 1.01),
                CGPointMake(-0.29, 1.08),
                CGPointMake(-0.27, 1.11),
            ]
        ]
        for (name, samples) in templates {
            self.gestureRecognizer.addTemplate(name, samples: samples)
        }
    }
}
