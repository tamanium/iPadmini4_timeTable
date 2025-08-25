import Foundation
import Combine
import UIKit
import UniformTypeIdentifiers

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
            if schedules[index].statusDates[.performing] != nil {
                schedules[index].statusDates[.performing] = date
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
    // 全スケジュールのステータス更新・表示最上位行ID取得
    func updateAllStatus(stdStatus: Status, currentTime: Date) -> UUID? {
        // 全スケジュールのステータス更新
        for i in schedules.indices {
            //guard let statusDates = schedules[i].statusDates else { continue }
            let statusDates = schedules[i].statusDates
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
    func updateStatusSimpleNew(stdStatus: Status, nowTime: Date) -> UUID? {
        var topID: UUID?
        
        for i in schedules.indices {
            // 日付時刻を取得
            guard let dateTime = schedules[i].statusDates[stdStatus] else { continue }
            // 日付時刻をシステム日時と比較
            let result = Utils.compareHHmm(dateTime, nowTime)
            // 更新後のステータス宣言
            var newStatus: Status
            // すでに予定時刻を超えているor同じ場合
            if result != .orderedDescending {
                // 次のインデックスが存在する && すでに予定時刻を超えているor同じ
                if (i+1) < schedules.count,
                   let nextDateTime = schedules[i+1].statusDates[stdStatus],
                   Utils.compareHHmm(nextDateTime, nowTime) == .orderedDescending {
                    newStatus = stdStatus
                } else{
                    newStatus = .done
                }
            } else {
                // 予定時刻に達していない場合
                newStatus = .before
                if i==0 {
                    topID = schedules[i].id
                }
            }
            schedules[i].setStatus(newStatus)
            // スクロールする上で最上位行のidを取得
            if topID == nil, newStatus == stdStatus {
                topID = schedules[max(0, i-1)].id
            }
        }
        return topID
    }
    
    // URLからjsonを読み込む関数
    func loadSchedules(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            print("セキュリティスコープのアクセスに失敗しました")
            return
        }
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let loadedSchedules = try decoder.decode([Schedule].self, from: data)
            DispatchQueue.main.async {
                self.schedules = loadedSchedules
            }
        } catch {
            print("読み込み失敗: \(error)")
        }
    }
    
    // jsonをURLへ保存する関数
    func encodeSchedules() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        do {
            return try encoder.encode(schedules)
        } catch {
            print("エンコード失敗: \(error)")
            return nil
        }
    }
}

