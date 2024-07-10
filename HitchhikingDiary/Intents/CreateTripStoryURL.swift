import AppIntents

struct CreateTripStoryURL: AppIntent {
    static var title = LocalizedStringResource("Create Trip Story URL")
    
    @Parameter(title: "Trip")
    var trip: TripIntentItem
    
    func perform() async throws -> some IntentResult & ReturnsValue<String?> {
        let url = "https://explore.hitchhikingdiary.app/images/v1/story/\(trip.id.uuidString)"
        
        return .result(value: url)
    }
}
