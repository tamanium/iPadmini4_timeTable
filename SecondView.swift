import SwiftUI
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
