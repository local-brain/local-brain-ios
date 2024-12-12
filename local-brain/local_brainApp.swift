//
//  local_brainApp.swift
//  local-brain
//
//  Created by Michal Jach on 11/12/2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct local_brainApp: App {
  let store = Store(initialState: Chats.State()) {
    Chats()
  }
  
  var body: some Scene {
    WindowGroup {
      ChatsView(store: store)
    }
  }
}
