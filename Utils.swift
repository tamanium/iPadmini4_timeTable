import SwoftUI

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
