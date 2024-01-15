//
//  ChatDetail.swift
//  LocalBrain
//
//  Created by Michael Jach on 14/01/2024.
//

import SwiftUI

struct ChatDetail: View {
  @Binding var chat: Chat
  @State var prompt = ""
  @State var isLoading = false
  @FocusState private var focusedField: String?
  
  var body: some View {
    VStack {
      ScrollView {
        VStack {
          HStack {
            Text(chat.responses.joined())
              .fontWeight(.medium)
              .padding(.horizontal, 24)
            
            Spacer()
          }
          
          if isLoading {
            HStack {
              CircularLoaderView()
              Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
          }
        }
      }
      
      TextField("what's on your mind ?", text: $prompt)
        .focused($focusedField, equals: "prompt")
        .disabled(isLoading)
        .opacity(isLoading ? 0.5 : 1)
        .padding()
        .clipShape(RoundedRectangle(cornerRadius: 13))
        .overlay(
          RoundedRectangle(cornerRadius: 13)
            .stroke(Color("ColorSecondary"), lineWidth: 2)
        )
        .padding(24)
        .submitLabel(.send)
        .onSubmit {
          Task {
            await onSubmitPrompt()
          }
        }
    }
    .onAppear {
      focusedField = "prompt"
    }
  }
  
  @MainActor
  func onSubmitPrompt() async {
    chat.name = prompt
    isLoading = true
    if !chat.responses.isEmpty {
      chat.responses.append("\n\n")
    }
    chat.responses.append("→ \(prompt)\n\n")
    
    guard let llamaContext = chat.llamaContext else { return }
    
    await withTaskGroup(of: Void.self) { group in
      group.addTask {
        await llamaContext.completion_init(text: prompt)
        prompt = ""
        
        while await llamaContext.n_cur < llamaContext.n_len {
          let result = await llamaContext.completion_loop()
          chat.responses.append(result)
        }
      }
    }
    
    isLoading = false
  }
}

#Preview {
  NavigationView {
    ChatDetail(
      chat: .constant(Chat(
        name: "New chat",
        responses: ["Hello, my name is ultra bot."],
        modelFileUrl: URL(fileURLWithPath: "")
      )),
      isLoading:true
    )
  }
}
