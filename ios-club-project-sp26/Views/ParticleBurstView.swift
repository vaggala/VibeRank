import SwiftUI

struct ParticleBurstView: View {
    let voteType: VoteType

    @State private var animate = false
    private let particles: [Particle]

    init(voteType: VoteType) {
        self.voteType = voteType
        self.particles = Self.generate(for: voteType)
    }

    var body: some View {
        ZStack {
            ForEach(particles) { p in
                Text(p.emoji)
                    .font(.system(size: p.size))
                    .rotationEffect(.degrees(animate ? p.endRotation : 0))
                    .offset(
                        x: animate ? cos(p.angle) * p.distance : 0,
                        y: animate ? sin(p.angle) * p.distance : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? 0.4 : 1.2)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.75)) {
                animate = true
            }
        }
    }

    private static func generate(for type: VoteType) -> [Particle] {
        let pool: [String]
        let count: Int

        switch type {
        case .smash:
            pool = ["❤️", "💖", "💘", "✨", "🔥", "💕", "😍"]
            count = 14
        case .pass:
            pool = ["❌", "👎", "💔", "🙅", "🚫"]
            count = 10
        case .skip:
            pool = ["💨", "🤔", "😐", "🤷", "💭"]
            count = 8
        }

        return (0..<count).map { i in
            let baseAngle = Double(i) / Double(count) * 2 * .pi
            let jitter = Double.random(in: -0.25...0.25)
            return Particle(
                emoji: pool.randomElement() ?? "✨",
                angle: baseAngle + jitter,
                distance: CGFloat.random(in: 140...230),
                size: CGFloat.random(in: 22...38),
                endRotation: Double.random(in: -200...200)
            )
        }
    }
}

private struct Particle: Identifiable {
    let id = UUID()
    let emoji: String
    let angle: Double
    let distance: CGFloat
    let size: CGFloat
    let endRotation: Double
}
