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
  var downloadState: DownloadState = .notDownloaded
  
  init(name: String, filename: String, url: URL, downloadState: DownloadState? = .notDownloaded) {
    self.name = name
    self.filename = filename
    self.url = url
    
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
    let isDownloaded = FileManager.default.fileExists(atPath: path.path)
    self.downloadState = isDownloaded ? .downloaded : .notDownloaded
  }
}
