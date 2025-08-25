import Foundation

/*
 // スケジュール行クラス
 class SchedlueRowClass: Identifiable, ObservableObject, Codable {
 var id = UUID()
 let name: String
 let timerStr: String
 @Published var nowStatus: Status
 let date: Date?
 let statusDates: [Status: Date]?
 
 // イニシャライザ
 init(timerStr: String, name: String) {
 self.name = name
 self.timerStr = timerStr
 self.nowStatus = Status.first
 self.date = nil
 self.statusDates = nil
 }
 }
 */
struct TotalSchedule {
    var statusTemplate: [Status]
    var schedules: [Schedule]
}
// スケジュール行構造体
struct Schedule: Identifiable, Codable {
    var id = UUID()    // ID
    var name: String   // 名前
    var status: Status // 現在のステータス
    var statusDates: [Status: Date] = [:]// ステータスと日時のマッピング
    var dates: [Date] = [] // 日付配列
    
    // イニシャライザ
    init(status: Status, name: String, date: Date) {
        self.id = UUID()
        self.name = name
        self.status = .first
        // とりあえず初期値
        self.statusDates = [status: date]
        self.dates = [date]
    }
    
    // 【Setter】ステータス
    mutating func setStatus(_ status: Status) {
        self.status = status
    }
    // ステータスを進める
    mutating func nextStatus() {
        self.status = self.status.next
    }
    // 表示透明度を算出数する
    func opacity(base: Status) -> Double {
        Utils.opacity(status, base: base)
    }
}
