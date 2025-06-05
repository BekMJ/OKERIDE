import SwiftUI
import SceneKit

/// A custom SCNView that can host a scooter model.
/// Assumes the model pivot is already centered in the .scn file.
class CustomSCNView: SCNView {
    // Prevent focus caching warnings
    override var canBecomeFocused: Bool { false }
    override func focusItems(in rect: CGRect) -> [UIFocusItem] { [] }
}

// MARK: - TransparentView
/// A SwiftUI wrapper for displaying the scooter SceneKit view with transparency,
/// using a cached scene for instant rendering.
struct TransparentView: UIViewRepresentable {
    static var cachedScene: SCNScene? = nil

    /// Call this on app launch to warm the cache.
    static func preloadScene() {
      DispatchQueue.global(qos: .userInitiated).async {
        guard cachedScene == nil,
              let scene = SCNScene(named: "scooter1.scn")
        else { return }
        cachedScene = scene
      }
    }

    func makeUIView(context: Context) -> SCNView {
      let sceneView = CustomSCNView(frame: .zero)
      sceneView.backgroundColor = .clear
      sceneView.autoenablesDefaultLighting = true
      sceneView.allowsCameraControl = true

      if let scene = TransparentView.cachedScene {
        sceneView.scene = scene
      } else {
        sceneView.scene = SCNScene()
        DispatchQueue.global(qos: .userInitiated).async {
          guard let loaded = SCNScene(named: "scooter1.scn") else { return }
          TransparentView.cachedScene = loaded
          DispatchQueue.main.async {
            sceneView.scene = loaded
          }
        }
      }
      return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}
}

