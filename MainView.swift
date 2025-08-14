import SwiftUI

struct MainView: View {
    
    @StateObject private var vm = ViewModel()
    @State var nowTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
    
    @State private var scrollToPerforming: (() -> Void)?
    @State private var path = NavigationPath()
    @State private var isInit = false
    
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
                        Text(Utils.formatDate(vm.nowTime, format: "HH")).font(timeFont)
                        // コロン
                        Text(":").font(timeFont)
                        // 分
                        Text(Utils.formatDate(vm.nowTime, format: "mm")).font(timeFont)
                        // 秒
                        Text(Utils.formatDate(vm.nowTime, format: "ss")).font(secondFont)
                    }
                    .minimumScaleFactor(0.5)    // 最小50%まで縮小
                    .lineLimit(1)               // 折り返し防止
                    .layoutPriority(1)          // レイアウト優先
                    .frame(
                        maxWidth: .infinity, // 幅：親画面幅
                        alignment: .center      // 中央寄せ
                    )
                    .background(Color.black) /*
                    .onReceive(timer) {input in // 1秒ごとに表示時間更新
                        nowTime = input
                    }*/
                    // -------タイムテーブル領域--------
                    // データテーブル領域
                    VStack(spacing: 0){
                        // ヘッダ行
                        Text("演奏時刻")
                        // タップのイベント
                        /*
                            .gesture(){
                                print("title tap")
                                DispatchQueue.main.async{
                                    withAnimation {
                                        scrollProxy.scrollTo(scrollID, anchor: .top)
                                    }
                                }
                            }
                         */
                        // スクロール領域
                        ScrollViewReader { scrollProxy in
                            // 縦スクロール領域
                            ScrollView(.vertical) {
                                Grid(alignment: .leading, horizontalSpacing: 32, verticalSpacing: 16){
                                    // 表示
                                    ForEach(vm.schedules, id: \.id) { row in
                                        ScheduleView(row: row, vm: vm)
                                    }
                                }
                                // ScrollView内
                                .onChange(of: vm.nowTime) {
                                    if let scrollID = vm.updateStatuses(currentTime: vm.nowTime) {
                                        DispatchQueue.main.async{
                                            withAnimation {
                                                scrollProxy.scrollTo(scrollID, anchor: .top)
                                            }
                                        }
                                    }
                                }

                                .padding(.bottom, geometry.size.height * 0.5)
                            }
                            .onAppear{
                                vm.scrollToPerforming = {
                                    // 最上位行IDを取得
                                    if let topID = vm.getTopIdByStatus(.performing){
                                        // スクロール処理
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            scrollProxy.scrollTo(topID, anchor: .top)
                                        }
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
                        vm.addRow(name: "新しい団体", date: newDate)
                    }
                    Button("全体編集") {
                        path.append("edit")
                    }
                    .navigationDestination(for: String.self) { value in
                        if value == "edit" {
                            EditView(vm: vm)
                        }
                    }

                }
                .frame(maxWidth: .infinity)
                // スケジュールデータ初期化
                .onAppear {
                    if !isInit {
                        let calendar = Calendar.current
                        let nowDate = Date()
                        let currentHour = calendar.component(.hour, from: nowDate)
                        vm.schedules = ((currentHour)*60..<(currentHour+1)*60).map { minute in
                            let nameString = "団体\(minute - currentHour*60)"
                            let _hour = minute/60
                            let _minute = minute%60
                            let date = calendar.date(bySettingHour: _hour, minute: _minute, second: 0, of: nowDate)!
                            
                            return Schedule(
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
struct ScheduleView: View {
    let schedule: Schedule
    @ObservedObject var vm: ViewModel
    
    @State private var isEditMode = false
    @State private var newName: String = ""
    @State private var newDate: Date = Date()
    
    var body: some View {
        let opacity = Utils.setOpacity(schedule.nowStatus, base: .performing)
        HStack {
            GridRowView(
                status: schedule.nowStatus.rawValue,
                time: Utils.formatDate(schedule.date, format: "HH:mm"), 
                name: schedule.name
            )
        }
        .opacity(opacity)
        .id(schedule.id)
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

