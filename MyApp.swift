import SwiftUI

@main
struct MyApp: App {

    init() {
        // アプリ起動時にスリープを無効にする
        UIApplication.shared.isIdleTimerDisabled = true
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
