import SwiftUI

struct AppPageBackground: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image("VoteSelectionBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
}

#Preview {
    AppPageBackground()
}
