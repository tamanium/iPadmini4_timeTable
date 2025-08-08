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
                    .layoutPriority(1)          // レイアウト優先
                    .frame(
                        maxWidth: .infinity, // 幅：親画面いっぱい
                        alignment: .center      // 中央寄せ
                    )
                    .background(Color.black)    // 背景：黒
                    .onReceive(timer) {input in // 1秒ごとに表示時間更新
                        nowTime = input
                    }
                    
                    // -------タイムテーブル領域--------
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
                                            // ステータス
                                            Text(row.nowStatus.rawValue)
                                                .font(.system(size:50))
                                            // 時刻
                                            Text(row.timeStr)
                                                .font(.system(size: 50, design: .monospaced))
                                            // 名前
                                            Text(row.name)
                                                .font(.system(size:50))
                                            
                                        }
                                        // 演奏後は文字色グレー
                                        .opacity(Status.performing.order < row.nowStatus.order ? 0.3 : 1.0)
                                        .id(row.id) // スクロール対象のID
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
                                        // 現在時刻をHH:mmの文字列として取得
                                        let truncatedTimeStr = Utils.formatDate(currentTime, format: "HH:mm")
                                        // HH:mmの文字列からDate型に変換(二度手間か?)
                                        guard let truncatedCurrentTime = Utils.dateFromString(truncatedTimeStr, format: "HH:mm") else { return }
                                        // スケジュール配列でループ処理
                                        for (i, row) in scheduleRows.enumerated() {
                                            // 行の時刻をDate型で取得
                                            guard let rowTime = Utils.dateFromString(row.timeStr, format: "HH:mm") else { return}
                                            // 現在時刻が行の時刻に達している場合
                                            if rowTime <= truncatedCurrentTime {
                                                // その行のStatusを完了とし、次のループ処理を行う
                                                var _scheduleRow = scheduleRows[i]
                                                _scheduleRow.nowStatus = Status.last
                                                    scheduleRows[i] = _scheduleRow
                                                continue
                                            }
                                            
                                            // 現在時刻が行の時刻に達していない場合
                                            if truncatedCurrentTime < rowTime {
                                                // (あれば)一つ上の行のStatusを演奏中とする
                                                if 0 <= i-1 {
                                                    var _scheduleRow = scheduleRows[i]
                                                    _scheduleRow.nowStatus = Status.performing
                                                        scheduleRows[i] = _scheduleRow
                                                }

                                                // 2つ上までの行からidを取得する
                                                let indexArr = [0, i-1, i-2]
                                                let topRowIndex = indexArr.max()
                                                let topRowID = scheduleRows[topRowIndex].id
                                                // 対象行へスクロールする
                                                withAnimation {
                                                    scrollProxy.scrollTo(topRowID, anchor: .top)
                                                }
                                                break
                                            }
                                        }
                                    }
                                }
                                Spacer().frame(height: 900) // スクロール下部スペース
                            }
                        }
                    }
                    // 背景：黒
                    .background(Color.black)
                    // -----------ボタン領域-----------
                }
                // スケジュールデータ初期化
                .onAppear {
                    scheduleRows = (6*60..<24*60).map { minute in
                        let timeString = String(format: "%02d:%02d", minute / 60, minute % 60)
                        let nameString = "団体\(minute + 1)"
                        return ScheduleRow(
                            id: UUID(),
                            timeStr: timeString,
                            name: nameString,
                            nowStatus: Status.first,
                            //date:date,
                            date:nil,
                            statusDates: nil
                        )
                    }
                }
            }
        }
    }
}
