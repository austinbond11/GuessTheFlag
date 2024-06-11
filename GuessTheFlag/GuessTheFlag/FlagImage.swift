//
//  FlagImage.swift
//  GuessTheFlag
//
//  Created by Austin Bond on 6/11/24.
//

import SwiftUI

struct FlagImage: View {
    let name: String
    
    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: 150, height: 100)
            .clipShape(Capsule())
            .shadow(radius: 5)
            .transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    FlagImage(name: "France")
}
