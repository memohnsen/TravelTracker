import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var iconScale: CGFloat = 0.3
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Map Icon with Pin
                ZStack {
                    Image(systemName: "map.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Image(systemName: "mappin.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.red)
                        .offset(x: isAnimating ? 0 : -60, y: isAnimating ? 0 : -60)
                }
                .scaleEffect(iconScale)
                
                // App Title
                Text("Travel Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 1.0)) {
                iconScale = 1.0
                isAnimating = true
            }
            
            withAnimation(.easeIn(duration: 0.4).delay(0.5)) {
                opacity = 1.0
            }
        }
    }
} 
