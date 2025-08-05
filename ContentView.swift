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
    // 前回時刻の分
    @State var previousMinute: String = ""
    
    // タイムテーブルデータ
    let scheduleRows: [ScheduleRow] = [
        ScheduleRow(time:"12:40", name:"ABC学園"),
        ScheduleRow(time:"13:50", name:"ABC高校"),
        ScheduleRow(time:"13:50", name:"ABC高校"),
        ScheduleRow(time:"13:50", name:"ABC高校"),
        ScheduleRow(time:"13:50", name:"ABC高校"),
        ScheduleRow(time:"13:50", name:"ABC高校"),
        ScheduleRow(time:"13:50", name:"ABC高校"),
        ScheduleRow(time:"13:50", name:"ABC高校"),
        ScheduleRow(time:"13:50", name:"ABC高校"),
        ScheduleRow(time:"13:50", name:"ABC高校"),
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
        NavigationStack {
            GeometryReader { geometry in
                let timeFont = Font.system(size: geometry.size.width * 0.3, weight: .light, design: .monospaced)
                let secondFont = Font.system(size: geometry.size.width * 0.1, weight: .light, design: .monospaced)
                // タテ配置
                VStack {
                    // -------------------------------
                    // ----------時計表示領域----------
                    // -------------------------------
                    // ヨコ配置
                    HStack(alignment: .lastTextBaseline, spacing:-1) {
                        // 時間
                        Text(Self.hourFormatter.string(from: nowTime))
                            .font(timeFont)
                        // コロン
                        Text(":")
                            .font(timeFont)
                        // 分
                        Text(Self.minuteFormatter.string(from: nowTime))
                            .font(timeFont)
                        // 秒
                        Text(Self.minuteFormatter.string(from: nowTime))
                            .font(secondFont)
                    }
                    // 幅：親画面いっぱい、中央寄せ
                    .frame(maxWidth: .infinity, alignment: .center)
                    // 背景：黒
                    .background(Color.black)
                    
                    // -------------------------------
                    // -------タイムテーブル領域--------
                    // -------------------------------
                    ScrollViewReader { scrollProxy in
                        ScrollView(.vertical) {
                            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                                // ヘッダ行
                                GridRow {
                                    // 2列分セル合体
                                    Text("演奏時刻").gridCellColumns(2)
                                }
                                Divider().gridCellUnsizedAxes([.horizontal, .vertical])
                                // データ行
                                ForEach(scheduleRows) { row in
                                    GridRow {
                                        Text(row.time).font(.system(design: .monospaced))
                                        Text(row.name)
                                    }
                                    // スクロール対象のID
                                    .id(row.id)
                                }
                            }
                            .padding()
                            .background(Color.black)
                            .cornerRadius(2)
                        }
                        .frame(maxHeight: geometry.size.height * 0.5)
                        .onReceive(timer) { currentTime in
                            nowTime = currentTime
                            // 現在時刻の分を取得
                            let currentMinute = Self.minuteFormatter.string(from: currentTime)
                            
                            // 分が更新された場合
                            if currentMinute != previousMinute {
                                // 前回時刻の分を更新
                                previousMinute = currentMinute
                                // 時刻比較
                                let formatter = DateFormatter()
                                formatter.dateFormat = "HH:mm"
                                formatter.locale = Locale(identifier: "en_JP")
                                
                                let nowString = formatter.string(from: currentTime)
                                
                                for row in scheduleRows {
                                    if let rowTime = formatter.date(forom: row.time),
                                       rowTime > currentTime {
                                        scrollProxy.scrollTo(row.id, anchor: .top)
                                        break;
                                    }
                                }
                            }
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
                        .frame(maxWidth: .infinity, alignment: .center)
                        // 背景：黒
                        .background(Color.black)
                        // 1秒ごとに表示時間更新
                        .onReceive(timer) {input in nowTime = input
                        }
                    }
                }
            }
        }
    }
}
