# FocusFlow — Two-framework evaluation checkpoint (evidence-grounded)

**Purpose:** Apply ISO/IEC 25010:2023 as a software product-quality model and PACMAD for mobile usability. These frameworks are **adapted to a student developer prototype**; a three-task convenience test does not establish representative user satisfaction.

## A. PACMAD rapid task protocol (collect actual measurements)

Test in one continuous user journey on the **Android API 37 emulator**; reset to Home before T1. Use a stopwatch, count taps, note errors and outcome. A task is a **success only when its stated end state is visible**. If only the developer participates, label `participant D1 (developer)`; an independent user can be added only with actual voluntary consent and anonymised results.

| Task ID | Start → end state | Success (Y/N) | Time (s) | Taps | Errors (#) | Effort 1 easy–5 hard | Notes |
|---|---|---|---|---|---|---|---|
| P01 | Home → choose 15 min → countdown running | [fill] | [fill] | [fill] | [fill] | [fill] | [fill] |
| P02 | While timer running → tap `Phone` → distraction count becomes 1 | [fill] | [fill] | [fill] | [fill] | [fill] | [fill] |
| P03 | End session early → select `Good` or `Choice` → Save reflection → History shows saved reflection | [fill] | [fill] | [fill] | [fill] | [fill] | [fill] |

**Derived statistics after recording:**

- **Effectiveness:** number of successful tasks / 3 × 100%.
- **Efficiency:** actual per-task seconds and taps; avoid implying stopwatch precision beyond manual timing.
- **Errors:** navigation mistakes, wrong taps or failed saves, recorded per task; counts may be zero **only if actually observed**.
- **Learnability:** note whether first attempt required guidance, and whether a second attempt improved (only if tested).
- **Satisfaction:** an actual rating/feedback after the tasks (developer self-rating must be labelled as such).
- **Cognitive load:** subjective 1–5 effort per task is a quick proxy, not a validated workload scale.
- **Memorability:** cannot be established in one immediate session; mark **not assessed** unless a delayed retest takes place.

| PACMAD attribute | Planned observable / boundary | Status |
|---|---|---|
| Effectiveness | T1–T3 completed / attempted | PENDING raw task results |
| Efficiency | Stopwatch seconds and tap counts | PENDING |
| Satisfaction | Recorded actual participant response, if solicited | PENDING |
| Learnability | Guidance needed / second attempt change if tested | PENDING |
| Memorability | Delayed return visit comparison | NOT TESTED |
| Errors | Incorrect interactions and task failures | PENDING |
| Cognitive load | Post-task effort 1–5, self-report only | PENDING |

## B. ISO/IEC 25010:2023 evaluation tailored to FocusFlow

**2023 edition**: evaluate characteristics relevant to this prototype rather than claiming all nine characteristics have been assessed. Product-quality checks and user-task checks are complementary; don't interchange them.

| Product-quality aspect | Device/repository evidence | Conclusion status |
|---|---|---|
| Functional suitability | Core focus flow, reflections, analytics, tips, settings; 58 automated Flutter tests and CI #6 green | Verified tests pass; manual R06–R10 still pending |
| Reliability | Offline app/history persistence verified in emulator; session interruption shows `Not yet ended` | Demonstrated offline persistence; lifecycle limitation/open check |
| Interaction capability / accessibility | Maximum font size surfaced two overflows; fixes retested with no visible overflow markers | Before/after device verification; TalkBack and touch targets not comprehensively tested |
| Performance efficiency | No measured release APK size, frame timings or cold-start distribution yet | NOT MEASURED; do not claim low CPU/battery cost |
| Compatibility / portability | Android emulator API 37 confirmed; Flutter produces Android/iOS project structure | Android run observed; iOS compatibility **not tested** |
| Security / privacy | On-device SQLite, settings shared preferences, no account required by design | Local persistence observed; encryption and complete absence of network traffic **not proven** |
| Maintainability | Model–View–Presenter organisation; tests; successful CI runs | Evidence: code organisation and 58 tests; maintainability not quantitatively measured |

## C. Results and analysis structure (copy to report after P01–P03)

**Method:** I used PACMAD to measure mobile task success, time, taps, observed errors and perceived effort during [actual participant count] task trials. I used ISO/IEC 25010:2023 to assess functional suitability, reliability, interaction capability, performance, security and compatibility using documented tests and real Android device/emulator observations.

**Results (fill from data, not invented):** [3 tasks; x/3 successful; per-task seconds/taps; observed errors and effort]. Android offline persistence and notification delivery were confirmed in the supplied screenshots. A maximum-text-scale test revealed a 6px overflow in Reflection and a 2px overflow in Insights; both were corrected and visually retested.

**Interpretation/limitations:** Small, developer-conducted test without independent participants cannot establish usability for neurodivergent users as a population. The Android emulator is not a substitute for low-end physical Android testing or iOS testing. Interrupted session recovery and high-level security claims remain limitations.

**Source links:** ISO official: https://www.iso.org/standard/78176.html ; Harrison et al. PACMAD original model: https://link.springer.com/article/10.1186/2194-0827-1-1
