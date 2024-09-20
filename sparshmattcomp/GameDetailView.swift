//
//  GameDetailView.swift
//  sparshmattcomp
//
//  Created by Sparsh Kapoor on 9/4/24.
//

import SwiftUI

struct GameDetailView: View {
    var gameName: String
    
    @State private var sparshWins: Int = 0
    @State private var mattWins: Int = 0
    @State private var weeklyStats: [WeekStat] = []
    
    var sparshWinPercent: Double {
        let totalWins = sparshWins + mattWins
        return totalWins > 0 ? Double(sparshWins) / Double(totalWins) * 100 : 0
    }
    
    var mattWinPercent: Double {
        let totalWins = sparshWins + mattWins
        return totalWins > 0 ? Double(mattWins) / Double(totalWins) * 100 : 0
    }
    
    var body: some View {
        VStack {
            Divider() // Top divider similar to MainView
            
            // Red and Blue buttons for wins
            HStack(spacing: 0) {
                Button(action: {
                    sparshWins += 1
                    performHaptic() // Haptic feedback on Red button
                    updateCurrentWeek()
                    saveScores()
                }) {
                    Text("Sparsh")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .font(.largeTitle)
                }
                
                Button(action: {
                    mattWins += 1
                    performHaptic() // Haptic feedback on Blue button
                    updateCurrentWeek()
                    saveScores()
                }) {
                    Text("Matt")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .font(.largeTitle)
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.5) // Covers 3/4 of the screen
            Divider()
            
            // Wins and Win Percentage Section
            HStack {
                // Sparsh's side
                VStack {
                    Text("Wins: \(sparshWins)")
                        .font(.caption) // Smaller font
                    Text("Win Percent:")
                        .font(.caption)
                    Text("\(sparshWinPercent, specifier: "%.2f")%")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40) // Smaller box height
                
                // Vertical Divider
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(.gray)
                    .alignmentGuide(.bottom) { d in d[.bottom] } // Align to meet the bottom divider
                
                // Matt's side
                VStack {
                    Text("Wins: \(mattWins)")
                        .font(.caption)
                    Text("Win Percent:")
                        .font(.caption)
                    Text("\(mattWinPercent, specifier: "%.2f")%")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40) // Smaller box height
            }
            .padding(.top, 4) // Adjust top padding for closer positioning to buttons
            
            Divider() // Bottom divider after the win section
            
            Spacer()
            
            // Weekly Leaderboards
            ScrollView {
                ForEach(weeklyStats, id: \.self) { week in
                    VStack {
                        // Weekly date range
                        Text(week.dateRange)
                            .font(.title)
                        
                        HStack {
                            VStack {
                                Text("Wins: \(week.sparshWins)")
                                    .font(.caption)
                                Text("Win Percent:")
                                    .font(.caption)
                                Text("\(week.sparshWinPercent, specifier: "%.2f")%")
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 40) // Smaller box height
                            
                            Rectangle()
                                .frame(width: 1)
                                .foregroundColor(.gray)
                            
                            VStack {
                                Text("Wins: \(week.mattWins)")
                                    .font(.caption)
                                Text("Win Percent:")
                                    .font(.caption)
                                Text("\(week.mattWinPercent, specifier: "%.2f")%")
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 40) // Smaller box height
                        }
                        Divider() // Divider between weeks
                    }
                    .padding(.top, 8)
                }
            }
            
            Spacer()
        }
        .navigationBarTitle(Text(gameName), displayMode: .inline) // Title for the detail view
        .onAppear {
            loadScores()  // Load scores when the view appears
            setupWeekUpdate() // Set up the automatic week update
            
            // Save scores when the app enters the background
            NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
                saveScores()
            }
        }
    }
    
    // Function to perform haptic feedback
    private func performHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // Function to save scores to UserDefaults
    private func saveScores() {
        UserDefaults.standard.set(sparshWins, forKey: "\(gameName)_sparshWins")
        UserDefaults.standard.set(mattWins, forKey: "\(gameName)_mattWins")
        WeekStat.saveWeeklyStats(weeklyStats, forGame: gameName)
    }
    
    // Function to load scores from UserDefaults
    private func loadScores() {
        sparshWins = UserDefaults.standard.integer(forKey: "\(gameName)_sparshWins")
        mattWins = UserDefaults.standard.integer(forKey: "\(gameName)_mattWins")
        weeklyStats = WeekStat.loadWeeklyStats(forGame: gameName)
        
        // If there are no weekly stats, add the current week
        if weeklyStats.isEmpty || !Calendar.current.isDateInThisWeek(weeklyStats.last!.startDate) {
            weeklyStats.append(WeekStat(startDate: Date(), endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!))
        }
    }
    
    // Function to update the current week with the latest scores
    private func updateCurrentWeek() {
        if let currentWeek = weeklyStats.last, Calendar.current.isDateInThisWeek(currentWeek.startDate) {
            weeklyStats[weeklyStats.count - 1].sparshWins = sparshWins
            weeklyStats[weeklyStats.count - 1].mattWins = mattWins
        }
        saveScores() // Save the updated weekly stats
    }
    
    // Function to set up weekly updates
    private func setupWeekUpdate() {
        // Set up a timer to create a new week every Monday at midnight
        Timer.scheduledTimer(withTimeInterval: 60 * 60 * 24, repeats: true) { timer in
            let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
            if currentWeek != Calendar.current.component(.weekOfYear, from: weeklyStats.last!.startDate) {
                let newWeek = WeekStat(startDate: Date(), endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!)
                weeklyStats.append(newWeek)
                saveScores() // Save the weekly stats
            }
        }
    }
}

// Model to track weekly stats
struct WeekStat: Hashable, Codable {
    let startDate: Date
    let endDate: Date
    var sparshWins: Int = 0
    var mattWins: Int = 0
    
    var sparshWinPercent: Double {
        let totalWins = sparshWins + mattWins
        return totalWins > 0 ? Double(sparshWins) / Double(totalWins) * 100 : 0
    }
    
    var mattWinPercent: Double {
        let totalWins = sparshWins + mattWins
        return totalWins > 0 ? Double(mattWins) / Double(totalWins) * 100 : 0
    }
    
    // Computed property to show date range
    var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/dd"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    // Load weekly stats from UserDefaults
    static func loadWeeklyStats(forGame gameName: String) -> [WeekStat] {
        if let data = UserDefaults.standard.data(forKey: "\(gameName)_weeklyStats"),
           let stats = try? JSONDecoder().decode([WeekStat].self, from: data) {
            return stats
        }
        return []
    }
    
    // Save weekly stats to UserDefaults
    static func saveWeeklyStats(_ stats: [WeekStat], forGame gameName: String) {
        if let data = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(data, forKey: "\(gameName)_weeklyStats")
        }
    }
}

// Helper function to check if a date is in the current week
extension Calendar {
    func isDateInThisWeek(_ date: Date) -> Bool {
        let today = Date()
        guard let startOfWeek = self.date(from: self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)),
              let endOfWeek = self.date(byAdding: .day, value: 7, to: startOfWeek) else {
            return false
        }
        return date >= startOfWeek && date < endOfWeek
    }
}

#Preview {
    GameDetailView(gameName: "Mario Kart")
}
