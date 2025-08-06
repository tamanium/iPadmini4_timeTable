import Foundation

// ステータス定義
enum Status: String, Codable, Hashable {
    
    case home         = "00" // 前日
    case coming       = "01" // 移動中
    case checkIn      = "02" // 受付
    case takingIn     = "03" // 楽器搬入
    case preparing    = "04" // 楽器準備
    case beforeTuning = "05" // チューニング室待機
    case tuning       = "06" // チューニング
    case waiting1     = "07" // 待機1
    case waiting2     = "08" // 待機2
    case performing   = "09" // 演奏本番
    case putAway      = "10" // 楽器片付け
    case takingOut    = "11" // 楽器搬出
    case done         = "12" // 予定完了
}


// スケジュール行
struct ScheduleRow: Identifiable, Codable {
    var id = UUID()    // ID
    let timeStr: String   // 時刻文字列
    let name: String   // 名前
    let nowStatus: Status // 現在のステータス
    let date: Date?     // 日時プロパティ
    let statusDates: [Status: Date]? // ステータスと日時のマッピング
}
