//
//  LocalBrainApp.swift
//  LocalBrain
//
//  Created by Michael Jach on 14/01/2024.
//

import SwiftUI

@main
struct LocalBrainApp: App {
  @StateObject private var viewModel = ViewModel()
  
  var body: some Scene {
    WindowGroup {
      ChatList()
        .environmentObject(viewModel)
    }
  }
}
