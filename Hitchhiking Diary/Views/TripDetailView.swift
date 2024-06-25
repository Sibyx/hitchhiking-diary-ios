import SwiftUI
import SwiftData
import MapKit

struct TripDetailView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Bindable var trip: Trip
    
    var groupedRecords: [(key: Date, value: [TripRecord])] {
        let sortedRecords = trip.records.sorted { $0.createdAt > $1.createdAt }
        let grouped = Dictionary(grouping: sortedRecords) { (record: TripRecord) -> Date in
            let components = Calendar.current.dateComponents([.year, .month, .day], from: record.createdAt)
            return Calendar.current.date(from: components)!
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        VStack {
            HStack {
                trip.status.icon()
                    .font(.largeTitle)
                Text(trip.status.rawValue.capitalized)
                    .font(.title)
            }
            .padding(.horizontal)
            
            Text(trip.content)
                .padding()
            
            Map() {
                ForEach(trip.records, id:\.self) {
                    record in
                    Annotation(record.type.rawValue, coordinate: record.location) {
                        record.type.icon()
                    }
                }
            }
            .frame(height: 200)
            .cornerRadius(10)
            .padding()
            
            List {
                ForEach(groupedRecords, id: \.key) { (date, records) in
                    Section(header: Text(date, style: .date)) {
                        ForEach(records) { tripRecord in
                            NavigationLink(destination: TripRecordDetailView(tripRecord: tripRecord)) {
                                HStack {
                                    tripRecord.type.icon()
                                    Text(tripRecord.type.rawValue)
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    deleteTripRecord(tripRecord)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: TripFormView(trip: trip)) {
                    Image(systemName: "pencil")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: TripRecordFormView(tripRecord: nil, trip: trip)) {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationTitle(trip.title)
    }

    private func deleteTripRecord(_ tripRecord: TripRecord) {
        modelContext.delete(tripRecord)
    }
}

#Preview {
    do {
        let previewer = try Previewer()

        return TripDetailView(trip: previewer.trip)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
