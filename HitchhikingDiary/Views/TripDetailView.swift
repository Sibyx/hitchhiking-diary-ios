import SwiftUI
import SwiftData
import MapKit

struct TripDetailView: View {
    @Environment(\.database) private var database
    @Bindable var trip: Trip
    @EnvironmentObject var appState: AppState
    
    var groupedRecords: [(key: Date, value: [TripRecord])] {
        let sortedRecords = trip.records.filter{item in item.deletedAt == nil}.sorted { $0.happenedAt > $1.happenedAt }
        let grouped = Dictionary(grouping: sortedRecords) { (record: TripRecord) -> Date in
            let components = Calendar.current.dateComponents([.year, .month, .day], from: record.happenedAt)
            return Calendar.current.date(from: components)!
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                trip.status.icon()
                    .font(.caption)
                Text(trip.status.title().capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Image(systemName: "safari").font(.caption)
                Text("explore.hitchhikingdiary.app")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        if let url = URL(string: "\(appState.apiBaseUrl)/trips/\(trip.id)") {
                            UIApplication.shared.open(url)
                        }
                    }
            }
            .padding()
            
            Text(trip.content)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Map() {
                ForEach(trip.records.filter{item in item.deletedAt == nil}, id:\.self) {
                    record in
                    Annotation(record.type.title(), coordinate: record.location) {
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
                                    Text(tripRecord.type.title())
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    Task {
                                        tripRecord.updatedAt = Date()
                                        tripRecord.deletedAt = Date()
                                        await database.insert(tripRecord)
                                        try! await database.save()
                                    }
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
}
