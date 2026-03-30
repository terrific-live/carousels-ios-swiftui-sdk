//
//  PollView.swift
//  CarouselDemo
//

import SwiftUI

// MARK: - PollDisplayMode
enum PollDisplayMode {
    case interactive  // Allows voting (for Detail)
    case readOnly     // No interaction (for Feed)
}

// MARK: - PollView
struct PollView: View {
    @ObservedObject var viewModel: PollViewModel
    let sizeConfig: PollStyleConfiguration
    let displayMode: PollDisplayMode

    init(
        viewModel: PollViewModel,
        sizeConfig: PollStyleConfiguration = .default,
        displayMode: PollDisplayMode = .interactive
    ) {
        self.viewModel = viewModel
        self.sizeConfig = sizeConfig
        self.displayMode = displayMode
    }

    /// Whether to show answered state (both modes show answered state when actually answered)
    private var showAnsweredState: Bool {
        viewModel.isAnswered
    }

    /// Whether user can interact with the poll (vote)
    private var isInteractive: Bool {
        displayMode == .interactive
    }

    var body: some View {
        VStack(spacing: sizeConfig.optionSpacing) {
            // Question
            Text(viewModel.pollData.question)
                .font(sizeConfig.questionFont.toFont())
                .italic()
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .padding(.horizontal, sizeConfig.horizontalPadding)
                .padding(.bottom, sizeConfig.verticalPadding)

            // Options
            ForEach(viewModel.pollData.options.prefix(4)) { option in
                if showAnsweredState {
                    PollOptionAnswered(
                        text: option.text,
                        percentage: viewModel.percentage(for: option),
                        percentageFraction: viewModel.percentageFraction(for: option),
                        isSelected: viewModel.selectedOptionIndex == option.id,
                        sizeConfig: sizeConfig,
                        isInteractive: isInteractive
                    ) {
                        viewModel.handleSelectOption(option.id)
                    }
                } else {
                    PollOptionNotAnswered(
                        text: option.text,
                        sizeConfig: sizeConfig,
                        isInteractive: isInteractive,
                        isSelected: viewModel.selectedOptionIndex == option.id
                    ) {
                        viewModel.handleSelectOption(option.id)
                    }
                }
            }
        }
        .padding(.horizontal, sizeConfig.horizontalPadding)
    }
}

// MARK: - Preview
#Preview("Not Answered - Interactive") {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "#0a1a3a"), Color(hex: "#5a9a8a")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        PollView(
            viewModel: PollViewModel(
                assetId: "preview-asset",
                pollData: PollData(
                    id: "preview-1",
                    questionId: "question-preview-1",
                    question: "Ce soir sur France TV, vous êtes plutôt...",
                    options: [
                        PollOptionData(id: 0, text: "Curling (F)", numberOfVotes: 0),
                        PollOptionData(id: 1, text: "Saut à ski (H)", numberOfVotes: 0),
                        PollOptionData(id: 2, text: "Ski acrobatique (F)", numberOfVotes: 0),
                        PollOptionData(id: 3, text: "Bobsleigh (F)", numberOfVotes: 0)
                    ]
                )
            ),
            sizeConfig: .default,
            displayMode: .interactive
        )
    }
}

#Preview("Answered - Interactive") {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "#1a3a4a"), Color(hex: "#4a8a7a")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        PollView(
            viewModel: PollViewModel(
                assetId: "preview-asset",
                pollData: PollData(
                    id: "preview-2",
                    questionId: "question-preview-2",
                    question: "Qu'allez-vous suivre aujourd'hui sur France TV ?",
                    options: [
                        PollOptionData(id: 0, text: "Hockey sur glace", numberOfVotes: 210),
                        PollOptionData(id: 1, text: "Bobsleigh", numberOfVotes: 230),
                        PollOptionData(id: 2, text: "Saut à ski", numberOfVotes: 240),
                        PollOptionData(id: 3, text: "Ski acrobatique", numberOfVotes: 320)
                    ]
                ),
                isAnswered: true,
                selectedOptionIndex: 1
            ),
            sizeConfig: .default,
            displayMode: .interactive
        )
    }
}

#Preview("Read Only Mode (Feed - Answered)") {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "#1a3a4a"), Color(hex: "#4a8a7a")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        PollView(
            viewModel: PollViewModel(
                assetId: "preview-asset",
                pollData: PollData(
                    id: "preview-3",
                    questionId: "question-preview-3",
                    question: "Qu'allez-vous suivre aujourd'hui sur France TV ?",
                    options: [
                        PollOptionData(id: 0, text: "Hockey sur glace", numberOfVotes: 210),
                        PollOptionData(id: 1, text: "Bobsleigh", numberOfVotes: 230),
                        PollOptionData(id: 2, text: "Saut à ski", numberOfVotes: 240),
                        PollOptionData(id: 3, text: "Ski acrobatique", numberOfVotes: 320)
                    ]
                ),
                isAnswered: true,
                selectedOptionIndex: 1
            ),
            sizeConfig: .compact,
            displayMode: .readOnly  // Shows answered state, no interaction
        )
    }
}

#Preview("Read Only Mode (Feed - Not Answered)") {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "#0a1a3a"), Color(hex: "#5a9a8a")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        PollView(
            viewModel: PollViewModel(
                assetId: "preview-asset",
                pollData: PollData(
                    id: "preview-4",
                    questionId: "question-preview-4",
                    question: "Ce soir sur France TV, vous êtes plutôt...",
                    options: [
                        PollOptionData(id: 0, text: "Curling (F)", numberOfVotes: 0),
                        PollOptionData(id: 1, text: "Saut à ski (H)", numberOfVotes: 0),
                        PollOptionData(id: 2, text: "Ski acrobatique (F)", numberOfVotes: 0),
                        PollOptionData(id: 3, text: "Bobsleigh (F)", numberOfVotes: 0)
                    ]
                )
            ),
            sizeConfig: .compact,
            displayMode: .readOnly  // Shows unanswered state, no interaction
        )
    }
}
