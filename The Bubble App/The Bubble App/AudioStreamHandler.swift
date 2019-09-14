//
//  AudioStreamHandler.swift
//  The Bubble App
//
//  Created by Daniel McCrystal on 9/14/19.
//  Copyright © 2019 Lampshade Software. All rights reserved.
//

import Foundation
import AVFoundation

class AudioStreamHandler: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
	
	let settings = [
		AVFormatIDKey: kAudioFormatMPEG4AAC,
		AVNumberOfChannelsKey : 1,
		AVSampleRateKey : 44100]
	let captureSession = AVCaptureSession()
	
	var count = 0
	
	override init() {
		super.init()
		
		let queue = DispatchQueue(label: "AudioSessionQueue", attributes: [])
		let captureDevice = AVCaptureDevice.default(for: AVMediaType.audio)
		var audioInput : AVCaptureDeviceInput? = nil
		var audioOutput : AVCaptureAudioDataOutput? = nil
		
		do {
			try captureDevice?.lockForConfiguration()
			audioInput = try AVCaptureDeviceInput(device: captureDevice!)
			captureDevice?.unlockForConfiguration()
			audioOutput = AVCaptureAudioDataOutput()
			audioOutput?.setSampleBufferDelegate(self, queue: queue)
		} catch {
			print("Capture devices could not be set")
			print(error.localizedDescription)
		}
		
		if audioInput != nil && audioOutput != nil {
			captureSession.beginConfiguration()
			if (captureSession.canAddInput(audioInput!)) {
				captureSession.addInput(audioInput!)
			} else {
				print("cannot add input")
			}
			if (captureSession.canAddOutput(audioOutput!)) {
				captureSession.addOutput(audioOutput!)
			} else {
				print("cannot add output")
			}
			captureSession.commitConfiguration()
			
			print("Starting capture session")
			captureSession.startRunning()
		}
	}
	
	func captureOutput(_ output: AVCaptureOutput,
					   didOutput sampleBuffer: CMSampleBuffer,
					   from connection: AVCaptureConnection) {
		
		print("Audio data recieved [chunk: \(count)]")
		count += 1
	}
}
