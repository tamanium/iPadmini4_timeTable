import SwiftUI

struct ContentView: View {
    // 現在時刻
    @State var nowTime = Date()
    
    // 時刻更新用タイマー
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // 時間のフォーマッター（staticで再利用）
    private static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        formatter.locale = Locale(identifier: "en_JP")
        return formatter
    }()
    
    // 分のフォーマッター(staticで再利用)
    private static let minuteFormatter: DateFormatter  = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm"
        formatter.locale = Locale(identifier: "en_JP")
        return formatter
    }()
    
    var body: some View {
        GeometryReader { geometry in
            // タテ配置
            VStack {
                // ヨコ配置
                HStack(spacing:-1) {
                    Text(Self.hourFormatter.string(from: nowTime))
                    Text(":")
                    Text(Self.minuteFormatter.string(from: nowTime))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.system(size: geometry.size.width * 0.42, weight: .light, design: .rounded))
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Hello, world!")
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .onReceive(timer) {input in nowTime = input}
        }
    }
}
