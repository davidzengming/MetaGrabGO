import SwiftUI

// Entry point into view
struct MainView: View {
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    
    var body: some View {
        ZStack {
            self.assetsDataStore.colors["darkButNotBlack"]!
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                if self.userDataStore.isAuthenticated == false {
                    UserView()
                } else {
                    GameHubView()
                        .environmentObject(RecentFollowDataStore())
                        .environmentObject(GlobalGamesDataStore())
                }
            }
        }
        
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
