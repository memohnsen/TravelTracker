import SwiftUI
import UniformTypeIdentifiers

struct AppIconPreview: View {
    @State private var exportPath: String = ""
    @State private var isDarkMode = false
    
    var body: some View {
        VStack {
            AppIcon()
                .frame(width: 512, height: 512)
                .environment(\.colorScheme, isDarkMode ? .dark : .light)
            
            // Export options
            ScrollView {
                VStack(spacing: 16) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                        .padding(.horizontal)
                    
                    Button {
                        exportAllSizes()
                    } label: {
                        Text("Export \(isDarkMode ? "Dark" : "Light") Icons")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        exportAllSizes(darkMode: true)
                        exportAllSizes(darkMode: false)
                    } label: {
                        Text("Export Both Light & Dark")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    if !exportPath.isEmpty {
                        Text("Icons exported to:\n\(exportPath)")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
        }
    }
    
    func exportAllSizes(darkMode: Bool? = nil) {
        let sizes = [1024, 180, 120, 80, 60, 58, 40]
        let mode = darkMode ?? isDarkMode
        
        // Create a directory for the icons
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let iconDirectory = documentsPath.appendingPathComponent("AppIcons")
        
        try? fileManager.createDirectory(at: iconDirectory, withIntermediateDirectories: true)
        
        // Export each size
        for size in sizes {
            let renderer = ImageRenderer(content: AppIcon()
                .frame(width: CGFloat(size), height: CGFloat(size))
                .environment(\.colorScheme, mode ? .dark : .light)
            )
            renderer.scale = 1
            
            if let image = renderer.uiImage {
                let prefix = mode ? "dark" : "light"
                let fileName = "\(prefix)_icon_\(size)x\(size).png"
                let fileURL = iconDirectory.appendingPathComponent(fileName)
                
                if let imageData = image.pngData() {
                    try? imageData.write(to: fileURL)
                }
            }
        }
        
        exportPath = iconDirectory.path
    }
}

struct AppIcon: View {
    @Environment(\.colorScheme) var colorScheme
    
    var gradientColors: [Color] {
        colorScheme == .dark ? [
            Color.black,
            Color.black
        ] : [
            Color.blue.opacity(0.8),
            Color.purple.opacity(0.8)
        ]
    }
    
    var mapGradient: [Color] {
        colorScheme == .dark ? [
            Color.blue.opacity(0.8),
            Color.purple.opacity(0.8)
        ] : [
            Color.white,
            Color.white
        ]
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Subtle wave pattern
                Path { path in
                    let size = geometry.size.width
                    path.move(to: CGPoint(x: 0, y: size * 0.3))
                    path.addCurve(
                        to: CGPoint(x: size, y: size * 0.4),
                        control1: CGPoint(x: size * 0.4, y: size * 0.2),
                        control2: CGPoint(x: size * 0.6, y: size * 0.5)
                    )
                    path.addLine(to: CGPoint(x: size, y: size))
                    path.addLine(to: CGPoint(x: 0, y: size))
                }
                .fill(Color.white.opacity(colorScheme == .dark ? 0.05 : 0.1))
                
                // Map icon with gradient
                Image(systemName: "map.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(geometry.size.width * 0.15)
                    .foregroundStyle(
                        LinearGradient(
                            colors: mapGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Pin overlay
                Image(systemName: "mappin.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.25)
                    .foregroundColor(.red)
                    .background {
                        Circle()
                            .fill(.white)
                            .scaleEffect(0.8)
                    }
                    .offset(x: geometry.size.width * 0.1, y: geometry.size.width * 0.1)
                    .shadow(color: .black.opacity(0.3), radius: geometry.size.width * 0.02, x: 0, y: geometry.size.width * 0.01)
            }
        }
    }
}

// Preview with both light and dark modes
struct AppIcon_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 40) {
            AppIcon()
                .frame(width: 180, height: 180)
                .environment(\.colorScheme, .light)
            
            AppIcon()
                .frame(width: 180, height: 180)
                .environment(\.colorScheme, .dark)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

#Preview {
    AppIconPreview()
} 
