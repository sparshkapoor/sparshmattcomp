//
//  MainView.swift
//  sparshmattcomp
//
//  Created by Sparsh Kapoor on 9/4/24.
//

import SwiftUI

struct MainView: View {
    @State private var games: [String] = []
    @State private var newGame: String = ""
    @State private var isAddingGame = false
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Top bar with Edit and + buttons
                HStack {
                    if isEditing {
                        Button("Done") {
                            isEditing.toggle()
                            performHaptic()
                        }
                    } else {
                        Button("Edit") {
                            isEditing.toggle()
                            performHaptic()
                        }
                    }

                    Spacer()

                    // Add button to allow users to add a new game
                    Button(action: {
                        isAddingGame.toggle()
                        performHaptic()
                    }) {
                        Image(systemName: "plus")
                            .padding()
                    }
                }
                .padding()

                Divider()

                // Game list view with clickable buttons for each game
                List {
                    ForEach(games, id: \.self) { game in
                        NavigationLink(destination: GameDetailView(gameName: game)) {
                            Text(game)
                        }
                        .onTapGesture {
                            performHaptic()
                        }
                    }
                    .onDelete(perform: deleteGame) // Enable swipe to delete
                }
                .environment(\.editMode, .constant(isEditing ? EditMode.active : EditMode.inactive)) // Enable editing mode
                
                if isAddingGame {
                    VStack {
                        TextField("Enter game", text: $newGame)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()

                        Button("Add") {
                            if !newGame.isEmpty {
                                games.append(newGame)
                                saveGames()  // Save the updated games list
                                newGame = ""
                                isAddingGame = false
                                performHaptic()
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true) // Hide default navigation bar
            .onAppear {
                loadGames() // Load games when the view appears
            }
        }
    }
    
    // Function to delete a game from the list
    private func deleteGame(at offsets: IndexSet) {
        games.remove(atOffsets: offsets)
        saveGames()  // Save the updated games list after deletion
        performHaptic()
    }
    
    // Function to save games to UserDefaults
    private func saveGames() {
        UserDefaults.standard.set(games, forKey: "gamesList")
    }
    
    // Function to load games from UserDefaults
    private func loadGames() {
        if let savedGames = UserDefaults.standard.stringArray(forKey: "gamesList") {
            games = savedGames
        }
    }
    
    // Function to perform haptic feedback
    private func performHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

#Preview {
    MainView()
}




#Preview {
    MainView()
}
