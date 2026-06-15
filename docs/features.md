# Onboarding
- When the user first downloads the app, the onboarding flow explicitly explains:
    1. knowzeno works only with user-selected text.
    2. Capture happens only after the user presses the configured shortcut or
       chooses the menu bar capture item.
    3. Captured text is copied into the local Capture tab editor first.
    4. Nothing is sent to the backend until the user reviews the editor and
       presses Send text to server.
    5. Submitted text is used to create source notes and learning notes.
- The onboarding flow also asks for the user's API key, lets the user choose the
  global capture shortcut, explains Accessibility permission, and shows the
  basic workflow: select text, capture it, review/edit, submit, then review or
  delete generated notes in Library.
- The Help menu includes Show Onboarding so users can review the onboarding
  flow again without clearing their API key or shortcut.
    
    
# App Interface
The main app interface has two tabs:

1. Capture: display captured text and send it to the backend. The Capture tab
   repeats that only selected text is captured and that nothing is sent until
   the user presses Send text to server. After the global
   shortcut captures text, the send button is focused so Return can submit
   without using the mouse. Repeated captures append to the editor with a blank
   line separator, and only the clear button empties the editor.
2. Library: show recent learning items with their source notes, preview long
   text by default, expand rows on demand, choose a 20/50/100 item limit, and
   delete accidental learning items.

# Direct Download Accessibility
- If selected text capture works in development but not in the direct-download
  app, grant Accessibility permission to the installed `/Applications/Knowzeno.app`
  copy. macOS ties Accessibility permission to the specific signed app copy, so
  old development, DerivedData, or `~/Applications` entries may not apply.
