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
    
    // TODO: remove this
    func getNode() -> SKNode {
        return SKNode()
    }
	
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
		
        session = Session(getNode: getNode)
        
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
    

    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
		NSLog("Adding node")
		
		let labelNode = SKLabelNode(text: "sample text")
		labelNode.fontColor = .white
		labelNode.verticalAlignmentMode = .center
		
		let boxNode = SKSpriteNode(color: .black, size: labelNode.frame.size)

		let node = SKNode()
		node.addChild(boxNode)
		node.addChild(labelNode)
		
		return node
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		NSLog("touch")
		
		if let currentFrame = sceneView.session.currentFrame {
			let pos = faceTracker.getFacePosition(pixelBuffer: currentFrame.capturedImage)
			NSLog("\(pos)")
			
			
			var translation = matrix_identity_float4x4
			translation.columns.3.z = -1.0
			let transform = simd_mul(currentFrame.camera.transform, translation)
			
			let anchor = ARAnchor(transform: transform)
			sceneView.session.add(anchor: anchor)
			NSLog("Added anchor")
			
		}
		
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
                NSLog(session.bubbles.last!.content)
            }
        } catch {
            return
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        NSLog("Did recieve data!");
    }
}
