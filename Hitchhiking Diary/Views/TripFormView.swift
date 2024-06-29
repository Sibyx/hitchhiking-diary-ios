import SwiftUI
import SwiftData

struct TripFormView: View {
    @Environment(\.database) private var database
    @Environment(\.dismiss) private var dismiss
    
    @State var trip: Trip?
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var status: TripStatus = .draft
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    Picker("Status", selection: $status) {
                        ForEach(TripStatus.allCases, id: \.self) { type in
                            HStack {
                                type.icon()
                                Text(type.title())
                            }.tag(type)
                        }
                    }
                }
                
                Section(header: Text("Description")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 200, maxHeight: .infinity)
                }
            }
            .navigationTitle(trip?.title ?? "New Trip" )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: {
                            Task {
                                if let trip = trip {
                                    trip.title = title
                                    trip.content = content
                                    trip.status = status
                                    trip.updatedAt = Date()
                                    await database.insert(trip)
                                } else {
                                    let trip = Trip(title: title, content: content, status: status)
                                    await database.insert(trip)
                                }
                                dismiss()
                            }
                    }) {Text("Save")}
                }
            }
            .onAppear {
                if let trip = trip {
                    title = trip.title
                    content = trip.content
                    status = trip.status
                }
            }
        }
    }
}
