//
//  inputField.swift
//  Youtube Downloader
//
//  Created by Sharad Jadhav on 13/08/25.
//

import SwiftUI

struct CustomInputField: View {
    let placeholder: String
    @Binding var text: String
    var body: some View {
        HStack {
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.secondary))
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .background(Color(.quaternaryLabelColor))
                .cornerRadius(6)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
    }
}
