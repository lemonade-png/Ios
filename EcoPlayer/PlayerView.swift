import SwiftUI
import AVKit

struct PlayerView: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        
        // Optimizations
        // ensures the player doesn't keep the display awake unnecessarily if paused, though AVPlayer handles most of this.
        controller.updatesNowPlayingInfoCenter = true 
        
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Update player if needed, but usually we just hold the reference
        if uiViewController.player != player {
            uiViewController.player = player
        }
    }
}
