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
