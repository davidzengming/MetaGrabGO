import SwiftUI

// Entry point into view
struct MainView: View {
    @EnvironmentObject var userDataStore: UserDataStore
    
    var body: some View {
        VStack {
            if self.userDataStore.isAuthenticated == false {
                UserView()
            } else {
                GameHubView()
                    .environmentObject(GameDataStore())
                    .environmentObject(AssetsDataStore())
                    .environmentObject(KeyboardHeightDataStore())
            }
        }
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
