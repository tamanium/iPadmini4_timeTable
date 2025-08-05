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
                    // 時間
                    Text(Self.hourFormatter.string(from: nowTime))
                    // コロン
                    Text(":")
                    // 分
                    Text(Self.minuteFormatter.string(from: nowTime))
                }
                // 幅：親画面いっぱい、中央寄せ
                .frame(maxWidth: .infinity, alignment: .center)
                // 背景：黒
                .background(Color.black)
                // フォント
                // サイズ：本画面いっぱい×倍率
                // 太さ：普通か細いか
                // デザイン：ラウンデッド？
                .font(.system(size: geometry.size.width * 0.42, weight: .light, design: .rounded))
                // 画像
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                // テキスト
                Text("Hello, world!")
            }
            // 幅：画面いっぱい
            .frame(maxWidth: .infinity, alignment: .center)
            // 背景：黒
            .background(Color.black)
            // 1分ごとに表示時間更新
            .onReceive(timer) {input in nowTime = input}
        }
    }
}
