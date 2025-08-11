import SwiftUI
struct SecondView: View {
    var body: some View { 
        VStack { 
            Text("別画面") .font(.title) .padding() 
            Spacer() 
        } 
        .navigationTitle("別画面タイトル") 
        .background(Color.black) 
    } 
}