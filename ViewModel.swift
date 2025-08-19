import Foundation
import Combine

// スケジュールモデル
class ViewModel: ObservableObject {
    @Published var schedules: [Schedule] = []
    @Published var nowTime = Date()
    private var cancellable: AnyCancellable?
    // 前回時刻(分)
    private var prevMinute = ""
    
    init() {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink{
                [weak self] time in self?.nowTime = time
            }
    }
    
    func initSchedules(){
        let calendar = Calendar.current
        let nowDate = Date()
        let currentHour = calendar.component(.hour, from: nowDate)
        
        schedules = ((currentHour)*60..<(currentHour+1)*60).map { minute in
            let nameString = "団体\(minute - currentHour*60)"
            let _hour = minute/60
            let _minute = minute%60
            let date = calendar.date(bySettingHour: _hour, minute: _minute, second: 0, of: nowDate)!
            
            return Schedule(
                status: .performing,
                name: nameString,
                date:date
            )
        }
    }
    
    // 行追加
    func addSchedule(status: Status, name: String, date: Date) {
        let newSchedule = Schedule(
            status: status,
            name: name,
            date: date
        )
        schedules.append(newSchedule)
    }
    // 行追加
    func addSchedule(name: String, date: Date) {
        let newSchedule = Schedule(
            status: .performing,
            name: name,
            date: date
        )
        schedules.append(newSchedule)
    }
    // 行更新
    func updateSchedule(id: UUID, name: String, date: Date) {
        if let index = schedules.firstIndex(where: { $0.id == id }) {
            schedules[index].name = name
            //schedules[index].date = date
            if schedules[index].statusDates?[.performing] != nil {
                schedules[index].statusDates?[.performing] = date
            }
        }
    }
    // 行削除
    func deleteSchedule(id: UUID) {
        schedules.removeAll { $0.id == id }
    }
    // 引数ステータスの行IDを取得
    func getIdByStatus(_ status: Status) -> UUID? {
        schedules.first(where: { $0.status == status })?.id
    }
    /*
     // 引数ステータスを基準とする最上位行IDを取得
     func getTopIdByStatus(_ status: Status) -> UUID? {
     guard let i = schedules.firstIndex(where: { $0.nowStatus == status }) else {
     return nil
     }
     let topIndex = max(0, i - (i > 1 ? 2 : 1))
     return schedules[topIndex].id
     }*/
    /*
    // スケジュールのソート（基準ステータス時刻昇順）
    func sortSchedules(stdStatus: Status) {
        let sortedSchedules = schedules.sorted {$0.statusDates?[stdStatus]? < $1.statusDates?[stdStatus]? }
        schedules = sortedSchedules
    }*/
    // 全スケジュールのステータス更新・表示最上位行ID取得
    func updateAllStatus(stdStatus: Status, currentTime: Date) -> UUID? {
        // 全スケジュールのステータス更新
        for i in schedules.indices {
            guard let statusDates = schedules[i].statusDates else { continue }
            // 時刻順にソート
            let sortedStatusDates = statusDates.sorted { $0.value < $1.value }
            var nowStatus = Status.before
            for (status, date) in sortedStatusDates {
                // 予定時刻に達していない場合、処理終了
                if date > currentTime { break }
                // 予定時刻を超えている場合、ステータス取得
                nowStatus = status
            }
            // 現在ステータスを更新
            schedules[i].status = nowStatus
        }
        // 表示最上位行ID取得
        var scrollID: UUID?
        for i in schedules.indices {
            if schedules[i].status == stdStatus {
                scrollID = schedules[max(0, i-1)].id
                break
            }
        }
        return scrollID
    }
    
    // ステータス更新・最上位行ID取得
    func updateStatusesNew(stdStatus: Status, currentTime: Date) -> UUID? {
        var scrollID: UUID?
        
        var isInit = true
        
        for i in schedules.indices {
            guard let scheduleDate = schedules[i].statusDates?[stdStatus] else { continue }
            
            if scheduleDate <= currentTime {
                // もう予定時刻を超えている場合
                // ステータス：済
                schedules[i].setStatus(.done)
            } else {
                // まだ予定時刻を超えていない場合
                // ステータス：未
                schedules[i].setStatus(.before)
                //　初めての予定時刻を超えていない行だった場合
                if isInit {
                    // フラグ下ろす
                    isInit = false
                    if i == 0 {
                        scrollID = schedules[0].id
                        continue
                    } else {
                        // ひとつ前の行の日時を取得
                        let yetDate = schedules[i-1].statusDates?[stdStatus]
                        for j in stride(from: i-1, through: 0, by: -1) {
                            // 日付取得
                            let tmpDate = schedules[j].statusDates?[stdStatus]
                            // 日時が異なる場合、処理終了
                            if tmpDate != yetDate { break }
                            // ステータス変更
                            schedules[j].setStatus(stdStatus)
                            scrollID = schedules[max(0, j-1)].id
                        }
                    }
                }
            }
        }
        return scrollID
    }
    
    // ステータス更新・最上位行ID取得
    func updateStatuses(stdStatus: Status, currentTime: Date) -> UUID? {
        var scrollID: UUID?
        
        for i in schedules.indices {
            guard let date = schedules[i].statusDates?[stdStatus] else { continue }
            // 経過した行をdoneにする
            if date <= currentTime {
                schedules[i].setStatus(.done)
                scrollID = schedules[i].id
            } else {
                // 直前の行を performing にする
                if i > 0 {
                    schedules[i-1].setStatus(stdStatus)
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
