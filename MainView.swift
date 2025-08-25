import SwiftUI

struct MainView: View {
    
    @StateObject private var vm = ViewModel()
    @State var prevMinute = Utils.formatDate(Date(), format: "mm")
    private let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
    
    @State private var scrollToPerforming: (() -> Void)?
    @State private var path = NavigationPath()
    @State private var showPicker = false
    @State private var showExporter = false
    @State private var exportData: Data?
    
    // メイン表示
    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geometry in
                // タテ配置
                VStack {
                    // ----------時計表示領域----------
                    clockView(viewWidth: geometry.size.width)
                        .frame(height: geometry.size.width * 0.4)
                    // -------タイムテーブル領域--------
                    timeTableView(geometry: geometry)
                        .frame(maxHeight: .infinity)
                    // -----------ボタン領域-----------
                    //buttonArea
                    HStack {
                        Button("📂読込") {
                            showPicker = true
                        }
                        Button("💾保存") {
                            exportData = vm.encodeSchedules()
                            showExporter = true
                        }
                        Button("📝編集") {
                            path.append("edit")
                        }
                        Button("➕新規"){
                            path.append("edit")
                        }
                        /*
                         Button("デバッグ用初期化") {
                         vm.initSchedules()
                         scrollToPerforming?()
                         }*/
                    }
                    //.padding()
                    .background(Color.gray.opacity(0.2))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationDestination(for: String.self) { value in
            if value == "edit" {
                EditView(vm: vm)
            }
        }
        .sheet(isPresented: $showPicker) {
            DocumentPicker { url in
                vm.loadSchedules(from: url)
            }
        }
        .sheet(isPresented: $showExporter) {
            if let data = exportData {
                DocumentExporter(data: data, fileName: "schedules.json")
            }
        }
        
    }
    
    // 時計表示
    func clockView(viewWidth: CGFloat) -> some View {
        let timeFont = Font.system(size: viewWidth * 0.3, weight: .medium, design: .monospaced)
        let secFont = Font.system(size: viewWidth * 0.08, weight: .light, design: .monospaced)
        
        return HStack(alignment: .lastTextBaseline, spacing: -8) {
            // 時間
            Text(Utils.formatDate(vm.nowTime, format: "HH")).font(timeFont)
            // コロン
            Text(":").font(timeFont).padding(.horizontal, -30)
            // 分
            Text(Utils.formatDate(vm.nowTime, format: "mm")).font(timeFont)
            // 秒
            Text(Utils.formatDate(vm.nowTime, format: "ss")).font(secFont)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color.black)
    }
    
    // タイムテーブル表示
    func timeTableView(geometry: GeometryProxy) -> some View {
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
                                ScheduleView(schedule: schedule, stdStatus: .performing)
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
                .frame(maxWidth: .infinity)
                .onAppear{
                    scrollToPerforming = {
                        if let scrollID = vm.updateStatusSimple(stdStatus: .performing, currentTime: vm.nowTime) {
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
    }
    /*
     // ボタン領域表示
     var buttonArea: some View {
     VStack(spacing: 8) {
     Button("読込") {
     showPicker = true
     }
     Button("保存") {
     exportData = vm.encodeSchedules()
     showExporter = true
     }
     Button("全体編集") {
     path.append("edit")
     }
     Button("スケジュール初期化") {
     vm.initSchedules()
     scrollToPerforming?()
     }
     }
     }
     */
}

// テーブルの表示
struct ScheduleView: View {
    let schedule: Schedule
    let stdStatus: Status
    
    var body: some View {
        HStack {
            ScheduleGridRowView(schedule: schedule, stdStatus: .performing)
        }
        .opacity(schedule.opacity(base:.performing))
        .id(schedule.id)
    }
}
// 行の表示
struct ScheduleGridRowView: View { 
    let schedule: Schedule
    let stdStatus: Status
    
    var body: some View { 
        GridRow{ 
            Text(schedule.status.rawValue) 
                .frame(width:70)
                .font(.system(size:50)) 
            if let date = schedule.statusDates[stdStatus] {
                let time = Utils.formatDate(date, format: "HH:mm")
                Text(time) 
                    .frame(width:180)
                    .font(.system(size: 50, design: .monospaced)) 
            } else {
                Text("00:00") 
                    .frame(width:180)
                    .font(.system(size: 50, design: .monospaced)) 
            }
            Text(schedule.name) 
                .frame(width:450, alignment: .leading)
                .font(.system(size:50)) 
        } 
    } 
}
