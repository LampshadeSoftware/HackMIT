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
	
	var currentFaceBox: CGRect? = nil
	
	var frame: CGSize? = nil
	
	static let FACE_WIDTH_TO_Z_DISTANCE_DIVIDER: CGFloat = 350
	static let Y_OFFSET_DISTANCE_MULTIPLIER: CGFloat = 0.001
	
	func getFaceBox(pixelBuffer: CVPixelBuffer) -> CGRect? {
		if (frame == nil) {
			frame = CGSize(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
		}

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
			return nil
		}
	}
	
	func detectedFace(request: VNRequest, error: Error?) {
		// 1
		guard
			let results = request.results as? [VNFaceObservation],
			let result = results.first
			else {
				NSLog("No face detected")
				currentFaceBox = nil
				return
			}
		NSLog("Detected face!")
		
		currentFaceBox = convertCoordinates(box: result.boundingBox)
	}
	
	func convertCoordinates(box: CGRect) -> CGRect {
		let width = frame!.width
		let height = frame!.height
		
		let x = width * box.origin.x
		let y = height * box.origin.y
		
		let adjustedWidth = width * box.width
		let adjustedHeight = height * box.height
		
		return CGRect(x: x, y: y, width: adjustedWidth, height: adjustedHeight)
	}
}
