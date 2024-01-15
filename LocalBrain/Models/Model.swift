//
//  Model.swift
//  LocalBrain
//
//  Created by Michael Jach on 14/01/2024.
//

import Foundation

struct Model: Identifiable {
  var id: String { name }
  let name: String
  let filename: String
  let url: URL
  var downloadState: DownloadState = .empty
  var isDownloaded: Bool {
    get {
      let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
      return FileManager.default.fileExists(atPath: path.path)
    }
  }
}
