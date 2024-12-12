//
//  Chats.swift
//  local-brain
//
//  Created by Michal Jach on 11/12/2024.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Chats {
  @Reducer(state: .equatable)
  enum Path {
    case chat(Chat)
  }
  
  @ObservableState
  struct State: Equatable {
    var isDownloading: Bool {
      models.contains(where: { $0.downloadState == .downloading })
    }
    var chats: IdentifiedArrayOf<Chat.State> = []
    var models: IdentifiedArrayOf<ModelItem.State> = [
      ModelItem.State(model: ModelModel(
        id: UUID(),
        name: "Meta Llama 3.1 8B",
        url: URL(string:  "https://huggingface.co/bartowski/Meta-Llama-3.1-8B-Instruct-GGUF/resolve/main/Meta-Llama-3.1-8B-Instruct-Q4_K_S.gguf?download=true")!,
        filename: "Meta-Llama-3.1-8B-Instruct-Q4_K_S.gguf",
        format: """
        <|start_header_id|>user<|end_header_id|>
          {prompt}<|eot_id|><|start_header_id|>assistant<|end_header_id|>
        """,
        size: "5GB"
      )),
      ModelItem.State(model: ModelModel(
        id: UUID(),
        name: "Meta Llama 3.2 3B",
        url: URL(string:  "https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_0.gguf?download=true")!,
        filename: "Llama-3.2-3B-Instruct-Q4_0.gguf",
        format: """
        <|start_header_id|>user<|end_header_id|>
          {prompt}<|eot_id|><|start_header_id|>assistant<|end_header_id|>
        """,
        size: "2GB"
      )),
      ModelItem.State(model: ModelModel(
        id: UUID(),
        name: "Qwen 2.5.1 7B",
        url: URL(string:  "https://huggingface.co/bartowski/Qwen2.5.1-Coder-7B-Instruct-GGUF/resolve/main/Qwen2.5.1-Coder-7B-Instruct-Q4_0.gguf?download=true")!,
        filename: "Qwen2.5.1-Coder-7B-Instruct-Q4_0.gguf",
        format: """
          <|im_start|>system
          You are a helpful assistant that answer questions and provide valuable informations.<|im_end|>
          <|im_start|>user
          {prompt}<|im_end|>
          <|im_start|>assistant
        """,
        size: "4GB"
      )),
      ModelItem.State(model: ModelModel(
        id: UUID(),
        name: "Ministral 8B",
        url: URL(string:  "https://huggingface.co/bartowski/Ministral-8B-Instruct-2410-GGUF/resolve/main/Ministral-8B-Instruct-2410-Q4_0.gguf?download=true")!,
        filename: "Ministral-8B-Instruct-2410-Q4_0.gguf",
        format: "<s>[INST]{prompt}[/INST]",
        size: "5GB"
      ))
    ]
    var activeId: UUID?
    
    // Sub states
    var path = StackState<Path.State>()
  }
  
  enum Action: Sendable {
    case initialize
    case newChat
    
    // Sub actions
    case path(StackActionOf<Path>)
    case chats(IdentifiedActionOf<Chat>)
    case models(IdentifiedActionOf<ModelItem>)
  }
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .initialize:
        state.activeId = state.models.first(where: { $0.downloadState == .downloaded })?.id
        if state.models.first(where: { $0.downloadState == .downloaded }) == nil {
          return .run { [models = state.models] send in
            if let uuid = models.first?.id {
              await send(.models(.element(id: uuid, action: .download)))
            }
          }
        }
        return .none
        
      case .newChat:
        if let activeModel = state.models.first(where: { $0.id == state.activeId }) {
          let chatState = Chat.State(chat: ChatModel(
            id: UUID(),
            model: activeModel.model
          ))
          state.chats.append(chatState)
          state.path.append(.chat(chatState))
        }
        return .none
        
      case .path(.element(_, action: .chat(.cleanup))):
        state.chats = state.chats.filter({ !$0.chat.text.isEmpty })
        return .none
        
      case .path(.element(_, action: .chat(.setTitle(let title)))):
        if let idx = state.path.first?.chat?.id {
          state.chats[id: idx]?.chat.title = title
        }
        return .none
        
      case .path(.element(_, action: .chat(.didCreateContext(let context)))):
        if let idx = state.path.first?.chat?.id,
          state.chats[id: idx]?.chat.llamaContext == nil {
          state.chats[id: idx]?.chat.llamaContext = context
        }
        return .none
        
      case .path(.element(_, action: .chat(.onResponse(let response)))):
        if let idx = state.path.first?.chat?.id {
          state.chats[id: idx]?.chat.text += response
        }
        return .none
        
      case .path:
        return .none
        
      case .chats:
        return .none
        
      case .models(.element(_, action: .delete(let uuid))):
        if uuid == state.activeId {
          state.activeId = nil
        }
        return .none
        
      case .models(.element(_, action: .setActive(let uuid))):
        state.activeId = uuid
        return .none
        
      case .models:
        return .none
      }
    }
    .forEach(\.path, action: \.path)
    .forEach(\.chats, action: \.chats) {
      Chat()
    }
    .forEach(\.models, action: \.models) {
      ModelItem()
    }
  }
}
