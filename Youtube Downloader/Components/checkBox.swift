
import SwiftUI

struct CustomCheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 16) {
            configuration.label
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundColor(configuration.isOn ? .accentColor : .gray)
                .onTapGesture {
                    withAnimation(.spring( duration: 0.2, blendDuration: 0.8)) {
                        configuration.isOn.toggle()
                    }
                }
        }
    }
}
