//
//  ViewController.swift
//  The Bubble App
//
//  Created by Cowboy Lynk on 9/14/19.
//  Copyright © 2019 Lampshade Software. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Starscream

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var socket = WebSocket(url: URL(string: "wss://api.rev.ai/speechtotext/v1alpha/stream?access_token=02w0YXKRxWEAtCh_mgitSSsuq74oInJPBIZ-t6xy5dvlTMGzZoRKQI8sTPE6mJxqCwwOA4UYa8s67iEm4ny54aIBYt8YM&content_type=audio/x-raw;layout=interleaved;rate=16000;format=S16LE;channels=1")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("Loaded");
        
        // Connect to the Rev web socket
        socket.delegate = self
        socket.connect()
        
        NSLog("Tried to connect to socket");
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
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
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
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
        NSLog("Did recieve message!");
        
        guard let data = text.data(using: .utf16),
            let jsonData = try? JSONSerialization.jsonObject(with: data),
            let jsonDict = jsonData as? [String: Any],
            let messageType = jsonDict["type"] as? String,
            let id = jsonDict["id"] as? String
        else {
            return
        }
        
        if messageType == "connected" {
            NSLog(id);
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        NSLog("Did recieve data!");
    }
}
