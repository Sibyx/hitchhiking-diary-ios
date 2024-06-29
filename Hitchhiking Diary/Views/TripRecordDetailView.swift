import SwiftUI
import MapKit

struct TripRecordDetailView: View {
    @Bindable var tripRecord: TripRecord

    @State private var selectedPhoto: UIImage?
    @State private var isPhotoPresented = false
    @State private var isLoading = false
    
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
                
                if !tripRecord.photos.filter({$0.deletedAt == nil}).isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tripRecord.photos.filter({$0.deletedAt == nil}), id: \.id) { photo in
                                let img = UIImage(data: photo.content)
                                Image(uiImage: img!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .onTapGesture {
                                        isLoading = true
                                        selectedPhoto = img
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            isPhotoPresented = true
                                            isLoading = false
                                        }
                                    }
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
        .navigationTitle(tripRecord.type.title())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isPhotoPresented) {
            if let selectedPhoto = selectedPhoto {
                PhotoViewer(selectedPhoto: selectedPhoto)
            }
        }
        .overlay(
            Group {
                if isLoading {
                    LoaderView()
                }
            }
        )
    }
}


private struct PhotoViewer: View {
    var selectedPhoto: UIImage
    
    var body: some View {
        Image(uiImage: selectedPhoto)
            .resizable()
            .scaledToFit()
            .ignoresSafeArea()
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
