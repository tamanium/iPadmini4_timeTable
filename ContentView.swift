import SwiftUI

struct ContentView: View {
    // 現在時刻
    @State var nowTime = Date()
    // 前回時刻の分
    @State var prevMinute = ""
    // スケジュール行配列
    @State private var scheduleRows: [ScheduleRow] = []
    // 時刻更新用タイマー
    private let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
    // 演奏中の行を基準にスクロール
    @State private var scrollToPerforming: (() -> Void)?
    
    // 表示
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let viewWidth = geometry.size.width
                // 時計フォント
                let timeFont = Font.system(size: viewWidth * 0.3, weight: .medium, design: .monospaced)
                // 秒フォント
                let secondFont = Font.system(size: viewWidth * 0.08, weight: .light, design: .monospaced)
                // タテ配置
                VStack {
                    // ----------時計表示領域----------
                    // ヨコ配置
                    HStack(alignment: .lastTextBaseline, spacing: -8) {
                        // 時間
                        Text(Utils.formatDate(nowTime, format: "HH")).font(timeFont)
                        // コロン
                        Text(":").font(timeFont)
                        // 分
                        Text(Utils.formatDate(nowTime, format: "mm")).font(timeFont)
                        // 秒
                        Text(Utils.formatDate(nowTime, format: "ss")).font(secondFont)
                    }
                    .minimumScaleFactor(0.5)    // 最小50%まで縮小
                    .lineLimit(1)               // 折り返し防止
                    .layoutPriority(1)          // レイアウト優先p
                    .frame(
                        maxWidth: .infinity, // 幅：親画面いっぱい
                        alignment: .center      // 中央寄せ
                    )
                    .background(Color.black) 
                    .onReceive(timer) {input in // 1秒ごとに表示時間更新
                        nowTime = input
                    }
                    
                    // -------タイムテーブル領域--------
                    // データテーブル領域
                    VStack(spacing: 0){
                        // ヘッダ行
                        Text("演奏時刻")
                        // ダブルタップのイベント
                            .onTapGesture(count:1) {
                                // 演奏中の行を基準にスクロール
                                scrollToPerforming?()
                            }
                        // スクロール領域
                        ScrollViewReader { scrollProxy in
                            // 縦スクロール領域
                            ScrollView(.vertical) {
                                Grid(alignment: .leading, horizontalSpacing: 32, verticalSpacing: 16){
                                    // データ行
                                    ForEach(scheduleRows) { row in
                                        ScheduleRowView(row: row)
                                    }
                                }
                                // タイマーイベント
                                .onReceive(timer) { currentTime in
                                    // 現在時刻の分を取得
                                    let nowMinute = Utils.formatDate(currentTime, format: "mm")
                                    // 分が更新された場合
                                    if nowMinute != prevMinute {
                                        // 前回時刻の分を更新
                                        DispatchQueue.main.async {
                                            prevMinute = nowMinute
                                        }
                                        // スケジュール配列でループ処理
                                        for (i, row) in scheduleRows.enumerated() {
                                            // 現在時刻が行の時刻に達している場合
                                            if row.date <= currentTime {
                                                // その行のStatusを完了とする
                                                scheduleRows[i].setStatus(.last)
                                                continue
                                            }
                                            // 現在時刻が行の時刻に達していない場合
                                            else {
                                                // 一つ上の行のStatusを演奏中とする
                                                if 0 <= i-1 {
                                                    scheduleRows[i-1].setStatus(.performing)
                                                }
                                                // スクロール処理
                                                scrollToPerforming?()
                                                break
                                            }
                                        }
                                    }
                                }
                                Spacer().frame(height: 900) // スクロール下部スペース
                            }
                            .onAppear{
                                scrollToPerforming = {
                                    // 演奏中の行を検索
                                    let topID: AnyHashable
                                    if let index = scheduleRows.firstIndex(where: {$0.nowStatus == .performing}){
                                        // その1つ上の行のインデックスを取得
                                        let topIndex = max(0, index-1)
                                        topID = scheduleRows[topIndex].id
                                    } else {
                                        topID = scheduleRows[0].id
                                    }
                                    // スクロール処理
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        scrollProxy.scrollTo(topID, anchor: .top)
                                    }
                                }
                            }
                        }
                    }
                    // 背景：黒
                    .background(Color.black)
                    // -----------ボタン領域-----------
                }
                .frame(maxWidth: .infinity) // 幅：親画面いっぱい
                // スケジュールデータ初期化
                .onAppear {
                    let calendar = Calendar.current
                    let nowDate = Date()
                    let currentHour = calendar.component(.hour, from: nowDate)
                    scheduleRows = ((currentHour)*60..<(currentHour+2)*60).map { minute in
                        let nameString = "団体\(minute + 1)"
                        let _hour = minute/60
                        let _minute = minute%60
                        let date = calendar.date(bySettingHour: _hour, minute: _minute, second: 0, of: nowDate)!
                        
                        return ScheduleRow(
                            id: UUID(),
                            name: nameString,
                            date:date,
                            nowStatus: Status.first,
                            statusDates: nil
                        )
                    }
                }
            }
        }
    }
}
 
struct ScheduleRowView: View {
    let row: ScheduleRow
    var body: some View {
        let opacity = Utils.setOpacity(row.nowStatus, base: .performing)
        GridRowView(
            status: row.nowStatus.rawValue,
            time: Utils.formatDate(row.date, format: "HH:mm"),
            name: row.name
        )
        .opacity(opacity)
        .id(row.id)
    }
}
struct GridRowView: View {
    let status: String
    let time: String 
    let name: String
    var body: some View {
        GridRow{
            Text(status)
                .font(.system(size:50))
            Text(time)
                .font(.system(size: 50, design: .monospaced))
            Text(name)
                .font(.system(size:50))
        }
    }
}
