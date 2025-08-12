import SwiftUI

struct ContentView: View {
    
    @StateObject private var model = ScheduleModel()
    // 現在時刻
    @State var nowTime = Date()
    // 時刻更新用タイマー
    private let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
    // 演奏中の行を基準にスクロール
    @State private var scrollToPerforming: (() -> Void)?
    
    @State private var path = NavigationPath()
    
    // 表示
    var body: some View {
        NavigationStack(path: $path) {
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
                    .layoutPriority(1)          // レイアウト優先
                    .frame(
                        maxWidth: .infinity, // 幅：親画面幅
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
                                    // 表示
                                    ForEach(model.scheduleRows) { row in
                                        ScheduleRowView(row: row)
                                    }
                                    // データ行
                                }
                                // タイマーイベント
                                .onReceive(timer) { currentTime in
                                    if let scrollID = model.updateStatuses(currentTime: currentTime) {
                                        withAnimation {
                                            scrollProxy.scrollTo(scrollID, anchor: .top)
                                        }
                                    }
                                }
                                .padding(.bottom, geometry.size.height * 0.5)
                                //Spacer().frame(height: 900) // スクロール下部スペース
                            }
                            .onAppear{
                                model.scrollToPerforming = {
                                    // 演奏中の行を検索
                                    let topID: AnyHashable
                                    if let index = model.scheduleRows.firstIndex(where: {$0.nowStatus == .performing}){
                                        // その1つ上の行のインデックスを取得
                                        let topIndex = max(0, index-1)
                                        topID = model.scheduleRows[topIndex].id
                                    } else {
                                        topID = model.scheduleRows[0].id
                                    }
                                    // スクロール処理
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        scrollProxy.scrollTo(topID, anchor: .top)
                                    }
                                }
                            }
                        }
                    }
                    .background(Color.black)
                    .frame(maxWidth: .infinity)
                    //Spacer()
                    // -----------ボタン領域-----------
                    //NavigationLink("追加画面へ") {
                    //    SecondView(model: model)
                    //}
                }
                .frame(maxWidth: .infinity)
                // スケジュールデータ初期化
                .onAppear {
                    let calendar = Calendar.current
                    let nowDate = Date()
                    let currentHour = calendar.component(.hour, from: nowDate)
                    model.scheduleRows = ((currentHour)*60..<(currentHour+1)*60).map { minute in
                        let nameString = "団体\(minute - currentHour*60)"
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
            name: row.name ) 
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
