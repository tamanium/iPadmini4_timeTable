import SwiftUI

// 構造体：タイムテーブルの行
struct ScheduleRow: Identifiable {
    let id = UUID()  // ID
    let time: String // 時刻
    let name: String // 団体名
}

struct ContentView: View {
    // 現在時刻
    @State var nowTime = Date()

    // タイムテーブルデータ
    let scheduleRows: [ScheduleRow] = [
        ScheduleRow(time:"12:40", name:"ABC学園"),
        ScheduleRow(time:"13:50", name:"ABC高校"),
        ScheduleRow(time:"14:00", name:"abc学校")
    ]
    
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
    
    // 秒のフォーマッター(staticで再利用)
    private static let secondFormatter: DateFormatter  = {
        let formatter = DateFormatter()
        formatter.dateFormat = "ss"
        formatter.locale = Locale(identifier: "en_JP")
        return formatter
    }()

    // 表示
    var body: some View {
        GeometryReader { geometry in
            // タテ配置
            VStack {
                // -----時計表示領域-----
                // ヨコ配置
                HStack(alignment: .lastTextbaseline, spacing:-1) {
                    // 時間
                    Text(Self.hourFormatter.string(from: nowTime))
                        .font(.system(size: geometry.size.width * 0.42, weight: .light, design: .rounded))
                    // コロン
                    Text(":")
                        .font(.system(size: geometry.size.width * 0.42, weight: .light, design: .rounded))
                    // 分
                    Text(Self.minuteFormatter.string(from: nowTime))
                        .font(.system(size: geometry.size.width * 0.42, weight: .light, design: .rounded))
                    // 分
                    Text(Self.secondFormatter.string(from: nowTime))
                        .font(.system(size: geometry.size.width * 0.2, weight: .light, design: .rounded))
                }
                // 幅：親画面いっぱい、中央寄せ
                .frame(maxWidth: .infinity, alignment: .center)
                // 背景：黒
                .background(Color.black)

                // -----タイムテーブル領域-----
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                    GridRow {
                        Text("時刻").bold()
                        Text("学校名").bold()
                    }
                    Divider().gridCellUnsizedAxes([.horizontal, .vertical])

                    ForEach(scheduleRows) { row in
                        GridRow {
                            Text(row.time)
                            Text(row.name)
                        }
                   }
                }
                .padding()
                .background(Color.black)
                .cornerRadius(2)
                
                // 画像
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                // テキスト
                Text("Hello, world!")
                Spacer()

                // 画面遷移ボタン
                NavigationLink(destination: SecondView()) {
                    Text("Data")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
            // 幅：画面いっぱい
            .frame(maxheight: geometry.size.height * 0.5, maxWidth: .infinity, alignment: .center)
            // 背景：黒
            .background(Color.black)
            // 1分ごとに表示時間更新
            .onReceive(timer) {input in nowTime = input}
        }
    }
}
