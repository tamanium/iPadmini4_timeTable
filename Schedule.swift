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

// スケジュール行構造体
struct ScheduleRow: Identifiable, Codable {
    var id = UUID()    // ID
    var name: String   // 名前
    var date: Date     // 日時プロパティ
    var nowStatus: Status // 現在のステータス
    var statusDates: [Status: Date]? // ステータスと日時のマッピング
    
    // 【Setter】ステータス
    mutating func setStatus(_ status: Status) {
        self.nowStatus = status
    }
    // ステータスを進める
    mutating func nextStatus() {
        self.nowStatus = nowStatus.next
    }
}
