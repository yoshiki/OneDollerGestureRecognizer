import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var gestureView: GestureView!

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.gestureView.mode = GestureViewMode.Register
        self.gestureView.mode = GestureViewMode.Detect
        self.gestureView.registerTemplate()
        self.gestureView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: GestureViewDelegate {
    func detect(name: String, score: Float) {
        var message = ""
        if score < 0.4 {
            message = "Match template: \(name)\nScore: \(score)"
        } else {
            message = "Not recognized"
        }
        let alertViewController = UIAlertController(
            title: "Result",
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alertViewController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertViewController, animated: true, completion: nil)
    }
}

