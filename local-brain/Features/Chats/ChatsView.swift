//
//  ChatsView.swift
//  local-brain
//
//  Created by Michal Jach on 11/12/2024.
//

import SwiftUI
import ComposableArchitecture

struct ChatsView: View {
  @Bindable var store: StoreOf<Chats>
  
  var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
      List {
        Section(header: Text("Recent")) {
          if store.chats.isEmpty {
            Text("No recent chats")
              .foregroundStyle(.secondary)
          } else {
            ForEach(store.chats) { chatState in
              NavigationLink(state: Chats.Path.State.chat(chatState)) {
                HStack {
                  Text(chatState.chat.title)
                  
                  Spacer()
                  
                  Text(chatState.chat.model.name)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                }
              }
            }
          }
        }
        
        Section {
          Button {
            store.send(.newChat)
          } label: {
            HStack(spacing: 4) {
              Image("icon-add")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
              
              Text("New chat")
            }
          }
          .disabled(store.activeId == nil)
        }
        
        Section(header: Text("Models"), footer: Text("All models are open source, downloaded from huggingface.co.")) {
          ForEach(store
            .scope(state: \.models, action: \.models)) { modelStore in
              HStack {
                ModelItemView(store: modelStore)
                
                if store.activeId == modelStore.model.id {
                  Circle()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(.green)
                }
              }
            }
        }
      }
      .navigationTitle("Chats")
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Image("icon-logo")
            .resizable()
            .scaledToFit()
            .frame(width: 28)
        }
      }
    } destination: { store in
      switch store.case {
      case let .chat(store):
        ChatView(store: store)
      }
    }
    .onAppear {
      store.send(.initialize)
    }
  }
}

#Preview {
  ChatsView(store: Store(initialState: Chats.State(
    chats: [Chat.State(chat: Mocks.chatModel)]
  )) {
    Chats()
  })
}
