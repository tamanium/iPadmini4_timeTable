import SwiftUI

struct EditSheet: View {
    @Binding var name: String
    @Binding var date: Date
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("編集")
                .font(.title)
                .padding()

            DatePicker("時刻", selection: $date, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .font(.system(size: 50, design: .monospaced))

            TextField("団体名", text: $name)
                .font(.system(size: 50))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            HStack {
                Button("保存") {
                    onSave()
                }
                .font(.title2)
                .padding()

                Button("キャンセル") {
                    onCancel()
                }
                .font(.title2)
                .padding()
            }
        }
        .padding()
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
