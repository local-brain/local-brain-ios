//
//  ChatListViewModel.swift
//  LocalBrain
//
//  Created by Michael Jach on 14/01/2024.
//

import SwiftUI

class ViewModel: ObservableObject {
  @Published var chats: [Chat] = [Chat(name: "New chat")]
  
  func sortedChats() -> Binding<[Chat]> {
    Binding<[Chat]>(
      get: {
        self.chats
      },
      set: { chats in
        for chat in chats {
          if let index = self.chats.firstIndex(where: { $0.id == chat.id }) {
            self.chats[index] = chat
          }
        }
      }
    )
  }
}
