import SwiftUI

struct ShareableStatsView: View {
    let states: [USState]
    let timeframe: String
    
    private var badges: [Badge] {
        Badge.allBadges.filter { badge in
            badge.getLatestVisitDate(from: states) != nil
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Safe area spacer for Dynamic Island/Notch
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
            .padding(.top, 20)
            
            // Stats Grid
            VStack(spacing: 24) {
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
                .frame(width: 160, height: 160)
                
                // Simplified Stats Grid
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                    StatItem(
                        title: "Completion",
                        value: "\(Int((Float(states.count) / 50.0) * 100))%"
                    )
                }
            }
            
            // Badges Section (if any badges earned)
            if !badges.isEmpty {
                VStack(spacing: 12) {
                    Text("Badges Earned")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: 70, maximum: 80), spacing: 12),
                            GridItem(.adaptive(minimum: 70, maximum: 80), spacing: 12),
                            GridItem(.adaptive(minimum: 70, maximum: 80), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        ForEach(badges) { badge in
                            VStack(spacing: 4) {
                                Image(systemName: badge.imageName)
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                
                                Text(badge.name)
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .frame(height: 24)
                                
                                if let date = badge.getLatestVisitDate(from: states) {
                                    Text(date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .frame(height: 70)
                            .padding(8)
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.white.opacity(0.1))
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
            
            Spacer(minLength: 0)
            
            // Footer
            HStack {
                Text("Tracked with")
                Text("TrekBook")
                    .fontWeight(.semibold)
                Text("🧭")
            }
            .font(.footnote)
            .foregroundColor(.white.opacity(0.9))
        }
        .padding(32)
        .frame(width: 390, height: 844)
        .background {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.8),
                    Color.purple.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Subtle wave pattern
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
        }
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
