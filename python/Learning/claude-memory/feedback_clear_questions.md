---
name: feedback-clear-questions
description: "When quizzing the user, ask ONE clear question — do not mix two prompts (e.g., \"what does it print?\" plus a hint that points elsewhere)"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 6eb4cdae-4ce4-4397-99f8-a560f21c21b4
---

When quizzing or testing the user, ask exactly **one** clear question. Do not bundle a primary question with a hint that points to a different angle.

**Why:** The user got confused when I asked "what does this print?" but added a hint "what's missing?" — the hint pointed them to answer about the absent `super()` call rather than the actual output. Mixed signals made them give what looked like a wrong answer when they actually knew the concept.

**How to apply:** When writing a quiz/test question:
- State one question.
- If giving a hint, the hint must reinforce that same question, not redirect to a different one.
- Avoid stacking "what does X do?" + "what's missing/wrong?" in the same prompt.

Related: [[course-general]]
