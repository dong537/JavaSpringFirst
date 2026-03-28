import SwiftUI
import UIKit

struct BadgeTokenView: View {
    let badgeAssetName: String

    var body: some View {
        Group {
            if let image = UIImage(named: badgeAssetName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.98, green: 0.74, blue: 0.17), Color(red: 0.93, green: 0.38, blue: 0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(spacing: 2) {
                        Text("TL")
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)

                        Text("LOGO")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.92))
                    }
                }
                .frame(height: 90)
            }
        }
        .frame(height: 90)
    }
}
