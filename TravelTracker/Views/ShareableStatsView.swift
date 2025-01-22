import SwiftUI

struct ShareableStatsView: View {
    let states: [USState]
    let timeframe: String
    
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
                    
                    // Create a subtle wave pattern
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
            
            // Content
            VStack(spacing: 24) {
                Color.clear
                    .frame(height: 60)
                
                // Header
                VStack(spacing: 8) {
                    Text("My US Travel Progress")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(timeframe)
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                // Stats Grid
                VStack(spacing: 32) {
                    // Progress Circle
                    ZStack {
                        Circle()
                            .stroke(.white.opacity(0.3), lineWidth: 20)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(states.count) / 50.0)
                            .stroke(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                        
                        VStack {
                            Text("\(states.count)")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(.white)
                            Text("STATES")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .frame(width: 200, height: 200)
                    
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        StatItem(title: "Completion", value: "\(Int((Float(states.count) / 50.0) * 100))%")
                        
                        if let firstVisit = states.last?.visitDate {
                            StatItem(
                                title: "First Visit",
                                value: firstVisit.formatted(date: .abbreviated, time: .omitted)
                            )
                        }
                        
                        if let latestVisit = states.first?.visitDate {
                            StatItem(
                                title: "Latest Visit",
                                value: latestVisit.formatted(date: .abbreviated, time: .omitted)
                            )
                        }
                    }
                }
                
                Spacer()
                
                // Footer
                HStack {
                    Text("Tracked with")
                    Text("Travel Tracker")
                        .fontWeight(.semibold)
                    Text("🧭")
                }
                .font(.footnote)
                .foregroundColor(.white.opacity(0.9))
                
                Color.clear
                    .frame(height: 20)
            }
            .padding(32)
        }
        .frame(width: 390, height: 844)
        .background(Color.black) // Fallback background
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.15))
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Material.ultraThinMaterial)
                }
        }
    }
} 