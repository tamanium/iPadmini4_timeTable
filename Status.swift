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
