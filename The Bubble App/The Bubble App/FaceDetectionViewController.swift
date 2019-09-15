
import AVFoundation
import UIKit
import Vision

class FaceDetectionViewController: UIViewController {
	@IBOutlet var faceView: FaceView!
	let session = AVCaptureSession()
	var previewLayer: AVCaptureVideoPreviewLayer!

	var sequenceHandler = VNSequenceRequestHandler()

	let dataOutputQueue = DispatchQueue(
		label: "video data queue",
		qos: .userInitiated,
		attributes: [],
		autoreleaseFrequency: .workItem)

	var faceViewHidden = false

	var maxX: CGFloat = 0.0
	var midY: CGFloat = 0.0
	var maxY: CGFloat = 0.0

	override func viewDidLoad() {
		super.viewDidLoad()
		configureCaptureSession()

		maxX = view.bounds.maxX
		midY = view.bounds.midY
		maxY = view.bounds.maxY

		session.startRunning()
	}
	
	func detectedFace(request: VNRequest, error: Error?) {
		// 1
		guard
			let results = request.results as? [VNFaceObservation],
			let result = results.first
			else {
				// 2
				NSLog("unable to find face")
				faceView.clear()
				return
			}
		
		// 3
		let box = result.boundingBox
		faceView.boundingBox = convert(rect: box)
		
		// 4
		DispatchQueue.main.async {
			self.faceView.setNeedsDisplay()
		}
	}
	
	func convert(rect: CGRect) -> CGRect {
		// 1
		let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
		
		// 2
		let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
		
		// 3
		return CGRect(origin: origin, size: size.cgSize)
	}


}


// MARK: - Video Processing methods

extension FaceDetectionViewController {
  func configureCaptureSession() {
		// Define the capture device we want to use
		guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
												   for: .video,
												   position: .back) else {
		  fatalError("No front video camera available")
		}

		// Connect the camera to the capture session input
		do {
			let cameraInput = try AVCaptureDeviceInput(device: camera)
			session.addInput(cameraInput)
		} catch {
			fatalError(error.localizedDescription)
		}

		// Create the video data output
		let videoOutput = AVCaptureVideoDataOutput()
		videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
		videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

		// Add the video output to the capture session
		session.addOutput(videoOutput)

		let videoConnection = videoOutput.connection(with: .video)
		videoConnection?.videoOrientation = .portrait

		// Configure the preview layer
		previewLayer = AVCaptureVideoPreviewLayer(session: session)
		previewLayer.videoGravity = .resizeAspectFill
		previewLayer.frame = view.bounds
		view.layer.insertSublayer(previewLayer, at: 10)
	}
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate methods

extension FaceDetectionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

		// 1
		guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
			return
		}

		// 2
		let detectFaceRequest = VNDetectFaceRectanglesRequest(completionHandler: detectedFace)

		// 3
		do {
			try sequenceHandler.perform(
				[detectFaceRequest],
				on: imageBuffer,
				orientation: .up)
		} catch {
			print(error.localizedDescription)
		}

	}
}
