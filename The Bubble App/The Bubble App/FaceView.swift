
import UIKit
import Vision

class FaceView: UIView {

	var boundingBox = CGRect.zero

	func clear() {


		boundingBox = .zero

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
