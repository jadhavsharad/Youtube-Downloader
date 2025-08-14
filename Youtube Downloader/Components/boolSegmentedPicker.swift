import SwiftUI

struct BoolSegmentedPicker<Content: View>: View {
    @Binding var selection: Bool
    
    let labels: [Bool: String]
    let content: (String) -> Content

    var body: some View {
        LazyHStack(spacing: 0) {
            ForEach([false, true], id: \.self) { option in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.selection = option
                    }
                }) {
                    content(labels[option] ?? "") // Use the label for the content
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(self.selection == option ? Color.accentColor : Color.clear)
                        .foregroundColor(self.selection == option ? .white : .primary)
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(9)
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

