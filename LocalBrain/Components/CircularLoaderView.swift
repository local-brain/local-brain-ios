//
//  ProgressViewStyle+Extension.swift
//  LocalBrain
//
//  Created by Michael Jach on 14/01/2024.
//

import SwiftUI

struct CircularLoaderView: View {
  @State private var animate = false
  
  let gradient = LinearGradient(
    stops: [
      Gradient.Stop(color: .primary, location: 0.1),
      Gradient.Stop(color: .primary.opacity(0.8), location: 0.4),
      Gradient.Stop(color: .primary.opacity(0.4), location: 0.8)
    ],
    startPoint: .leading,
    endPoint: .trailing
  )
  
  var body: some View {
    Circle()
      .stroke(gradient, lineWidth: 3)
      .frame(width: 16, height: 16)
      .rotationEffect(Angle(degrees: animate ? 360 : 0))
      .animation(
        .linear(duration: 1)
        .repeatForever(autoreverses: false),
        value: animate
      )
      .onAppear {
        withAnimation {
          animate.toggle()
        }
      }
  }
}
