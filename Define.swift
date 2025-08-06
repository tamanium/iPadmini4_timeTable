import Foundation

// ステータス定義
enum Status: String {
    case home         = "前日"
    case coming       = "移動中"
    case checkIn      = "受付"
    case takingIn     = "楽器搬入"
    case preparing    = "楽器出し"
    case beforeTuning = "チューニング待ち"
    case tuning       = "チューニング"
    case waiting1     = "待機1"
    case waiting2     = "待機2"
    case performing   = "演奏"
    case putAway      = "楽器片付け"
    case takingOut    = "楽器搬出"
    case done         = "完了"
}

// スケジュール行
struct ScheduleRow: Identifiable, Codable {
    let id = UUID()    // ID
    let time: String   // 時刻
    let name: String   // 名前
    let status: Status // ステータス
}
