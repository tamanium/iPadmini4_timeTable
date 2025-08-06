import SwiftUI

struct ContentView: View {
    // 現在時刻
    @State var nowTime = Date()
    // 前回時刻の分
    @State var previousMinute = ContentView.formatDate(Date(), format: "mm")    

    // タイムテーブルデータ（仮データ作成）
    let scheduleRows: [ScheduleRow] = (6*60..<24*60).map { minute in
        var dateComponents = DateComponents()
        dateComponents.year = Calendar.current.component(.year, from:  Date())
        dateComponents.month = Calendar.current.component(.month, from:  Date())
        dateComponents.day = Calendar.current.component(.day, from:  Date())
        dateComponents.hour = minute / 60
        dateComponents.minute = minute % 60
        let timeString = String(format: "%02d:%02d", minute / 60, minute % 60)
        // 連番: 1から開始
        let nameString = "団体\(minute + 1)" 
        // 日付データを取得(失敗した場合はメッセージ)
        guard let date = Calendar.current.date(from: dateComponents) else {
            fatalError("日付の生成に失敗しました")
        }
        return ScheduleRow(
            timeStr: timeString, 
            name: nameString, 
            nowStatus: Status.home, 
            date: date,      // 日付は動的に作成したもの（いずれは入力値）
            statusDates: nil // ステータス-日時のディクショナリは当分nilで
        )
    }
    
    // 時刻更新用タイマー
    private let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()

    // 表示
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                // 時計フォント
                let timeFont = Font.system(size: geometry.size.width * 0.3, weight: .medium, design: .monospaced)
                // 秒フォント
                let secondFont = Font.system(size: geometry.size.width * 0.08, weight: .light, design: .monospaced)
                // タテ配置
                VStack {
                    // -------------------------------
                    // ----------時計表示領域----------
                    // -------------------------------
                    // ヨコ配置
                    HStack(alignment: .lastTextBaseline, spacing: -8) {
                        // 時間
                        Text(Self.formatDate(nowTime, format: "HH")).font(timeFont)
                        // コロン
                        Text(":").font(timeFont)
                        // 分
                        Text(Self.formatDate(nowTime, format: "mm")).font(timeFont)
                        // 秒
                        Text(Self.formatDate(nowTime, format: "ss")).font(secondFont)
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
                        // ヘッダ行
                        Text("演奏時刻")
                        // スクロール領域
                        ScrollViewReader { scrollProxy in
                            // 縦スクロール領域
                            ScrollView(.vertical) {
                                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8){
                                    // データ行
                                    ForEach(scheduleRows) { row in
                                        GridRow {
                                            Text(row.status.rawValue)
                                                .font(.system(size: 30))
                                            Text(row.timeStr)
                                                .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .regular)))
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
                                        
                                        let truncatedTimeString = Self.formatDate(currentTime, format: "HH:mm")
                                        guard let truncatedCurrentTime = Self.dateFromString(truncatedTimeString, format: "HH:mm") else { return }
                                        for (i, row) in scheduleRows.enumerated() {
                                            if let rowTime = Self.dateFromString(row.timeStr, format: "HH:mm"),
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
    // 日付型の日付データを引数フォーマットで文字列に変換する
    static func formatDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_JP")
        return formatter.string(from: date)
    }
    // 文字列から日付データに変換する
    static func dateFromString(_ string: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_JP")
        return formatter.date(from: string)
    }

}
