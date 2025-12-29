//
//  Video_Wall_UtilityApp.swift
//  Video Wall Utility
//
//  Created by Fabian Scheidt on 14.12.25.
//

import SwiftUI

@main
struct Video_Wall_UtilityApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(state: StateController())
        }
        .windowStyle(.hiddenTitleBar)
    }
}
