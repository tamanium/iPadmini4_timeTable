import Foundation
import Combine

// スケジュールモデル
class ScheduleModel: ObservableObject {
    @Published var schedules: [Schedule] = []
    @Published var nowTime = Date()
    private var cancellable: AnyCancellable?
    // 前回時刻(分)
    private var prevMinute = ""
    // スクロール処理
    var scrollToPerforming: (() -> Void)? = nil
    init() {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink{
                [weak self] time in
                self?.nowTime = time
            }
    }
    func triggerScroll() {
        scrollToPerforming?()
    }
    // 行追加
    func addRow(name: String, date: Date) {
        let newSchedule = Schedule(
            id: UUID(),
            name: name,
            date: date,
            nowStatus: .before,
            statusDates: nil
        )
        schedules.append(newSchedule)
    }
    // 行更新
    func updateSchedule(id: UUID, name: String, date: Date) {
        if let index = schedules.firstIndex(where: { $0.id == id }) {
            schedules[index].name = name
            schedules[index].date = date
        }
    }
    // 行削除
    func deleteSchedule(id: UUID) {
        schedules.removeAll { $0.id == id }
    }
    // 引数ステータスの行IDを取得
    func getIdByStatus(_ status: Status) -> UUID? {
        schedules.first(where: { $0.nowStatus == status })?.id
    }
    // 引数ステータスを基準とする最上位行IDを取得
    func getTopIdByStatus(_ status: Status) -> UUID? {
        guard let i = schedules.firstIndex(where: { $0.nowStatus == status }) else {
            return nil
        }
        let topIndex = max(0, i - (i > 1 ? 2 : 1))
        return schedules[topIndex].id
    }
    // ステータス更新・最上位行ID取得
    func updateStatuses(currentTime: Date) -> UUID? {
        let nowMinute = Utils.formatDate(currentTime, format: "mm")
        guard nowMinute != prevMinute else { return nil }
        prevMinute = nowMinute
        var scrollID: UUID?
        
        for i in schedules.indices {
            // 経過した行をdoneにする
            if schedules[i].date <= currentTime {
                schedules[i].setStatus(.done)
                scrollID = schedules[i].id
            } else {
                // 直前の行を performing にする
                if i > 0 {
                    schedules[i-1].setStatus(.performing)
                } 
                // 最上位行IDを取得
                let topIndex = max(0, i - (i > 1 ? 2 : 1))
                scrollID = schedules[topIndex].id
                break
            }
        }
        return scrollID
    }
}
