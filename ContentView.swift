import SwiftUI

// 状態
enum Status {
    case home // 前日
    case coming // 移動中
    case checkIn // 受付
    case takingIn // 楽器搬入
    case preparing // 楽器出し
    case beforeTuning // チューニング室待ち
    case tuning // チューニング
    case waitingX // 待機X
    case waitingY // 待機Y
    case performing // 演奏
    case putAway // 楽器片付け
    case takingOut // 楽器搬出
    case done // 完了
}

// 構造体：タイムテーブルの行
struct ScheduleRow: Identifiable {
    let id = UUID()  // ID
    let time: String // 時刻
    let name: String // 団体名
    let status: Status // 状態
}

struct ContentView: View {
    // 現在時刻
    @State var nowTime = Date()
    // 前回時刻の分
    @State var previousMinute = ContentView.formatDate(Date(), format: "mm")
    // 大きさ
    @State private var gridScale: CGFloat = 1.0
    
    
    // タイムテーブルデータ
    let scheduleRows: [ScheduleRow] = (6*60..<24*60).map { minute in
        let timeString = String(format: "%02d:%02d", minute / 60, minute % 60)
        let nameString = "団体\(minute + 1)" // 連番: 1から開始
        return ScheduleRow(time: timeString, name: nameString, status: .home)
    }
    
    // 時刻更新用タイマー
    private let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()

    // 表示
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let timeFont = Font.monospacedDigitSystemFont(ofSize: geometry.size.width * 0.3, weight: .black)
                let secondFont = Font.system(size: geometry.size.width * 0.08, weight: .light, design: .monospaced)
                // タテ配置
                VStack {
                    // -------------------------------
                    // ----------時計表示領域----------
                    // -------------------------------
                    // ヨコ配置
                    HStack(alignment: .lastTextBaseline, spacing: -8) {
                        // 時間
                        
                        Text(Self.formatDate(nowTime, format: "HH"))
                            .font(timeFont)
                        // コロン
                        Text(":")
                            .font(timeFont)
                        // 分
                        Text(Self.formatDate(nowTime, format: "mm"))
                            .font(timeFont)
                        // 秒
                        Text(Self.formatDate(nowTime, format: "ss"))
                            .font(secondFont)
                    }
                    // 幅：親画面いっぱい、中央寄せ
                    .frame(maxWidth: .infinity, alignment: .center)
                    // 背景：黒
                    .background(Color.black)
                    // 1秒ごとに表示時間更新
                    .onReceive(timer) {input in
                        nowTime = input
                    }
                    
                    // -------------------------------
                    // -------タイムテーブル領域--------
                    // -------------------------------
                    
                    // データテーブル領域
                    VStack(spacing: 0){
                        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                            // ヘッダ行
                            GridRow {
                                // 2列分セル合体
                                Text("演奏時刻")
                                    .gridCellColumns(2)
                                    .frame(alignment: .leading)
                            }
                            Divider().gridCellUnsizedAxes([.horizontal, .vertical])
                        }
                        ScrollViewReader { scrollProxy in
                            // スクロール領域
                            ScrollView(.vertical) {
                                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8){
                                    // データ行
                                    ForEach(scheduleRows) { row in
                                        GridRow {
                                            Text(row.time)
                                                .font(.system(size: 30))
                                            Text(row.name)
                                                .font(.system(size: 30))
                                        }
                                        // スクロール対象のID
                                        .id(row.id)
                                    }
                                }
                                // タイマーイベント
                                .onReceive(timer) { currentTime in
                                    // 現在時刻の分を取得
                                    let currentMinute = Self.formatDate(currentTime, format: "mm")
                                    // 分が更新された場合
                                    if currentMinute != previousMinute {
                                        // 前回時刻の分を更新
                                        previousMinute = currentMinute
                                        // 時刻比較
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "HH:mm"
                                        formatter.locale = Locale(identifier: "en_JP")
                                        
                                        let truncatedTimeString = formatter.string(from: currentTime)
                                        guard let truncatedCurrentTime = formatter.date(from: truncatedTimeString) else { return }
                                        for (i, row) in scheduleRows.enumerated() {
                                            if let rowTime = formatter.date(from: row.time),
                                               rowTime >= truncatedCurrentTime {
                                                // 1つ前の行が存在するか確認
                                                let targetIndex = max(i - 1, 0)
                                                let targetID = scheduleRows[targetIndex].id
                                                
                                                withAnimation {
                                                    scrollProxy.scrollTo(targetID, anchor: .top)
                                                }
                                                break
                                            }
                                        }
                                    }
                                }
                                // ScrollView の末尾に追加
                                Spacer()
                                    .frame(height: 900) // 必要に応じて調整
                                
                            }
                            
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
                            //}
                            // 幅：画面いっぱい
                            .frame(maxWidth: .infinity, alignment: .center)
                            // 背景：黒
                            .background(Color.black)
                        }
                    }
                }
            }
        }
    }
    static func formatDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_JP")
        return formatter.string(from: date)
    }
}
