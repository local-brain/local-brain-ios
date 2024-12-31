//
//  ModelItemView.swift
//  local-brain
//
//  Created by Michal Jach on 11/12/2024.
//

import SwiftUI
import ComposableArchitecture

struct ModelItemView: View {
  let store: StoreOf<ModelItem>
  
  var body: some View {
    Menu {
      switch store.downloadState {
      case .notDownloaded:
        Button {
          store.send(.download)
        } label: {
          Label("Download", systemImage: "arrow.down.circle")
        }
        
      case .downloading:
        Button {
          store.send(.cancel)
        } label: {
          Label("Cancel", systemImage: "stop.circle")
        }
        
      case .downloaded:
        Button {
          store.send(.setActive(store.model.id))
        } label: {
          Label("Set active", systemImage: "checkmark.circle")
        }
        Button {
          store.send(.delete(store.model.id))
        } label: {
          Label("Delete", systemImage: "trash")
        }
        
      case .notSupported:
        EmptyView()
      }
      
    } label: {
      HStack {
        Text(store.model.name)
        
        Spacer()
        
        switch store.downloadState {
        case .notDownloaded:
          HStack {
            Text(store.model.size)
              .foregroundStyle(.secondary)
            
            Image("icon-download")
              .resizable()
              .frame(width: 18, height: 18)
          }
          
        case .downloading:
          Text("\(store.downloadProgress)%")
          
        case .downloaded:
          EmptyView()
          
        case .notSupported:
          Text("Device not supported")
            .foregroundStyle(.secondary)
            .font(.caption)
        }
      }
    }
  }
}

#Preview {
  ModelItemView(store: Store(initialState: ModelItem.State(
    model: Mocks.modelModel
  )) {
    ModelItem()
  })
}
