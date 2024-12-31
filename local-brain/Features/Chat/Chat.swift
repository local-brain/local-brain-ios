//
//  Chat.swift
//  local-brain
//
//  Created by Michal Jach on 11/12/2024.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Chat {
  @ObservableState
  struct State: Equatable, Identifiable {
    var id: UUID { chat.id }
    var chat: ChatModel
    var isLoading = false
    var prompt = ""
    var focusedField: Field?
    
    enum Field: String, Hashable {
      case prompt
    }
  }
  
  enum Action: Sendable {
    case setTitle(String)
    case initialize
    case onPromptChange(String)
    case onSubmit
    case onResponse(String)
    case onResponseEnd
    case cancelInference
    case setFocusedField(State.Field?)
    case cleanup
  }
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .initialize:
        return .run { send in
          await send(.setFocusedField(.prompt))
        }
        
      case .cleanup:
        return .none
        
      case .setFocusedField(let field):
        state.focusedField = field
        return .none
        
      case .onPromptChange(let prompt):
        state.prompt = prompt
        return .none
        
      case .setTitle(let title):
        state.chat.title = title
        return .none
        
      case .onSubmit:
        state.isLoading = true
        guard let llamaContext = state.chat.llamaContext else { return .none }
        
        return .run { [llamaContext = llamaContext, prompt = state.prompt, model = state.chat.model] send in
          await send(.setTitle(prompt))
          await send(.onResponse("\n\n**\(prompt.trimmingCharacters(in: .whitespacesAndNewlines))**\n\n"))
          let fullPrompt = model.format.replacingOccurrences(of: "{prompt}", with: prompt)
          await llamaContext.completion_init(text: fullPrompt)
          
          while await llamaContext.n_cur < llamaContext.n_len {
            if await llamaContext.is_done {
              await send(.cancelInference)
              return
            }
            let result = await llamaContext.completion_loop()
            await send(.onResponse(result))
          }
          await send(.onResponseEnd)
        }
        
      case .onResponse(let response):
        state.chat.text += response
        return .none
        
      case .onResponseEnd:
        state.isLoading = false
        state.prompt = ""
        return .none
        
      case .cancelInference:
        state.isLoading = false
        state.prompt = ""
        return .run { [llamaContext = state.chat.llamaContext] send in
          await llamaContext?.cancel()
        }
      }
    }
  }
}
