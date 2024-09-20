//
//  SplashView.swift
//  sparshmattcomp
//
//  Created by Sparsh Kapoor on 9/4/24.
//

import SwiftUI

struct SplashView: View {
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var fadeOut = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea() // Background color
            
            VStack {
                if showTitle {
                    Text("Sparsh vs. Matt")
                        .font(.custom("SFProRounded-Bold", size: 36)) // Custom font
                        .foregroundColor(.white)
                        .bold() // Make it bold
                        .opacity(fadeOut ? 0 : 1) // Fade out when needed
                        .transition(.opacity) // Fade transition
                }
                if showSubtitle {
                    Text("Developed by Sparsh")
                        .font(.custom("SFProRounded-Bold", size: 24)) // Custom font for subtitle
                        .foregroundColor(.white)
                        .bold() // Make it bold
                        .opacity(fadeOut ? 0 : 1) // Fade out
                        .transition(.opacity) // Fade transition
                }
            }
        }
        .onAppear {
            // Show the first title after 1 second with fade-in
            withAnimation(.easeIn(duration: 1.0)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showTitle = true
                }
            }
            
            // Show the subtitle after another 2 seconds with fade-in
            withAnimation(.easeIn(duration: 1.0)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showSubtitle = true
                }
            }
            
            // Fade out after another 2 seconds and move to the main screen
            withAnimation(.easeOut(duration: 2.0)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    fadeOut = true
                }
            }
        }
        .opacity(fadeOut ? 0 : 1) // Overall fade-out effect
    }
}

