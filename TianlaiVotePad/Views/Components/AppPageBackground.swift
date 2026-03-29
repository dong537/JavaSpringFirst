import SwiftUI

struct AppPageBackground: View {
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                Color.black

                Image("VoteSelectionBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipped()
            }
            .frame(width: size.width, height: size.height)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    AppPageBackground()
}
