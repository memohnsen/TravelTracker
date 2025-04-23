import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var iconScale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var rotation: Double = -30
    @State private var pinOffset: CGFloat = -60
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.8),
                    Color.purple.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Background pattern
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    path.move(to: CGPoint(x: 0, y: height * 0.3))
                    path.addCurve(
                        to: CGPoint(x: width, y: height * 0.4),
                        control1: CGPoint(x: width * 0.4, y: height * 0.2),
                        control2: CGPoint(x: width * 0.6, y: height * 0.5)
                    )
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                }
                .fill(Color.white.opacity(0.1))
            }
            
            VStack(spacing: 20) {
                // Map Icon with Pin
                ZStack {
                    // Map background glow
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                        .opacity(opacity)
                    
                    Image(systemName: "map.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isAnimating ? 0 : rotation))
                    
                    Image(systemName: "mappin.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.red)
                        .background {
                            Circle()
                                .fill(.white)
                                .scaleEffect(0.8)
                        }
                        .offset(x: isAnimating ? 0 : pinOffset, y: isAnimating ? 0 : pinOffset)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .scaleEffect(iconScale)
                
                // App Title
                Text("TrekBook")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(opacity)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
            }
        }
        .background(Color.black) // Fallback background
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                iconScale = 1.0
                isAnimating = true
                rotation = 0
            }
            
            withAnimation(.easeIn(duration: 0.4).delay(0.3)) {
                opacity = 1.0
            }
        }
    }
}

#Preview {
    SplashView()
} 
