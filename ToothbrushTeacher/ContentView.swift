import SwiftUI

@MainActor
struct ContentView: View {
    @State private var viewModel = ToothbrushViewModel()
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let completedDays = [10, 15]

    var body: some View {
        VStack(spacing: 30) {
            Text("🪥 歯磨き先生")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            VStack(alignment: .leading) {
                Text("今月の達成状況")
                    .font(.headline)
                    .padding(.horizontal)
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(1...30, id: \.self) { day in
                        Text("\(day)")
                            .frame(width: 40, height: 40)
                            .background(completedDays.contains(day) ? Color.green.opacity(0.3) : Color.gray.opacity(0.1))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(completedDays.contains(day) ? Color.green : Color.clear, lineWidth: 2)
                            )
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            Spacer()
            
            if viewModel.isRunning {
                VStack(spacing: 10) {
                    Text("只今、歯磨き中...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(viewModel.steps[viewModel.currentStepIndex])
                        .font(.system(size: 48, weight: .bold))
                    Text("あと \(viewModel.timeRemainingInStep) 秒")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    Button("途中でやめる") {
                        viewModel.endTimer()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            } else {
                Button(action: {
                    viewModel.startTimer()
                }) {
                    Text("歯磨きをスタート")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
