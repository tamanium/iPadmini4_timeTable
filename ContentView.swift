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
    // リンク処理
    @State private var path = NavigationPath()
    // 初回フラグ
    @State private var isInit = false
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
                                        ScheduleRowView(row: row, model: model)
                                    }
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
                            }
                            .onAppear{
                                model.scrollToPerforming = {
                                    // 演奏中の行を検索
                                    let topID: AnyHashable
                                    var topIndex = 0
                                    // あれば演奏中行の1つ上の行のインデックスを取得
                                    if let index = model.scheduleRows.firstIndex(where: {$0.nowStatus == .performing}){
                                        topIndex = max(0, index-1)
                                    }
                                    topID = model.scheduleRows[topIndex].id
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
                    // -----------ボタン領域-----------
                    Button("追加") {
                        let newDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
                        model.addRow(name: "新しい団体", date: newDate)
                    }
                }
                .frame(maxWidth: .infinity)
                // スケジュールデータ初期化
                .onAppear {
                    if !isInit {
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
                        isInit = true
                    }
                }
            }
        }
    }
}

// 行の表示
struct ScheduleRowView: View {
    let row: ScheduleRow
    @ObservedObject var model: ScheduleModel

    @State private var isEditMode = false
    @State private var newName: String = ""
    @State private var newDate: Date = Date()
    
    var body: some View {
        let opacity = Utils.setOpacity(row.nowStatus, base: .performing)
        HStack {
            Spacer()
            GridRowView(
                status: row.nowStatus.rawValue,
                time: Utils.formatDate(row.date, format: "HH:mm"), 
                name: row.name
            )
            Spacer()
            HStack {
                Button("編集") {
                    newName = row.name
                    newDate = row.date
                    isEditMode = true
                }
                Button("削除") {
                    model.deleteRow(id: row.id)
                }
            }
        }
        .opacity(opacity)
        .id(row.id) 
        .sheet(isPresented: $isEditMode) {
            EditSheet(
                name: $newName,
                date: $newDate,
                onSave: {
                    model.updateRow(id: row.id, name: newName, date: newDate)
                    isEditMode = false
                },
                onCancel: {
                    isEditMode = false
                }
            )
        }
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

