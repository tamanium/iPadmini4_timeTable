import Foundation

// ステータス定義
enum Status: String, Codable, Hashable, CaseIterable, Equatable {
    /*
     case home         = "💤" // 前日
     case coming       = "🚌" // 移動中
     case checkIn      = "💁‍♀️" // 受付
     case takingIn     = "🚚" // 楽器搬入
     case preparing    = "🎁" // 楽器準備
     case beforeTuning = "🔑" // チューニング室待機
     case tuning       = "🎹" // チューニング
     case waiting1     = "⏳" // 待機1
     case waiting2     = "⌛️" // 待機2
     case performing   = "🎷" // 演奏本番
     case putAway      = "📦" // 楽器片付け
     case takingOut    = "🚛" // 楽器搬出
     case done         = "✔️" // 予定完了
     */
    case before = "💤"
    case performing   = "🎷" // 演奏本番
    case done         = "👍" // 予定完了
    // ordinal風プロパティ
    var order: Int {
        return Status.allCases.firstIndex(of: self)!
    }
    //次のStatusを返す
    var next: Status {
        let nextOrder = self.order+1
        if Status.allCases.count <= nextOrder {
            return .done
        }
        return Status.allCases[nextOrder]
    }
}
// Statusの最初の要素を出力する
extension Status {
    static var first: Status {
        return Status.allCases.first!
    }
}
// Statusの最後の要素を出力する
extension Status {
    static var last: Status {
        return Status.allCases.last!
    }
}
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

// スケジュールモデル
class ScheduleModel: ObservableObject {
    // スケジュール業
    @Published var scheduleRows: [ScheduleRow] = []
    // 前回時刻(分)
    private var prevMinute = ""
    // スクロール処理
    var scrollToPerforming: (() -> Void)? = nil
    
    func triggerScroll() {
        scrollToPerforming?()
    }
    // 行追加
    func addRow(name: String, date: Date) {
        let newRow = ScheduleRow(
            id: UUID(),
            name: name,
            date: date,
            nowStatus: .before,
            statusDates: nil
        )
        scheduleRows.append(newRow)
    }
    // 行更新
    func updateRow(id: UUID, name: String, date: Date) {
        if let index = scheduleRows.firstIndex(where: { $0.id == id }) {
            scheduleRows[index].name = name
            scheduleRows[index].date = date
        }
    }
    // 行削除
    func deleteRow(id: UUID) {
        scheduleRows.removeAll { $0.id == id }
    }
    // ステータス更新・最上位行ID取得
    func updateStatuses(currentTime: Date) -> UUID? {
        let nowMinute = Utils.formatDate(currentTime, format: "mm")
        guard nowMinute != prevMinute else { return nil }
        prevMinute = nowMinute
        var scrollID: UUID?
        
        for i in scheduleRows.indices {
            if scheduleRows[i].date <= currentTime {
                scheduleRows[i].nowStatus = .done
                scrollID = scheduleRows[i].id
            } else {
                // 直前の行を performing にする
                if i > 0 {
                    scheduleRows[i - 1].nowStatus = .performing
                    if i > 1 {
                        scrollID = scheduleRows[i - 2].id
                    } else {
                        scrollID = scheduleRows[i - 1].id
                    }
                } else {
                    scrollID = scheduleRows[0].id
                }
                break
            }
        }
        return scrollID
    }
}

// メソッド
struct Utils {
    // キャッシュ用の DateFormatter
    private static var cachedFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    // 日付を文字列に変換
    static func formatDate(_ date: Date, format: String) -> String {
        cachedFormatter.dateFormat = format
        return cachedFormatter.string(from: date)
    }
    
    // 文字列から日付に変換
    static func dateFromString(_ string: String, format: String) -> Date? {
        cachedFormatter.dateFormat = format
        return cachedFormatter.date(from: string)
    }
    // 透明度算出
    static func setOpacity(_ status: Status, base: Status) -> Double {
        if status.order < base.order {
            return 0.7
        } else if status.order == base.order {
            return 1
        } else {
            return 0.3
        }
    }
}
