import AVFoundation
import Foundation

final class SoundPlayer {
    static let shared = SoundPlayer()

    private var cache: [String: AVAudioPlayer] = [:]
    private var currentPlayer: AVAudioPlayer?

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    @discardableResult
    func play(_ filename: String) -> TimeInterval {
        currentPlayer?.stop()
        guard let player = loadPlayer(filename) else { return 0 }
        player.currentTime = 0
        player.play()
        currentPlayer = player
        return player.duration
    }

    func stop() {
        currentPlayer?.stop()
        currentPlayer = nil
    }

    private func loadPlayer(_ filename: String) -> AVAudioPlayer? {
        if let p = cache[filename] { return p }
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            print("SoundPlayer: file not found — \(filename).mp3")
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            cache[filename] = player
            return player
        } catch {
            print("SoundPlayer: failed to load \(filename) — \(error)")
            return nil
        }
    }
}
