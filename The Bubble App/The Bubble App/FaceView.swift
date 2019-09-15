
import UIKit
import Vision

class FaceView: UIView {
	var leftEye: [CGPoint] = []
	var rightEye: [CGPoint] = []
	var leftEyebrow: [CGPoint] = []
	var rightEyebrow: [CGPoint] = []
	var nose: [CGPoint] = []
	var outerLips: [CGPoint] = []
	var innerLips: [CGPoint] = []
	var faceContour: [CGPoint] = []

	var boundingBox = CGRect(x: 10, y: 10, width: 100, height: 100)

	func clear() {
		leftEye = []
		rightEye = []
		leftEyebrow = []
		rightEyebrow = []
		nose = []
		outerLips = []
		innerLips = []
		faceContour = []

		boundingBox = CGRect(x: 10, y: 10, width: 100, height: 100)

		DispatchQueue.main.async {
		  self.setNeedsDisplay()
		}
	}

	override func draw(_ rect: CGRect) {
		// 1
		guard let context = UIGraphicsGetCurrentContext() else {
			return
		}
		
		// 2
		context.saveGState()
		
		// 3
		defer {
			context.restoreGState()
		}
		
		// 4
		context.addRect(boundingBox)
		
		// 5
		UIColor.red.setStroke()
		
		// 6
		context.strokePath()

	}
}