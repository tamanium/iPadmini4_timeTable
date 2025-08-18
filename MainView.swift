import SwiftUI

struct MainView: View {
    
    @StateObject private var vm = ViewModel()
    @State var nowTime = Date()
    @State var prevMinute = "60"
    private let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
    
    @State private var scrollToPerforming: (() -> Void)?
    @State private var path = NavigationPath()
    
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
                    .background(Color.black) 
                    // -------タイムテーブル領域--------
                    // データテーブル領域
                    VStack(spacing: 0) {
                        // ヘッダ行
                        Text("演奏時刻")
                            .onTapGesture {
                                scrollToPerforming?()
                            }
                        // スクロール領域
                        ScrollViewReader { scrollProxy in
                            Spacer()
                            // 縦スクロール領域
                            ScrollView(.vertical) {
                                Grid(alignment: .trailing, horizontalSpacing: 32, verticalSpacing: 16){
                                    if !vm.schedules.isEmpty {
                                        // 表示
                                        ForEach(vm.schedules, id: \.id) { schedule in
                                            ScheduleView(schedule: schedule)
                                        }
                                    } else {
                                        Text("データがありません")
                                    }
                                }
                                // ScrollView内
                                .onChange(of: vm.nowTime) {
                                    let nowMinute = Utils.formatDate(vm.nowTime, format: "mm")
                                    if(prevMinute != nowMinute) {
                                        prevMinute = nowMinute
                                        scrollToPerforming?()
                                    }
                                }
                                .padding(.bottom, geometry.size.height * 0.5)
                            }
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            .onAppear{
                                scrollToPerforming = {
                                    if let scrollID = vm.updateStatuses(currentTime: vm.nowTime) {
                                        print(scrollID)
                                        DispatchQueue.main.async{
                                            withAnimation {
                                                scrollProxy.scrollTo(scrollID, anchor: .top)
                                            }
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
                        vm.addSchedule(name: "新しい団体", date: newDate)
                    }
                    Button("全体編集") {
                        path.append("edit")
                    }
                    .navigationDestination(for: String.self) { value in
                        if value == "edit" {
                            EditView(vm: vm)
                        }
                    }
                    Button("スケジュール初期化") {
                        vm.initSchedules()
                        scrollToPerforming?()
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// テーブルの表示
struct ScheduleView: View {
    let schedule: Schedule
    
    var body: some View {
        HStack {
            ScheduleGridRowView( schedule: schedule)
        }
        .opacity(schedule.opacity(base:.performing))
        .id(schedule.id)
    }
}
// 行の表示
struct ScheduleGridRowView: View { 
    let schedule: Schedule
    
    var body: some View { 
        GridRow{ 
            Text(schedule.status.rawValue) 
                .frame(width:70)
                .font(.system(size:50)) 
            let time = Utils.formatDate(schedule.date, format: "HH:mm")
            Text(time) 
                .frame(width:180)
                .font(.system(size: 50, design: .monospaced)) 
            Text(schedule.name) 
                .frame(width:450, alignment: .leading)
                .font(.system(size:50)) 
        } 
    } 
}

