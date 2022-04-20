import Combine
import SwiftUI

struct ContentView: View {
    @State var exampleViewIsPresented = false

    var body: some View {
        Button("Present ExampleView Sheet") {
            exampleViewIsPresented = true
        }
        .sheet(isPresented: $exampleViewIsPresented) {
            NavigationView {
                ExampleView()
            }
        }
        .navigationTitle(Text("ContentView"))
    }
}
