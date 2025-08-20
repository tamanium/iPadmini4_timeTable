import Foundation

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
    static func opacity(_ status: Status, base: Status) -> Double {
        if status.order < base.order {
            return 0.7
        } else if status.order == base.order {
            return 1
        } else {
            return 0.3
        }
    }
    // 時分比較
    static func compareHHmm(_ date1: Date, _ date2: Date) -> ComparisonResult {
        let calendar = Calendar.current
        let comp1 = calendar.dateComponents([.hour, .minute], from: date1)
        let comp2 = calendar.dateComponents([.hour, .minute], from: date2)
        
        if let hour1 = comp1.hour, let min1 = comp1.minute, let hour2 = comp2.hour, let min2 = comp2.minute {
            if hour1 < hour2 || (hour1 == hour2 && min1 < min2) {
                // 左 < 右 の場合
                return .orderedAscending
            } else if hour1 == hour2 && min1 == min2 {
                // 左 == 右の場合
                return .orderedSame
            } else {
                // 左 > 右 の場合
                return .orderedDescending
            }
        }
        // 比較不可の場合は同じとする
        return .orderedSame
    }
    // カウント値から時分を算出（デバッグ用）
    static func parseHHmm(_ string: String) -> Date? {
        guard string.count == 4,
              let hour = Int(string.prefix(2)),
              let minute = Int(string.suffix(2)),
              (0..<24).contains(hour),
              (0..<60).contains(minute)
        else { return nil }
        
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())
    }
}
