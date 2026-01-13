import SwiftUI

struct FAQView: View {
    
    @StateObject private var viewModel = FAQViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("Часто задаваемые вопросы")
                        .font(.title)
                        .bold()
                        .padding(.horizontal, 24)
                    
                    ForEach(viewModel.faqItems, id: \.question) { item in
                        FAQItem(question: item.question, answer: item.answer)
                            .padding(.horizontal, 16)
                    }
                    
                    Spacer(minLength: 60)
                }
            }
            .navigationTitle("FAQ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
}

private struct FAQItem: View {
    
    let question: String
    let answer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question)
                .font(.headline)
            Text(answer)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
}

#Preview {
    FAQView()
}
