import SwiftUI

/// Lightweight full-screen confetti particle effect using Canvas.
struct ConfettiView: View {
    
    @State private var particles: [ConfettiParticle] = []
//    @State private var isAnimating = false
    
    private let particleCount = 120
    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    
    var body: some View {
        TimelineView(.animation) { timeline in
//            if isAnimating {
                Canvas { ctx, size in
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    for particle in particles {
                        let elapsed = now - particle.birthTime
                        guard elapsed >= 0 else { continue }
                        let t = elapsed / particle.lifetime
                        guard t <= 1 else { continue }
                        
                        let x = particle.x * size.width + particle.vx * elapsed * size.width
                        let y = particle.y * size.height
                        + particle.vy * elapsed * size.height
                        + 0.5 * 600 * elapsed * elapsed   // gravity
                        let opacity = max(0, 1 - t * t)
                        let rotation = particle.rotation + particle.rotationSpeed * elapsed
                        
                        ctx.opacity = opacity
                        ctx.translateBy(x: x, y: y)
                        ctx.rotate(by: .radians(rotation))
                        
                        let rect = CGRect(
                            x: -particle.size / 2,
                            y: -particle.size / 2,
                            width: particle.size,
                            height: particle.size * 0.5
                        )
                        ctx.fill(Path(rect), with: .color(particle.color))
                        // Reset transform
                        ctx.rotate(by: .radians(-rotation))
                        ctx.translateBy(x: -x, y: -y)
                        ctx.opacity = 1
                    }
                }
//            }
        }
        .id(particles.count)
        .onAppear {
            spawnParticles()
//            isAnimating = true
        }
        .allowsHitTesting(false)
    }
    
    private func spawnParticles() {
        let now = Date.timeIntervalSinceReferenceDate
        particles = (0..<particleCount).map { _ in
            ConfettiParticle(
                x: Double.random(in: 0...1),
                y: Double.random(in: -0.2...0.3),
                vx: Double.random(in: -0.08...0.08),
                vy: Double.random(in: -0.2...0.1),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 6...14),
                rotation: Double.random(in: 0...(.pi * 2)),
                rotationSpeed: Double.random(in: -4...4),
                lifetime: Double.random(in: 2.5...3.5),
                birthTime: now + Double.random(in: 0...0.6)
            )
        }
    }
}

#Preview {
    ConfettiView()
}
