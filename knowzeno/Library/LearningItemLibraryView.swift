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

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Spacer()

                Button(isExpanded ? "Show Less" : "Show More") {
                    toggleExpanded(item)
                }
                .buttonStyle(.borderless)

                Button("Delete", systemImage: "trash", role: .destructive) {
                    itemPendingDeletion = item
                }
                .buttonStyle(.borderless)
                .disabled(deletingItemIDs.contains(item.id))
            }

            pairedContentBlock(
                title: "Learning Item",
                systemImage: "sparkles",
                date: LibraryDateText.dateOnly(from: item.learningItemCreatedAt),
                tint: .blue,
                contentTitle: "Summary",
                text: item.learningItemSummary,
                isExpanded: isExpanded
            )

            pairedContentBlock(
                title: "Source Note",
                systemImage: "note.text",
                date: LibraryDateText.dateOnly(from: item.sourceNoteCreatedAt),
                tint: .green,
                contentTitle: "Text",
                text: item.sourceNoteText,
                isExpanded: isExpanded
            )
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
        date: String,
        tint: Color,
        contentTitle: String,
        text: String,
        isExpanded: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(title, systemImage: systemImage)
                    .font(.headline)
                    .foregroundStyle(tint)

                Text(date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            textSection(
                title: contentTitle,
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

    private func textSection(title: String, text: String, isExpanded: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(isExpanded ? text : TextPreview.preview(for: text))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
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
