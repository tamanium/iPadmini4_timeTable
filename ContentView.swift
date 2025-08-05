import SwiftUI

struct ContentView: View {
    // 時間
    @State var hour = ""
    // 分
    @State var minute = ""
    // 現在時刻
    @State var nowTime = Date()
    // 表示形式
    private let dateFormatterHour = DateFormatter()
    private let dateFormatterMinute = DateFormatter()
    init(){
        dateFormatterHour.dateFormat = "HH"
        dateFormatterHour.locale = Locale(identifier: "en_jp")
        dateFormatterMinute.dateFormat = "mm"
        dateFormatterMinute.locale = Locale(identifier: "en_jp")
    }
    var body: some View {
        // タテ配置
        VStack {
            // ヨコ配置
            HStack{
                // 年
                Text(hour.isEmpty ? "\(dateFormatterHour.string(from: nowTime))" : hour)
                    .onAppear{
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ _ in
                            self.nowTime = Date()
                            hour = "\(dateFormatterHour.string(from: nowTime))"
                        }
                    }
                    .font(
                        .system(
                            size: 30,
                            weight: .light,
                            design: .rounded
                        )
                    )
                Text(":")
                    .font(
                        .system(
                            size: 30,
                            weight: .light,
                            design: .rounded
                        )
                    )
                // 年
                Text(minute.isEmpty ? "\(dateFormatterHour.string(from: nowTime))" : minute)
                    .onAppear{
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ _ in
                            self.nowTime = Date()
                            minute = "\(dateFormatterHour.string(from: nowTime))"
                        }
                    }
                    .font(
                        .system(
                            size: 30,
                            weight: .light,
                            design: .rounded
                        )
                    )
            }
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        
    }
}