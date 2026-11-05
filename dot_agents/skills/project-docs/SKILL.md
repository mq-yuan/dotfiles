---
name: project-docs
description: Rules for writing and maintaining project documentation - status pages, contracts, guides, experiment records, findings and archives. Use whenever creating, updating, consolidating or reviewing docs/, README files, experiment records or status pages, or when deciding what from a discussion or experiment should be written down.
---

# Project Docs

Docs are context for every later agent and reader. Each line written will be read and will shape
later reasoning. Write the converged state of the project, not the path that led to it.

## Document types

| Type | Answers | Write mode | Default reading path |
| --- | --- | --- | --- |
| Contract | What the system must be: interfaces, invariants, coordinates | Rewrite on design change; no run details | Yes |
| Guide | How to use what is implemented | Change in the same commit as the code | Yes |
| Status | What is in progress now, next step, blockers | Overwrite; short | Yes |
| Record | One experiment or task: setup, outcome, conclusion | Conclusion first; rewrite while active | When relevant |
| Finding | Conclusions about one topic that hold across experiments | Short; each claim links its evidence | Index line yes; file when working on its topic |
| Archive | Closed records and iteration history kept on request | Frozen | No - only when the user asks |

## Scope

- Apply these rules to projects that already have docs, or when the user asks to create them.
  Do not set up a docs structure on your own initiative.
- Use only the types a project needs; a small project may have just a README or one document.
- Third-party code cloned to run baselines or comparisons gets no docs, and its README is not
  edited. Record its runs and results in the owning project's records.
- A project with docs maps these types to locations in its docs index; follow that mapping.

## Findings are found by topic

A record is found by its name (an experiment, a task). A finding is found by its topic.

- Each finding answers one question about a component, loss, data source, method or behavior.
  Name it after that topic, not after the experiment that produced it.
- The docs index lists every finding as one line: `topic - one-sentence conclusion`. A reader
  learns the conclusion from the index without opening the file.
- Before changing, evaluating or designing an experiment on a topic, check the findings index for
  it. Open the finding when its evidence or details are needed.
- A finding that dictates how something must be done is promoted into the contract or guide; the
  finding keeps the evidence.

## Record conclusions, not exploration

Exploration produces hypotheses, checks, refutations and dead ends. They stay in the conversation
or in scratch notes, not in docs, because later agents will read them and follow them.

- Write only after the discussion or experiment has converged. If convergence is unclear, ask.
- State what was established. If X is caused by Y, write that X is caused by Y. Do not mention
  the candidates that were eliminated on the way.
- Record a negative result only when it is itself the converged conclusion (for example, the cause
  of X is still unknown, but A has been shown to be unrelated).
- Do not add "ruled out", "alternatives considered" or "earlier hypothesis" sections unless the
  user explicitly asks for them.
- Keep iteration history only when the user asks to preserve it, and put it in the archive.
- Sanity checks that simply confirmed expectations are not worth recording; at most, one line in
  the owning record saying the behavior was verified.

## Rewrite, do not append

- Update by rewriting the affected text so the document reads as if written today. No
  "Update (date):" paragraphs, no changelog sections; git keeps history.
- Delete superseded statements instead of annotating them as outdated.
- One fact lives in one place; elsewhere, link to it.
- A good docs change is often net-neutral or shorter in length.

## Be concise

- Test each sentence: would a fresh agent act differently without it? If not, cut it.
- Lead with the conclusion; details follow only as far as they support it.
- Keep only the numbers that support a conclusion. Hashes, PIDs, ETAs, full logs and command
  transcripts go to the evidence location (outputs, run directories); link it.
- No defensive caveats unless the boundary would actually mislead a reader.
- No narration of the work ("I checked...", "This audit..."). Describe the project, not the session.

## Status page

- One page, overwritten in place, about one screen (60 lines at most).
- Contains only active work, its current state, the next step and blockers. Results go to records
  or findings; finished items leave status, keeping at most a link to their record.
- Each state carries an as-of date and its source (log, checkpoint, process list, user report).
- Update status in the same session that changes the state. Never write expected or planned state
  as current.
- Before acting on status, check it against live state. If it is stale, correct it or tell the user.

## Reading boundary

- Entry documents (AGENTS.md, the docs index, status) link only maintained documents. The archive
  is reachable only through its own index.
- Archived files start with one line: historical, not current guidance, read only when asked.
- Do not open archived documents unless the user names them or explicitly asks for history.

## Memory versus docs

Project facts - decisions, plans, data locations, results - belong in the repository docs. Agent
memory holds collaboration preferences and pointers, never the only copy of a project fact.

## Language

Code, comments and configs are English only. Docs, READMEs, experiment records and summaries
prefer English but may use Chinese where it aids reading.

## Before finishing a docs change

- Only converged conclusions were added; no exploration trail.
- Affected text was rewritten, not appended to; superseded text was removed.
- Status is still true and short.
- No entry document gained a link into the archive.
- Local links and anchors resolve.
