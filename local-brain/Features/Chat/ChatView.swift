//
//  ChatView.swift
//  local-brain
//
//  Created by Michal Jach on 11/12/2024.
//

import SwiftUI
import ComposableArchitecture

struct ChatView: View {
  @Bindable var store: StoreOf<Chat>
  @FocusState var focusedField: Chat.State.Field?
  
  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        VStack(alignment: .leading) {
          HStack {
            Text(LocalizedStringKey(store.chat.text.trimModelAdditions()))
            
            Spacer()
          }
          .padding(.horizontal)
          .sensoryFeedback(.impact, trigger: store.chat.text)
          .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.3))
          )
          
          if store.isLoading {
            ProgressView()
              .padding(.horizontal, 24)
              .padding(.vertical, 12)
          }
        }
      }
      .defaultScrollAnchor(.bottom)
      
      HStack {
        TextField("What's on your mind ?", text: $store.prompt.sending(\.onPromptChange))
          .focused($focusedField, equals: .prompt)
          .disabled(store.isLoading)
          .opacity(store.isLoading ? 0.5 : 1)
          .padding(18)
          .submitLabel(.send)
          .onSubmit {
            store.send(.onSubmit)
          }
        
        Button {
          if store.isLoading {
            store.send(.cancelInference)
          } else {
            store.send(.onSubmit)
          }
        } label: {
          Image(store.isLoading ? "icon-stop" : "icon-send")
            .resizable()
            .frame(width: 18, height: 18)
            .foregroundStyle(.colorButtonLabel)
            .padding(4)
            .background(.colorAccent)
            .clipShape(Circle())
        }
        .padding(.trailing)
      }
      .bind($store.focusedField.sending(\.setFocusedField), to: $focusedField)
      .background(.colorBackgroundPrimary)
      .clipShape(RoundedRectangle(cornerRadius: 13))
      .padding()
      .padding(.top, 8)
    }
    .navigationTitle(store.chat.title)
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      store.send(.initialize)
    }
    .onDisappear {
      store.send(.cleanup)
    }
  }
}

#Preview {
  ChatView(store: Store(initialState: Chat.State(
    chat: Mocks.chatModel
  )) {
    Chat()
  })
}
