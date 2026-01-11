import SwiftUI
import AVKit
import PhotosUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var player: AVPlayer?
    @State private var isPickerPresented = false
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack {
            if let player = player {
                PlayerView(player: player)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        player.play()
                    }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "play.tv.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("EcoPlayer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Battery Efficient Video Player")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        isPickerPresented = true
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Select Video from Photos")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // Big Buck Bunny sample
                        let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
                        self.player = AVPlayer(url: url)
                    }) {
                        HStack {
                            Image(systemName: "play.circle")
                            Text("Play Sample Video")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .photosPicker(isPresented: $isPickerPresented, selection: $selectedItem, matching: .videos)
        .onChange(of: selectedItem) { newItem in
            guard let item = newItem else { return }
            Task {
                if let movie = try? await item.loadTransferable(type: VideoPickerTransferable.self) {
                    await MainActor.run {
                        self.player = AVPlayer(url: movie.url)
                    }
                }
            }
        }
    }
}

// Helper to handle video selection
struct VideoPickerTransferable: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let copy = URL.documentsDirectory.appending(path: "importedVideo.mp4")
            if FileManager.default.fileExists(atPath: copy.path()) {
                try? FileManager.default.removeItem(at: copy)
            }
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self.init(url: copy)
        }
    }
}
