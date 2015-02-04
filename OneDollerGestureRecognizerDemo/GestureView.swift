import UIKit

class GestureView: UIView {
    var gestureRecognizer: OneDollerGestureRecognizer = OneDollerGestureRecognizer()
    var path: UIBezierPath = UIBezierPath()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }

    func commonInit() {
        self.path.lineCapStyle = kCGLineCapRound
        self.path.miterLimit = 0.0
        self.path.lineWidth = 5.0
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.gestureRecognizer.reset()

        if !self.path.empty {
            self.path.removeAllPoints()
            self.setNeedsDisplay()
        }
        
        let touch = touches.anyObject() as UITouch
        let point = touch.locationInView(self)
        self.gestureRecognizer.addPoint(x: Float(point.x), y: Float(point.y))
        self.path.moveToPoint(point)
        
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let point = touch.locationInView(self)
        self.gestureRecognizer.addPoint(x: Float(point.x), y: Float(point.y))
        self.path.addLineToPoint(point)
        self.setNeedsDisplay()
        
        super.touchesMoved(touches, withEvent: event)
    }

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.anyObject() as UITouch!
        var point = touch.locationInView(self)
        self.gestureRecognizer.addPoint(x: Float(point.x), y: Float(point.y))
        self.gestureRecognizer.find { (name, score) -> Void in
            println("matched name: \(name), score: \(score)")

            self.cleanup()
        }
        
        super.touchesEnded(touches, withEvent: event)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        UIColor.whiteColor().setStroke()
        self.path.strokeWithBlendMode(kCGBlendModeNormal, alpha: 0.5)
    }
    
    func cleanup() {
        self.path.removeAllPoints()
        self.setNeedsDisplay()
    }
}
