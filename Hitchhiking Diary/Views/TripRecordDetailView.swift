import SwiftUI
import MapKit

struct TripRecordDetailView: View {
    @Bindable var tripRecord: TripRecord

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Map() {
                    Marker("I am here!", coordinate: tripRecord.location)
                }
                .frame(height: 200)
                .cornerRadius(10)
                .padding()
                
                Text("Created on \(tripRecord.createdAt, formatter: itemFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let content = tripRecord.content {
                    Text(content)
                        .font(.body)
                        .padding(.bottom, 10)
                }
                
                if !tripRecord.photos.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tripRecord.photos, id: \.id) { photo in
                                Image(uiImage: UIImage(data: photo.content) ?? UIImage())
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }

            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: TripRecordFormView(tripRecord: tripRecord, trip: tripRecord.trip!)) {
                    Image(systemName: "pencil")
                }
            }
        }
        .navigationTitle(tripRecord.type.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    do {
        let previewer = try Previewer()

        return TripRecordDetailView(tripRecord: previewer.record1)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
