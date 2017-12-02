/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Main view controller for the AR experience.
 */

import UIKit
import SceneKit
import Foundation
import ARKit
import Vision

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    // MARK: - IBOutlets
    
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var menuButton: UIButton!
    
   
    @IBOutlet weak var menuPanel: UIView!
    var nodeModel:SCNNode!
    let nodeName = "reef"
    var found = 0

    
    
    private let handler = VNSequenceRequestHandler()
    fileprivate var lastObservation: VNDetectedObjectObservation?
    var trackImageBoundingBox: CGRect?
    
    // MARK: - View Life Cycle
    
    /// - Tag: StartARSession
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        
        
        
        /*
         Start the view's AR session with a configuration that uses the rear camera,
         device position and orientation tracking, and plane detection.
         */
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self
        
        /*
         Prevent the screen from being dimmed after a while as users will likely
         have long periods of interaction without touching the screen or buttons.
         */
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Show debug UI to view performance metrics (e.g. frames per second).
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Create a new scene
        
        let scene = SCNScene()
        
        registerGestureRecognizer()
        
        let modelScene = SCNScene(named:
            "Assets.scnassets/reef3/mesh.dae")!
        guard let modelNode = modelScene.rootNode.childNode(withName: "reef",recursively: false) else{
            return
        }
        modelNode.position = SCNVector3(x:0, y:-1, z: -3 )
        
        //        scene.rootNode.addChildNode(modelNode)
        sceneView.scene = scene
        
        
        var env = UIImage(named: "Assets.scnassets/interior_light.jpg")
        sceneView.scene.lightingEnvironment.contents = env;
    }
    
    func registerGestureRecognizer(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tap)
        
    }
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer){
        let sceneLocation = gestureRecognizer.view as! ARSCNView
        let touchLocation = gestureRecognizer.location(in: sceneLocation)
        let hitResult = self.sceneView.hitTest(touchLocation, types:[.existingPlaneUsingExtent, .estimatedHorizontalPlane])
        
        if hitResult.count>0{
            guard let hitTestResult = hitResult.first else{
                return
            }
            
//            let node = SCNNode()
//            let scene = SCNScene(named:
//                "Assets.scnassets/reef3/mesh.dae")
//            let nodeArray = scene!.rootNode.childNodes
//
//            for childNode in nodeArray{
//                node.addChildNode(childNode as SCNNode)
//            }
            
            let node = SCNNode()
            
            
            var aNode = SCNNode()
            var bNode = SCNNode()
            var planeNode = SCNNode()
            
            var val :Float
            val = 20
            var val2 :Float
            val2 = 20
            
            

            planeNode = SCNNode(geometry:SCNPlane(width: 10, height: 10))
            planeNode.geometry?.firstMaterial?.specular.contents = UIColor.blue
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.gray
            planeNode.geometry?.firstMaterial?.shininess = 0.2
            planeNode.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.physicallyBased
            planeNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(-M_PI_2))
            node.addChildNode(planeNode)
            
            var text = SCNText(string: "a", extrusionDepth: 1)
            var textNode = SCNNode(geometry: text)
            textNode.scale = SCNVector3(x:0.1,y: 0.1,z: 0.1)
            textNode.position = SCNVector3(x:0, y:val/2 , z: 0)
           
            
            var mat = SCNMaterial()
            mat.lightingModel = SCNMaterial.LightingModel.physicallyBased
            mat.diffuse.contents = UIImage(named: "Assets.scnassets/scuffed-plastic4-alb.png")
            mat.roughness.contents = UIImage(named: "Assets.scnassets/scuffed-plastic-ao.png")
            mat.metalness.contents = UIImage(named: "Assets.scnassets/scuffed-plastic-metal.psd")
            mat.normal.contents = UIImage(named: "Assets.scnassets/scuffed-plastic-normal.png")
            
            var mat2 = SCNMaterial()
            mat2.lightingModel = SCNMaterial.LightingModel.physicallyBased
            mat2.diffuse.contents = UIColor.blue
//            mat2.shininess = 0.5
            mat2.transparency = 0.98
            mat2.metalness.contents = NSNumber(value: 0.7)
            mat2.roughness.contents = NSNumber(value: 0.7)
            mat2.specular.contents = UIColor.white
            
            aNode = SCNNode(geometry: SCNCylinder(radius: 1.0, height: CGFloat(val)))
//                    let posX = min.x + Float(j) * Float(gridSize) + Float(gridSize/2)
//                    let posY = min.y + Float(i) * Float(gridSize) + Float(gridSize/2)
            aNode.position = SCNVector3(x: 3, y:val/2 , z: 0)
            aNode.rotation = SCNVector4(x: 0, y: 0, z: 0, w: Float(-M_PI_2))
//            aNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            aNode.geometry?.firstMaterial=mat2
            
            
            aNode.addChildNode(textNode)
            
            bNode = SCNNode(geometry: SCNCylinder(radius: 1.0, height: CGFloat(val2)))
            //        let posX = min.x + Float(j) * Float(gridSize) + Float(gridSize/2)
            //        let posY = min.y + Float(i) * Float(gridSize) + Float(gridSize/2)
            bNode.position = SCNVector3(x: 0, y:val2/2 , z: 0)
            bNode.rotation = SCNVector4(x: 0, y: 0, z: 0, w: Float(-M_PI_2))
            bNode.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
            
            node.addChildNode(aNode)
            node.addChildNode(bNode)
            
            
            let worldPos = hitTestResult.worldTransform
            
            node.position = SCNVector3(x:worldPos.columns.3.x ,y:worldPos.columns.3.y, z:worldPos.columns.3.z)
            node.scale = SCNVector3(x:0.01,y: 0.01,z: 0.01)
            sceneView.scene.rootNode.addChildNode(node)
            
            let animationGroup = CAAnimationGroup()
            
            let animation = CABasicAnimation(keyPath: "geometry.height")
            animation.fromValue = 0.0
            animation.toValue = val
            animation.duration = 2.0
            animation.autoreverses = false
            animation.repeatCount = 1
            aNode.addAnimation(animation, forKey: "extrude")
            
            
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's AR session.
        sceneView.session.pause()
        print("Paused")
    }
    
    // MARK: - ARSCNViewDelegate
    
    //    /// - Tag: PlaceARContent
    //    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    //        // Place content only for anchors found by plane detection.
    //        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    //
    //        // Create a SceneKit plane to visualize the plane anchor using its position and extent.
    //        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
    //        let planeNode = SCNNode(geometry: plane)
    //        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
    //
    //        /*
    //         `SCNPlane` is vertically oriented in its local coordinate space, so
    //         rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
    //        */
    //        planeNode.eulerAngles.x = -.pi / 2
    //
    //        // Make the plane visualization semitransparent to clearly show real-world placement.
    //        planeNode.opacity = 0.25
    //
    //        /*
    //         Add the plane visualization to the ARKit-managed node so that it tracks
    //         changes in the plane anchor as plane estimation continues.
    //        */
    //        node.addChildNode(planeNode)
    //    }
    
    //    /// - Tag: UpdateARContent
    //    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    //        // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
    //        guard let planeAnchor = anchor as?  ARPlaneAnchor,
    //            let planeNode = node.childNodes.first,
    //            let plane = planeNode.geometry as? SCNPlane
    //            else { return }
    //
    //        // Plane estimation may shift the center of a plane relative to its anchor's transform.
    //        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
    //
    //        /*
    //         Plane estimation may extend the size of the plane, or combine previously detected
    //         planes into a larger one. In the latter case, `ARSCNView` automatically deletes the
    //         corresponding node for one plane, then calls this method to update the size of
    //         the remaining plane.
    //        */
    //        plane.width = CGFloat(planeAnchor.extent.x)
    //        plane.height = CGFloat(planeAnchor.extent.z)
    //    }
    //
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let estimate = self.sceneView.session.currentFrame?.lightEstimate
            else{
                return
        }
        
        let intensity = estimate.ambientIntensity/1000
        self.sceneView.scene.lightingEnvironment.intensity = intensity
        
        
        
        return
//        print("in renderer")
        if (self.found==1){
            return
        }
        // Track the thumbnail
        guard let pixelBuffer = self.sceneView.session.currentFrame?.capturedImage else {
                return
        }
        
//        let barcodeRequest = VNDetectBarcodesRequest(completionHandler: {(request, error) in
//            self.reportResults(results: request.results)
//        })
//
        
        let barcodeRequest = VNDetectBarcodesRequest(completionHandler: {(request, error) in
       

            // Loopm through the found results
            for result in request.results! {

                
                // Cast the result to a barcode-observation
                if let barcode = result as? VNBarcodeObservation {
                    
                    // Print barcode-values
                    print(barcode.bottomLeft)
                    print(barcode.payloadStringValue)
                    
//                    print(barcode.barcodeDescriptor.debugDescription)
                    if let desc = barcode.barcodeDescriptor as? CIQRCodeDescriptor {
//                        let content = String(data: desc.errorCorrectedPayload, encoding: .utf8)
                        
                        // FIXME: This currently returns nil. I did not find any docs on how to encode the data properly so far.
//                        print("Payload: \(String(describing: content))")
                        print("Error-Correction-Level: \(desc.errorCorrectionLevel)")
                        print("Symbol-Version: \(desc.symbolVersion)")
                    }
                    if(barcode.payloadStringValue != "manto"){
                        return
                    }
                    
                    var trackImageBoundingBoxInImage = barcode.boundingBox
                    
                    // Transfrom the rect from image space to view space
                    trackImageBoundingBoxInImage.origin.y = 1 - trackImageBoundingBoxInImage.origin.y
                    guard let fromCameraImageToViewTransform = self.sceneView.session.currentFrame?.displayTransform(for: UIInterfaceOrientation.portrait, viewportSize: self.sceneView.frame.size) else {
                        return
                    }
                    let normalizedTrackImageBoundingBox = trackImageBoundingBoxInImage.applying(fromCameraImageToViewTransform)
                    let t = CGAffineTransform(scaleX: self.view.frame.size.width, y: self.view.frame.size.height)
                    let unnormalizedTrackImageBoundingBox = normalizedTrackImageBoundingBox.applying(t)
                    self.trackImageBoundingBox = unnormalizedTrackImageBoundingBox
                    
                    // Get the projection if the location of the tracked image from image space to the nearest detected plane
                    if let trackImageOrigin = self.trackImageBoundingBox?.origin {
//
//                        let codeLocation = gestureRecognizer.location(in: sceneLocation)
                        
                        let hitResult = self.sceneView.hitTest(CGPoint(x: trackImageOrigin.x - 20.0, y: trackImageOrigin.y + 40.0), types:[.existingPlaneUsingExtent, .estimatedHorizontalPlane])
                        
                        if hitResult.count>0{
                            guard let hitTestResult = hitResult.first else{
                                return
                            }
                            
                            let node = SCNNode()
                            let scene = SCNScene(named:
                                "Assets.scnassets/chips/cut.dae")
                            let nodeArray = scene!.rootNode.childNodes
                            
                            for childNode in nodeArray{
                                node.addChildNode(childNode as SCNNode)
                            }
                            
                            
                            let worldPos = hitTestResult.worldTransform
                            
//
                        node.position = SCNVector3(x:worldPos.columns.3.x ,y:worldPos.columns.3.y, z:worldPos.columns.3.z)
                        node.scale = SCNVector3(x:0.1,y: 0.1,z: 0.1)
                        self.sceneView.scene.rootNode.addChildNode(node)
                            self.found = 1
                        }
                    }
                }
                
            }
        })
        
        //        guard let _ = try? handler.perform([barcodeRequest]) else {
        //            return print("Could not perform barcode-request!")
        //        }
        
        do {
            try self.handler.perform([barcodeRequest], on: pixelBuffer)
        }
        catch {
            print(error)
        }
        
        //        let request = VNTrackObjectRequest(detectedObjectObservation: observation) { [unowned self] request, error in
        //            self.handle(request, error: error)
        //        }
        //        request.trackingLevel = .accurate
        //        do {
        //            try self.handler.perform([request], on: pixelBuffer)
        //        }
        //        catch {
        //            print(error)
        //        }
        
    }
    
    private func reportResults(results: [Any]?) {
        // Loop through the found results
        print("Barcode observation")
        
        if results == nil {
            print("No results found.")
        } else {
            print("Number of results found: \(results!.count)")
            for result in results! {
                
                // Cast the result to a barcode-observation
                if let barcode = result as? VNBarcodeObservation {
                    
                    if let payload = barcode.payloadStringValue {
                        print("Payload: \(payload)")
                    }
                    
                    // Print barcode-values
                    print("Symbology: \(barcode.symbology.rawValue)")
                    
                    if let desc = barcode.barcodeDescriptor as? CIQRCodeDescriptor {
                        let content = String(data: desc.errorCorrectedPayload, encoding: .utf8)
                        
                        // FIXME: This currently returns nil. I did not find any docs on how to encode the data properly so far.
                        print("Payload: \(String(describing: content))")
                        print("Error-Correction-Level: \(desc.errorCorrectionLevel)")
                        print("Symbol-Version: \(desc.symbolVersion)")
                    }
                }
            }
        }
    }
    
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        resetTracking()
    }
    
    // MARK: - Private methods
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal surfaces."
            
        case .normal:
            // No feedback needed when tracking is normal and planes are visible.
            message = ""
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        }
        
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
    
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    
    @IBAction func didTouchMenuButton(_ sender: Any) {
        menuPanel.isHidden=false
    }



}
