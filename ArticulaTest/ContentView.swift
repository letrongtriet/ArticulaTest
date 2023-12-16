//
//  ContentView.swift
//  ArticulaTest
//
//  Created by Triet Le on 16.12.2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            Spacer()

            Text("Welcome")
                .font(.largeTitle)

            Text("Tap the call button below to start")

            Spacer()

            Button {
                viewModel.didTapCallButton()
            } label: {
                Image(
                    systemName: viewModel.isCalling
                    ? "phone.arrow.down.left.fill"
                    : "phone.arrow.up.right.fill"
                )
                .resizable()
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .padding(20)
                .background(
                    Circle()
                        .fill(
                            viewModel.isCalling
                            ? .red
                            : .green
                        )
                )
            }
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.onAppear()
            }
        }
        .onDisappear {
            viewModel.onDisappear()
        }
        .alert("Important!!!", isPresented: $viewModel.hasError) {
            Button("OK", role: .cancel) {
                viewModel.didRespondToError()
            }
        }
    }
}

#Preview {
    ContentView()
}
