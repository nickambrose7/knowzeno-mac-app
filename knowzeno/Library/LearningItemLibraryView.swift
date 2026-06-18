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
    @State private var mutatingItemIDs: Set<UUID> = []
    @State private var editingItemID: UUID?
    @State private var titleDraft = ""
    @State private var summaryDraft = ""
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
        let isEditing = editingItemID == item.id
        let isMutating = mutatingItemIDs.contains(item.id)
        let date = LibraryDateText.dateOnly(from: item.learningItemCreatedAt)

        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.learningItemTitle)
                        .font(.headline)
                        .textSelection(.enabled)

                    Text(date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(item.learningItemLifecycleState.label)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(item.learningItemLifecycleState.tint)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.learningItemLifecycleState.tint.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 6))
            }

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

            if isEditing {
                editControls(for: item, isMutating: isMutating)
            }

            HStack(spacing: 8) {
                Button(isExpanded ? "Show Less" : "Show More") {
                    toggleExpanded(item)
                }
                .buttonStyle(CardActionButtonStyle())

                Button(isEditing ? "Cancel Edit" : "Edit", systemImage: "pencil") {
                    if isEditing {
                        cancelEditing()
                    } else {
                        startEditing(item)
                    }
                }
                .buttonStyle(CardActionButtonStyle())
                .disabled(isMutating)

                Button(
                    item.learningItemLifecycleState == .archived ? "Unarchive" : "Archive",
                    systemImage: item.learningItemLifecycleState == .archived ? "tray.and.arrow.up" : "archivebox"
                ) {
                    Task {
                        await toggleArchived(item)
                    }
                }
                .buttonStyle(CardActionButtonStyle())
                .disabled(isMutating)

                Spacer()

                Button(role: .destructive) {
                    itemPendingDeletion = item
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(CardActionButtonStyle(tint: .red))
                .disabled(deletingItemIDs.contains(item.id) || isMutating)
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

    private func editControls(for item: RecentLearningItemPair, isMutating: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Title", text: $titleDraft)
                .textFieldStyle(.roundedBorder)

            TextEditor(text: $summaryDraft)
                .frame(minHeight: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
                )
                .accessibilityLabel("Learning item summary")

            HStack {
                Button("Save Changes", systemImage: "checkmark") {
                    Task {
                        await saveEdits(item)
                    }
                }
                .buttonStyle(CardActionButtonStyle())
                .disabled(
                    isMutating
                    || titleDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    || summaryDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )

                Button("Cancel") {
                    cancelEditing()
                }
                .buttonStyle(CardActionButtonStyle())
                .disabled(isMutating)
            }
        }
        .padding(12)
        .background(Color.secondary.opacity(0.07))
        .clipShape(.rect(cornerRadius: 8))
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

    private func startEditing(_ item: RecentLearningItemPair) {
        editingItemID = item.id
        titleDraft = item.learningItemTitle
        summaryDraft = item.learningItemSummary
    }

    private func cancelEditing() {
        editingItemID = nil
        titleDraft = ""
        summaryDraft = ""
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

    private func saveEdits(_ item: RecentLearningItemPair) async {
        mutatingItemIDs.insert(item.id)
        errorMessage = nil

        do {
            let serverBaseURL = try AppConfiguration.sourceNoteServerBaseURL()
            let updatedItem = try await apiClient.updateLearningItem(
                id: item.id,
                title: titleDraft,
                summary: summaryDraft,
                apiKey: settings.apiKey,
                serverBaseURL: serverBaseURL
            )
            updateItem(item, with: updatedItem)
            cancelEditing()
        } catch {
            errorMessage = error.localizedDescription
        }

        mutatingItemIDs.remove(item.id)
    }

    private func toggleArchived(_ item: RecentLearningItemPair) async {
        mutatingItemIDs.insert(item.id)
        errorMessage = nil

        do {
            let serverBaseURL = try AppConfiguration.sourceNoteServerBaseURL()
            let updatedItem = if item.learningItemLifecycleState == .archived {
                try await apiClient.unarchiveLearningItem(
                    id: item.id,
                    apiKey: settings.apiKey,
                    serverBaseURL: serverBaseURL
                )
            } else {
                try await apiClient.archiveLearningItem(
                    id: item.id,
                    apiKey: settings.apiKey,
                    serverBaseURL: serverBaseURL
                )
            }
            updateItem(item, with: updatedItem)
        } catch {
            errorMessage = error.localizedDescription
        }

        mutatingItemIDs.remove(item.id)
    }

    private func updateItem(
        _ item: RecentLearningItemPair,
        with updatedItem: LearningItemMutationResponse
    ) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        items[index] = RecentLearningItemPair(
            learningItemID: updatedItem.learningItemID,
            learningItemTitle: updatedItem.learningItemTitle,
            learningItemSummary: updatedItem.learningItemSummary,
            learningItemLifecycleState: updatedItem.learningItemLifecycleState,
            learningItemCreatedAt: item.learningItemCreatedAt,
            sourceNoteID: item.sourceNoteID,
            sourceNoteText: item.sourceNoteText,
            sourceNoteCreatedAt: item.sourceNoteCreatedAt
        )
    }
}

#Preview {
    LearningItemLibraryView(settings: AppSettings())
}

private extension LearningItemLifecycleState {
    var label: String {
        switch self {
        case .active:
            "Active"
        case .archived:
            "Archived"
        case .learned:
            "Learned"
        }
    }

    var tint: Color {
        switch self {
        case .active:
            .blue
        case .archived:
            .orange
        case .learned:
            .green
        }
    }
}
