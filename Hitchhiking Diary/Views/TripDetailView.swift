import SwiftUI
import MapKit

struct TripDetailView: View {
    var trip: Trip
    @StateObject private var viewModel = TripDetailViewModel()

    var body: some View {
        VStack {
            MultiCoordinateMapView(tripRecords: viewModel.tripRecords)
                .frame(height: 300)
                .cornerRadius(10)
                .padding()

            List {
                ForEach(groupedRecords.keys.sorted(by: >), id: \.self) { date in
                    Section(header: Text(dateFormatter.string(from: date))) {
                        ForEach(groupedRecords[date] ?? []) { record in
                            NavigationLink(destination: TripRecordDetailView(tripRecord: record)) {
                                HStack {
                                    record.type.icon()
                                    VStack(alignment: .leading) {
                                        Text(record.type.rawValue)
                                            .font(.headline)
                                        Text("Created at: \(record.createdAt, formatter: dateFormatter)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(trip.name)
            .navigationBarItems(trailing: Button(action: {
                viewModel.showingNewTripRecordView = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $viewModel.showingNewTripRecordView) {
                TripRecordFormView(trip: trip, viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.fetchTripRecords(for: trip)
        }
    }

    private var groupedRecords: [Date: [TripRecord]] {
        Dictionary(grouping: viewModel.tripRecords, by: { Calendar.current.startOfDay(for: $0.createdAt) })
    }
}

struct TripDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let persistence = Persistence()
        persistence.preloadData()
        
        let sampleTrip = persistence.trips.first!
        let tripRecords = persistence.tripRecords[sampleTrip.id] ?? []

        let viewModel = TripDetailViewModel()
        viewModel.tripRecords = tripRecords
        
        return NavigationView {
            TripDetailView(trip: sampleTrip)
                .environmentObject(viewModel)
        }
    }
}
