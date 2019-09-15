//
//  FaceTracker.swift
//  The Bubble App
//
//  Created by Daniel McCrystal on 9/14/19.
//  Copyright © 2019 Lampshade Software. All rights reserved.
//

import Foundation


import AVFoundation
import UIKit
import Vision

class FaceTracker {
	
	var sequenceHandler = VNSequenceRequestHandler()
	
	var currentFaceBox: CGRect = CGRect.zero
	
	func getFacePosition(pixelBuffer: CVPixelBuffer) -> CGRect {
		let detectFaceRequest = VNDetectFaceRectanglesRequest(completionHandler: detectedFace)
		
		// 3
		do {
			try sequenceHandler.perform(
				[detectFaceRequest],
				on: pixelBuffer,
				orientation: .right)
			
			return self.currentFaceBox
		} catch {
			print(error.localizedDescription)
			return CGRect.zero
		}
	}
	
	func detectedFace(request: VNRequest, error: Error?) {
		// 1
		guard
			let results = request.results as? [VNFaceObservation],
			let result = results.first
			else {
				NSLog("No face detected")
				currentFaceBox = .zero
				return
			}
		NSLog("Detected face!")
		
		currentFaceBox = result.boundingBox
		
	}
	
}
