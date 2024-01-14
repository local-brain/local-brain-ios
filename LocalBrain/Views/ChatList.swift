//
//  ChatList.swift
//  LocalBrain
//
//  Created by Michael Jach on 14/01/2024.
//

import SwiftUI
import CoreData

struct ChatList: View {
  @EnvironmentObject var viewModel: ViewModel
  @State private var path = NavigationPath()
  
  var body: some View {
    NavigationStack {
      List {
        Section(header: Text("Recent chats")) {
          ForEach(viewModel.sortedChats()) { $chat in
            NavigationLink {
              ChatDetail(chat: $chat)
            } label: {
              Text(chat.name)
            }
          }
        }
        
        Section {
          Button {
            onAddNewChat()
          } label: {
            HStack {
              Image("icon-add")
                .resizable()
                .frame(width: 24, height: 24)
              
              Text("New chat")
                .fontWeight(.medium)
            }
          }
        }
      }
    }
  }
  
  func onAddNewChat() {
    viewModel.chats.append(Chat(name: "New chat"))
  }
}

#Preview {
  ChatList()
    .environmentObject(ViewModel())
}
