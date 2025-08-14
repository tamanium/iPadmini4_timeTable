import SwiftUI

struct EditView: View {
    @ObservedObject var model: ScheduleModel
    @Environment(\.dismiss) var dismiss
    @State private var editedRows: [EditableRow] = []
    
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
            ScrollView {
                Grid(alignment: .leading, horizontalSpacing: 32, verticalSpacing: 16) {
                    ForEach($editedRows) { $row in
                        GridRow {
                            TextField("時刻", text: $row.timeString)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .textFieldStyle(.roundedBorder)
                            
                            TextField("団体名", text: $row.name)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }
                .padding()
            }
            
            Button("保存") {
                for row in editedRows {
                    if let date = Utils.parseHHmm(row.timeString) {
                        model.updateRow(id: row.id, name: row.name, date: date)
                    }
                }
                dismiss()
            }
            .padding()
        }
        .onAppear {
            editedRows = model.scheduleRows.map {
                EditableRow(
                    id: $0.id,
                    name: $0.name,
                    timeString: Utils.formatDate($0.date, format: "HHmm")
                )
            }
        }
    }
}
