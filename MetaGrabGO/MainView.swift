import SwiftUI

// Entry point into view
struct MainView: View {
    @EnvironmentObject private var userDataStore: UserDataStore
    
    var body: some View {
        ZStack {
            appWideAssets.colors["darkButNotBlack"]!
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                GameHubView()
                    .environmentObject(RecentFollowDataStore())
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
