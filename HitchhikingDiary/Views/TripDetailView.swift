import SwiftUI
import Combine
import MapKit

struct TripDetailView: View {
    @Environment(\.database) private var database
    @Bindable var trip: Trip
    @EnvironmentObject var appState: AppState
    
    @State private var showingDatePicker = false
    @State private var showingShareSheet = false
    @State private var selectedDate = Date()
    @State private var shareImage: UIImage? = nil
    @State private var cancellable: AnyCancellable?
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var groupedRecords: [(key: Date, value: [TripRecord])] {
        let sortedRecords = trip.records.filter { $0.deletedAt == nil }.sorted { $0.happenedAt > $1.happenedAt }
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
                ForEach(trip.records.filter { $0.deletedAt == nil }, id: \.self) { record in
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
                Button(action: shareTrip) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: TripRecordFormView(tripRecord: nil, trip: trip)) {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationTitle(trip.title)
        .sheet(isPresented: $showingShareSheet, content: {
            if let shareImage = shareImage {
                ShareSheet(activityItems: [shareImage])
            }
        })
        .sheet(isPresented: $showingDatePicker) {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                Button("Share") {
                    showingDatePicker = false
                    fetchShareImage()
                }
                .padding()
            }
            .presentationDetents([.fraction(0.6)])
        }
        .overlay {
            if isLoading {
                LoaderView()
            }
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func shareTrip() {
        if trip.status == .inProgress {
            showingDatePicker = true
        } else {
            fetchShareImage()
        }
    }
    
    private func fetchShareImage() {
        isLoading = true
        let dateString = trip.status == .inProgress ? selectedDate.string(format: "yyyy-MM-dd") : nil
        let urlString = "\(appState.apiBaseUrl)/images/v1/story/\(trip.id)\(dateString != nil ? "?day=\(dateString!)" : "")"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            showErrorAlert = true
            errorMessage = "Invalid URL."
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    self.isLoading = false
                    self.showErrorAlert = true
                    self.errorMessage = "Failed to load image."
                }
            } receiveValue: { image in
                self.isLoading = false
                if let image = image {
                    self.shareImage = image
                    self.showingShareSheet = true
                } else {
                    self.showErrorAlert = true
                    self.errorMessage = "Failed to load image."
                }
            }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.excludedActivityTypes = [.assignToContact, .addToReadingList]
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
