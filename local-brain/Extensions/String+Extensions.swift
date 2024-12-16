//
//  String+Extensions.swift
//  local-brain
//
//  Created by Michal Jach on 12/12/2024.
//

extension String {
  func trimModelAdditions() -> String {
    return self
      .replacingOccurrences(of: "<|start_header_id|>assistant<|end_header_id|>", with: "")
      .replacingOccurrences(of: "<|start_header_id|>", with: "")
      .replacingOccurrences(of: "<|end_header_id|>", with: "")
      .replacingOccurrences(of: "|end_header_id|>", with: "")
      .replacingOccurrences(of: "<|eot|>", with: "")
      .replacingOccurrences(of: "<|eot_id|>", with: "")
      .replacingOccurrences(of: "<s>[OUT]", with: "")
      .replacingOccurrences(of: "[/OUT]", with: "")
      .replacingOccurrences(of: "\\n ", with: "\n", options: [.regularExpression])
  }
}
