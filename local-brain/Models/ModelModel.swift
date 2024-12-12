//
//  ModelModel.swift
//  local-brain
//
//  Created by Michal Jach on 11/12/2024.
//

import Foundation

struct ModelModel: Equatable, Identifiable {
  let id: UUID
  let name: String
  let url: URL
  let filename: String
  let format: String
  let size: String
  var path: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
  }
}
