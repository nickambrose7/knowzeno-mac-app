//
//  LearningItemLibraryView.swift
//  knowzeno
//

import SwiftUI

struct LearningItemLibraryView: View {
    let settings: AppSettings
    private let apiClient = SourceNoteAPIClient()
    @State private var limit: LearningItemLimit = .twenty
    @State private var items: [RecentLearningItemPair] = []
    @State private var expandedItemIDs: Set<UUID> = []
    @State private var deletingItemIDs: Set<UUID> = []
    @State private var itemPendingDeletion: RecentLearningItemPair?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Library")
                    .font(.title2)
                    .bold()

                Spacer()

                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                }
            }

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.red.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 8))
            }

            if items.isEmpty && isLoading == false {
                ContentUnavailableView(
                    "No Learning Items",
                    systemImage: "tray",
                    description: Text("Recent learning items will appear here after generation finishes.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(items) { item in
                    learningItemRow(item)
                }
                .listStyle(.inset)
            }
        }
        .padding(24)
        .toolbar {
            ToolbarItemGroup {
                Picker("Items", selection: $limit) {
                    ForEach(LearningItemLimit.allCases) { limit in
                        Text(limit.label).tag(limit)
                    }
                }
                .pickerStyle(.menu)

                Button("Refresh", systemImage: "arrow.clockwise") {
                    Task {
                        await loadItems()
                    }
                }
                .disabled(isLoading)
            }
        }
        .task {
            await loadItems()
        }
        .onChange(of: limit) { _, _ in
            Task {
                await loadItems()
            }
        }
        .alert(
            "Delete Learning Item?",
            isPresented: Binding(
                get: { itemPendingDeletion != nil },
                set: { isPresented in
                    if isPresented == false {
                        itemPendingDeletion = nil
                    }
                }
            ),
            presenting: itemPendingDeletion
        ) { item in
            Button("Delete", role: .destructive) {
                Task {
                    await delete(item)
                }
            }

            Button("Cancel", role: .cancel) { }
        } message: { _ in
            Text("This removes the learning item and its review data. The source note is removed only if no other learning items use it.")
        }
    }

    private func learningItemRow(_ item: RecentLearningItemPair) -> some View {
        let isExpanded = expandedItemIDs.contains(item.id)
        let date = LibraryDateText.dateOnly(from: item.learningItemCreatedAt)

        return VStack(alignment: .leading, spacing: 14) {
            Text(date)
                .font(.caption)
                .foregroundStyle(.secondary)

            pairedContentBlock(
                title: "Learning Item",
                systemImage: "sparkles",
                tint: .blue,
                text: item.learningItemSummary,
                isExpanded: isExpanded
            )

            pairedContentBlock(
                title: "Source Note",
                systemImage: "note.text",
                tint: .green,
                text: item.sourceNoteText,
                isExpanded: isExpanded
            )

            HStack {
                Button(isExpanded ? "Show Less" : "Show More") {
                    toggleExpanded(item)
                }
                .buttonStyle(CardActionButtonStyle())

                Spacer()

                Button(role: .destructive) {
                    itemPendingDeletion = item
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(CardActionButtonStyle(tint: .red))
                .disabled(deletingItemIDs.contains(item.id))
                .accessibilityLabel("Delete")
                .help("Delete")
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(.rect(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
        )
        .padding(.vertical, 6)
    }

    private func pairedContentBlock(
        title: String,
        systemImage: String,
        tint: Color,
        text: String,
        isExpanded: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(title, systemImage: systemImage)
                    .font(.headline)
                    .foregroundStyle(tint)

                Spacer()
            }

            textSection(
                text: text,
                isExpanded: isExpanded
            )
        }
        .padding(12)
        .background(tint.opacity(0.08))
        .clipShape(.rect(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(tint.opacity(0.22), lineWidth: 1)
        )
    }

    private func textSection(text: String, isExpanded: Bool) -> some View {
        Text(isExpanded ? text : TextPreview.preview(for: text))
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func toggleExpanded(_ item: RecentLearningItemPair) {
        if expandedItemIDs.contains(item.id) {
            expandedItemIDs.remove(item.id)
        } else {
            expandedItemIDs.insert(item.id)
        }
    }

    private func loadItems() async {
        guard settings.apiKey.isEmpty == false else {
            items = []
            errorMessage = "Enter an API key in Settings to load learning items."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let serverBaseURL = try AppConfiguration.sourceNoteServerBaseURL()
            items = try await apiClient.learningItems(
                limit: limit,
                apiKey: settings.apiKey,
                serverBaseURL: serverBaseURL
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func delete(_ item: RecentLearningItemPair) async {
        deletingItemIDs.insert(item.id)
        errorMessage = nil

        do {
            let serverBaseURL = try AppConfiguration.sourceNoteServerBaseURL()
            try await apiClient.deleteLearningItem(
                id: item.id,
                apiKey: settings.apiKey,
                serverBaseURL: serverBaseURL
            )
            items.removeAll { $0.id == item.id }
            expandedItemIDs.remove(item.id)
        } catch {
            errorMessage = error.localizedDescription
        }

        deletingItemIDs.remove(item.id)
    }
}

#Preview {
    LearningItemLibraryView(settings: AppSettings())
}

private struct CardActionButtonStyle: ButtonStyle {
    var tint: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        CardActionButton(configuration: configuration, tint: tint)
    }
}

private struct CardActionButton: View {
    let configuration: ButtonStyle.Configuration
    let tint: Color

    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovered = false

    var body: some View {
        configuration.label
            .font(.callout)
            .bold()
            .foregroundStyle(foregroundStyle)
            .padding(.horizontal, 12)
            .frame(minWidth: 36, minHeight: 30)
            .background(backgroundShape)
            .overlay(borderShape)
            .clipShape(.rect(cornerRadius: 7))
            .contentShape(.rect)
            .opacity(isEnabled ? 1 : 0.45)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: isHovered)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
            .onHover { isHovered = $0 }
    }

    private var foregroundStyle: Color {
        guard isEnabled else { return .secondary }
        return isHovered ? tint : .secondary
    }

    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(backgroundColor)
    }

    private var borderShape: some View {
        RoundedRectangle(cornerRadius: 7)
            .stroke(borderColor, lineWidth: 1)
    }

    private var backgroundColor: Color {
        guard isEnabled else { return .clear }

        if configuration.isPressed {
            return tint.opacity(0.22)
        }

        return isHovered ? tint.opacity(0.14) : Color.secondary.opacity(0.08)
    }

    private var borderColor: Color {
        guard isEnabled else { return Color.secondary.opacity(0.12) }
        return isHovered ? tint.opacity(0.65) : Color.secondary.opacity(0.22)
    }
}
