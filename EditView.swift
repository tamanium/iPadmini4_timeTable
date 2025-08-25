import SwiftUI

struct EditView: View {
    @ObservedObject var vm: ViewModel
    @Environment(\.dismiss) var dismiss
    @State private var editedRows: [EditableRow] = []
    @State private var isSwapped = false;
    
    struct EditableRow: Identifiable {
        let id: UUID
        var name: String
        var timeString: String // "HHmm"形式
    }
    
    var body: some View {
        VStack {
            Text("全体編集")
                .font(.title)
                .padding()
            Button("←→") {
                isSwapped.toggle()
            }
            ScrollView {
                Grid(alignment: .leading, horizontalSpacing: 32, verticalSpacing: 16) {
                    ForEach($editedRows) { $row in
                        GridRow {
                            if !isSwapped {
                                TextField("時刻", text: $row.timeString)
                                    .font(.system(size: 50, design: .monospaced)) 
                                    .keyboardType(.numberPad)
                                    .frame(width: 180)
                                    .textFieldStyle(.roundedBorder)
                                    // 入力制限
                                    .onChange(of: row.timeString) { newValue in
                                        row.timeString = String(newValue.prefix(4).filter{
                                            "0123456789".contains($0)
                                        })
                                    }
                                TextField("団体名", text: $row.name)
                                    .font(.system(size:50)) 
                                    .frame(width: 450)
                                    .textFieldStyle(.roundedBorder)
                            } else {
                                TextField("団体名", text: $row.name)
                                    .font(.system(size:50)) 
                                    .frame(width: 450)
                                    .textFieldStyle(.roundedBorder)
                                TextField("時刻", text: $row.timeString)
                                    .font(.system(size: 50, design: .monospaced)) 
                                    .keyboardType(.numberPad)
                                    .frame(width: 180)
                                    .textFieldStyle(.roundedBorder)
                                    // 入力制限
                                    .onChange(of: row.timeString) { newValue in
                                        row.timeString = String(newValue.prefix(4).filter{
                                            "0123456789".contains($0)
                                        })
                                    }
                            }
                        }
                    }
                }
                .padding()
            }
            Button("保存") {
                for row in editedRows {
                    if let date = Utils.parseHHmm(row.timeString) {
                        vm.updateSchedule(id: row.id, name: row.name, date: date)
                    } else {
                        print("無効な時刻: \(row.timeString)")
                    }
                }
                dismiss()
            }
            .padding()
        }
        .onAppear {
            // 完全に空の場合、空のスケジュールを追加する
            if vm.schedules.isEmpty {
                vm.addSchedule(status: .performing, name: "", date: Date())
            }
            editedRows = vm.schedules.map {
                EditableRow(
                    id: $0.id,
                    name: $0.name,
                    timeString: Utils.formatDate($0.statusDates?[.performing] ?? Date(),  format: "HHmm")
                )
            }
        }
    }
}
