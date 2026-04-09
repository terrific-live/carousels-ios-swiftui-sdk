//
//  AnalyticsEventsView.swift
//  CarouselDemo
//

import SwiftUI

// MARK: - AnalyticsEventsView
struct AnalyticsEventsView: View {
    @ObservedObject var store: AnalyticsEventStore
    @State private var isExpanded = false

    private let collapsedHeight: CGFloat = 44
    private let expandedHeight: CGFloat = 250

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Events list (visible when expanded)
            if isExpanded {
                eventsListView
            }
        }
        .background(Color.black.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
    }

    // MARK: - Header
    private var headerView: some View {
        Button(action: { isExpanded.toggle() }) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)

                Text("Analytics Events")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Text("\(store.events.count)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .clipShape(Capsule())

                Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.horizontal, 16)
            .frame(height: collapsedHeight)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Events List
    private var eventsListView: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray.opacity(0.3))

            if store.events.isEmpty {
                emptyStateView
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(store.events.reversed()) { event in
                                eventRowView(event)
                                    .id(event.id)
                                Divider()
                                    .background(Color.gray.opacity(0.2))
                            }
                        }
                    }
                    .frame(height: expandedHeight - collapsedHeight - 40)
                    .onChange(of: store.events.count) { _, _ in
                        if let lastEvent = store.events.first {
                            withAnimation(.easeOut(duration: 0.2)) {
                                proxy.scrollTo(lastEvent.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Clear button
                clearButtonView
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.title)
                .foregroundColor(.gray)
            Text("No events yet")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("Interact with the carousel to see events")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.7))
        }
        .frame(height: expandedHeight - collapsedHeight)
    }

    // MARK: - Event Row
    private func eventRowView(_ event: AnalyticsEventItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Time
            Text(timeFormatter.string(from: event.timestamp))
                .font(.caption2.monospacedDigit())
                .foregroundColor(.gray)
                .frame(width: 55, alignment: .leading)

            // Event info
            VStack(alignment: .leading, spacing: 2) {
                Text(event.eventName)
                    .font(.caption.bold())
                    .foregroundColor(.green)

                Text(event.details)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Clear Button
    private var clearButtonView: some View {
        Button(action: { store.clear() }) {
            HStack {
                Image(systemName: "trash")
                Text("Clear")
            }
            .font(.caption)
            .foregroundColor(.red)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Formatter
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack {
            Spacer()
            AnalyticsEventsView(store: AnalyticsEventStore())
        }
    }
}
