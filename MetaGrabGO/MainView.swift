import SwiftUI

// Entry point into view
struct MainView: View {
    var body: some View {
        ZStack {
            appWideAssets.colors["darkButNotBlack"]!
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                GameHubView()
                .environmentObject(UserDataStore())
                .environmentObject(GlobalGamesDataStore())
            }
        }
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
