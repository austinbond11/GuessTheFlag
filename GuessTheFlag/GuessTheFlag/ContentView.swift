//  ContentView.swift
//  GuessTheFlag
//
//  Created by Austin Bond on 6/5/24.

import SwiftUI

struct ContentView: View {
    // `allCountries` contains the full list of countries used in the game.
    private var allCountries: [String] = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"]
    
    // State variables to manage the game logic
    @State private var usedCountries: [String] = []                      // Keeps track of the flags that have been used in the current game
    @State private var currentCountries: [String] = []                   // Holds the countries for the current round
    @State private var correctAnswer = 0                                 // Index of the correct answer in `currentCountries`
    @State private var selectedAnswer: Int? = nil                        // Index of the selected answer
    @State private var showingScore = false                              // Controls the display of the score alert
    @State private var scoreTitle = ""                                   // The title of the score alert
    @State private var scoreAmount = 0                                   // The current score
    @State private var round = 1                                         // The current round number
    @State private var showingFinalScore = false                         // Controls the display of the final score alert
    @State private var animateFlags = [false, false, false]              // Controls the animation state for each flag
    @State private var streak = 0                                        // The current streak of correct answers
    @State private var maxStreak = 0                                     // The maximum streak reached during the game
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(stops: [
                .init(color: Color(red: 0.91, green: 0.29, blue: 0.50), location: 0.0),  // From pink
                .init(color: Color(red: 0.91, green: 0.29, blue: 0.50), location: 0.33),
                .init(color: Color(red: 0.40, green: 0.15, blue: 0.58), location: 0.33), // To purple
                .init(color: Color(red: 0.40, green: 0.15, blue: 0.58), location: 0.66),
                .init(color: Color(red: 0.00, green: 0.45, blue: 0.74), location: 0.66), // To blue
                .init(color: Color(red: 0.00, green: 0.45, blue: 0.74), location: 1.0)
            ]),
                           startPoint: .top,
                           endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Game title
                Text("Guess the Flag")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                
                // Container for the main game content
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of:")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        
                        // Display the name of the country the player should guess
                        Text(currentCountries.isEmpty ? "" : currentCountries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    // Display the flags for the current round
                    ForEach(0..<3) { number in
                        if number < currentCountries.count {
                            Button {
                                flagTapped(number)
                            } label: {
                                FlagImage(name: currentCountries[number])
                            }
                            .opacity(animateFlags[number] ? 1 : 0)
                            .scaleEffect(animateFlags[number] ? 1 : 0.5)
                            .onAppear {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(number) * 0.2)) {
                                    animateFlags[number] = true
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer()
                Spacer()
                
                // Display the current round number
                Text("Round: \(round) / 8")
                    .foregroundStyle(.white)
                    .font(.title.bold())
                
                // Display the current score
                Text("Score: \(scoreAmount)")
                    .foregroundStyle(.white)
                    .font(.title.bold())
                
                // Display the current streak and max streak
                Text("Streak: \(streak)").foregroundStyle(.white).font(.title.bold())
                Text("Max Streak: \(maxStreak)").foregroundStyle(.white).font(.title.bold())
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            startGame()
        }
        // Show an alert when the player's guess result is ready
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: nextRound)
        } message: {
            Text("Your score is \(scoreAmount)")
        }
        // Show an alert when the player finishes all rounds
        .alert("Your final score", isPresented: $showingFinalScore) {
            Button("Restart", action: restart)
        } message: {
            Text("Your final score is \(scoreAmount)\nHighest Streak: \(maxStreak)")
        }
    }
    
    // Called when a flag is tapped
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            // If the selected flag is correct
            scoreTitle = "Correct"
            scoreAmount += 10
            streak += 1
            if streak > maxStreak {
                maxStreak = streak
            }
        } else {
            // If the selected flag is incorrect
            scoreTitle = "Wrong, that's the \(currentCountries[number]) flag"
            streak = 0
        }
        showingScore = true
    }
    
    // Sets up the next question
    func askQuestion() {
        // Filter out used countries from the available pool
        var availableCountries = allCountries.filter { !usedCountries.contains($0) }
        
        // If less than 3 available countries, reset the used countries list
        if availableCountries.count < 3 {
            usedCountries.removeAll()
            availableCountries = allCountries
        }
        
        // Shuffle and pick the next set of countries
        availableCountries.shuffle()
        currentCountries = Array(availableCountries.prefix(3))
        correctAnswer = Int.random(in: 0..<currentCountries.count)
        
        // Add these countries to the used list
        usedCountries.append(contentsOf: currentCountries)
        
        // Reset animation state
        animateFlags = [false, false, false]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for i in 0..<3 {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(i) * 0.2)) {
                    animateFlags[i] = true
                }
            }
        }
    }
    
    // Sets up the next round
    func nextRound() {
        round += 1
        if round == 9 {
            // Show final score alert if game is over
            showingFinalScore = true
        } else {
            // Otherwise, set up the next question
            askQuestion()
        }
    }
    
    // Resets the game
    func restart() {
        round = 1
        scoreAmount = 0
        streak = 0
        maxStreak = 0
        usedCountries.removeAll()
        askQuestion()
    }
    
    // Starts a new game
    func startGame() {
        usedCountries.removeAll()
        askQuestion()
    }
}

// SwiftUI Preview
#Preview {
    ContentView()
}
