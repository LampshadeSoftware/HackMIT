//
//  ViewController.swift
//  The Bubble App
//
//  Created by Cowboy Lynk on 9/14/19.
//  Copyright © 2019 Lampshade Software. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import Starscream
import Vision

let SAMPLE_RATE = 16000
let CHUNK_LENGTH = 1.0  // in seconds

class ViewController: UIViewController, ARSKViewDelegate, AudioControllerDelegate {

	@IBOutlet weak var sceneView: ARSKView!
	
    let decoder = JSONDecoder()
    var socket = WebSocket(url: URL(string: "wss://api.rev.ai/speechtotext/v1alpha/stream?access_token=02w0YXKRxWEAtCh_mgitSSsuq74oInJPBIZ-t6xy5dvlTMGzZoRKQI8sTPE6mJxqCwwOA4UYa8s67iEm4ny54aIBYt8YM&content_type=audio/x-raw;layout=interleaved;rate=16000;format=S16LE;channels=1")!)
    var audioData: Data!
    var session: Session!
	var faceTracker: FaceTracker!
	
	
    
    func recordAudio() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
        } catch {
            
        }
        audioData = Data()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
        //        SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
        _ = AudioController.sharedInstance.start()
    }
    
    func stopAudio() {
        _ = AudioController.sharedInstance.stop()
        //        SpeechRecognitionService.sharedInstance.stopStreaming()
    }
    
    func processSampleData(_ data: Data) -> Void {
        audioData.append(data)
        
        // We recommend sending samples in 1000ms chunks
        
        let chunkSize : Int /* bytes/chunk */ = Int(CHUNK_LENGTH /* seconds/chunk */
            * Double(SAMPLE_RATE) /* samples/second */
            * 2 /* bytes/sample */);
        
        if (audioData.count > chunkSize) {
            // Send the audio data to Rev
            socket.write(data: audioData)
            
            // Flush the data
            self.audioData = Data()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		session = Session(addToScene: setNodeIfFaceExists)
        
		AudioController.sharedInstance.delegate = self
		
        NSLog("Loaded");
        
        // Connect to the Rev web socket
        socket.delegate = self
        socket.connect()
        
        NSLog("Tried to connect to socket");
		
		
        // Set the view's delegate
        sceneView.delegate = self

		sceneView.showsFPS = true
		sceneView.showsNodeCount = true

		
		if let scene = SKScene(fileNamed: "Scene") {
			NSLog("Presenting scene")
			sceneView.presentScene(scene)
		} else {
			NSLog("Problem presenting scene")
		}
		
		faceTracker = FaceTracker()
		
		recordAudio()
		
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
	var currentBubble: Bubble? = nil

    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
		NSLog("Adding node")
		
		let node = SKNode()
		
		if (currentBubble != nil) {
			currentBubble!.setNode(node: node)
		}
		return node
	}
	
	func setNodeIfFaceExists(bubble: Bubble) {
		if let currentFrame = sceneView.session.currentFrame {
			let faceBox = faceTracker.getFaceBox(pixelBuffer: currentFrame.capturedImage)
			if (faceBox != nil) {
				var translation = matrix_identity_float4x4
				let distance = getDistance(faceBox: faceBox!)
				translation.columns.3.z = Float(distance * -1)
				
				let transform = simd_mul(currentFrame.camera.transform, translation)
				
				let anchor = ARAnchor(transform: transform)
				currentBubble = bubble
				
				sceneView.session.add(anchor: anchor)
			}
		}
	}
	
	func getDistance(faceBox: CGRect) -> CGFloat {
		let faceSize = (faceBox.width + faceBox.height) / 2
		
		let distance = FaceTracker.FACE_WIDTH_TO_Z_DISTANCE_DIVIDER / faceSize
		
		NSLog("Face Size: \(faceSize)")
		NSLog("Distance: \(distance)")
		return distance
	}
	
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
	
}

// MARK: - WebSocketDelegate
extension ViewController : WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        NSLog("Did connect!");
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        NSLog("Did disconnect!");
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        let data = text.data(using: .utf16)
        do {
            let jsonData = try decoder.decode(RevResponse.self, from: data!)
            
            let messageType = jsonData.type
            if messageType == "final" || messageType == "partial" {
                session.updateBubbleContent(revResponse: jsonData)

            }
        } catch {
            return
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        NSLog("Did recieve data!");
    }
}
