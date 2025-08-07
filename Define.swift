import Foundation

// ステータス定義
enum Status: String, Codable, Hashable, CaseIterable {
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
    case done         = "✔️" // 予定完了
    // ordinal風プロパティ
    var order: Int {
        return Status.allCases.firstIndex(of: self)!
    }
}


// スケジュール行
struct ScheduleRow: Identifiable, Codable {
    var id = UUID()    // ID
    let timeStr: String   // 時刻文字列
    let name: String   // 名前
    var nowStatus: Status // 現在のステータス
    let date: Date?     // 日時プロパティ
    let statusDates: [Status: Date]? // ステータスと日時のマッピング
}

// メソッド
struct Utils {
    // 日付型の日付データを引数フォーマットで文字列に変換する
    static func formatDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    // 文字列から日付データに変換する
    static func dateFromString(_ string: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.date(from: string)
    }
}
