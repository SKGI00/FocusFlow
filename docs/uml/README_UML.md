# FocusFlow — corrected UML package (25 October 2026)

Source audit: `FocusFlow_Main_Review.zip` (the Git archive uploaded by the developer), compared with the previous `FocusFlow_Design_Process_Update.zip`.

**Change made:** Four diagrams updated to reflect present implementation (including Settings, shared preferences, and local Android notifications), actual `SessionPresenter.logDistraction(String): void` and `savedSessionId(): Future<int?>`. The original draft had a wrong return type and omitted the notifications feature. All diagrams keep MVP **Model–View–Presenter**, not MVVM. The sequence explicitly ends with the app displaying feedback to **User**.

## Included images
1. `01_Class_MVP.png`: representative typed public attributes and methods (not an exhaustive reverse-engineering of every Dart member). Session to distraction cardinality `1 → 0..*` and Session to reflection `1 → 0..1` reflect SQLite relationships and `UNIQUE(session_id)`.
2. `02_Runtime_Sequence.png`: the corrected UML lifeline sequence with start/log/finish/optional reflection and the final arrow returning feedback to User. Real code also handles early finish, Skip, and save failures; not every branch is drawn.
3. `03_Component.png`: Flutter presentation, presenters, analytics, repositories, SQLite, settings/preferences and native notification integration.
4. `04_Deployment.png`: Windows development, tested Android API 37 emulator runtime and independent GitHub Actions build-time CI; no remote app backend or cloud synchronization.

Each figure includes a scalable SVG; class/component/deployment diagrams also include editable Graphviz `.dot` sources. The source sequence SVG is preserved from the earlier corrected UML set because it properly depicts UML lifelines and final user feedback. Diagrams are source-informed design representations, not captured execution traces. Do not claim iOS device or physical Android testing on this evidence.

## Tutor feedback explicitly addressed
- Replace all ViewModel references with **Presenter**.
- State typed properties and operations in the representative class diagram.
- Include component and deployment diagrams and their boundaries.
- Restore end-user feedback at the end of the sequence diagram.
- Show exact on-device storage and Android notification service (current code rather than older drafts).

## Report insertion note
Use PNG figures in section 3.1 (Design and Implementation), caption below each diagram, and discuss changes from Milestone 1. Do not insert all source `.dot` texts into the report; keep them in GitHub for reproducibility. Ensure the wording of user feedback and UX behaviour matches the final built app.
