import SwiftUI

struct ScheduleEditView: View {
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


struct SecondView: View {
    @ObservedObject var model: ScheduleModel
    var row: ScheduleRow
    @State private var name: String
    @State private var date: Date
    
    init(model: ScheduleModel, row: ScheduleRow) {
        self.model = model
        self.row = row
        _name = State(initialValue: row.name)
        _date = State(initialValue: row.date)
    }
    
    var body: some View { 
        Form {
            TextField("団体名", text: $name)
            DatePicker("演奏時刻", selection: $date, displayedComponents: [.hourAndMinute])
            Button("保存") {
                model.updateRow(id: row.id, name: name, date: date)
            }
        }
        .navigationTitle("編集")
        /*
         VStack { 
         Text("別画面") .font(.title) .padding() 
         Spacer() 
         } 
         .navigationTitle("別画面タイトル") 
         .background(Color.black)
         */
    } 
}
