import SwiftUI


struct PulsingDot: View {
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.4))
                .frame(width: 40, height: 40)
                .scaleEffect(scale)
                .opacity(Double(2 - scale))
            Circle()
                .fill(Color.blue)
                .frame(width: 20, height: 20)
        }
        .onAppear {
            withAnimation(Animation.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
                scale = 2.0
            }
        }
    }
}

