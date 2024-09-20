//
//  sparshmattcompApp.swift
//  sparshmattcomp
//
//  Created by Sparsh Kapoor on 9/4/24.
//

import SwiftUI

@main
struct sparshmattcompApp: App {
    @State private var isSplashFinished = false
        var body: some Scene {
            WindowGroup {
                if isSplashFinished {
                    MainView() // Show MainView after splash is done
                } else {
                    SplashView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                // Set flag to true after splash animation finishes
                                isSplashFinished = true
                            }
                        }
                }
            }
        }
}
