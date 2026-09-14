# Team GitHub guide - literal beginner procedure

Private repository: https://github.com/Midiansi/projet-binairo . It must remain private. Commits made by the agent use the authenticated owner's GitHub noreply identity; this does not assert human authorship of code. Headers disclose AI assistance; the three actual author names must be supplied before submission.

## 1. Owner invites the two teammates (manual)

1. Ask each teammate for their exact GitHub username. No password or token is needed.
2. In your browser, sign into GitHub as Midiansi. Open the repository link above.
3. Select Settings, then Collaborators (some account layouts call it Collaborators and teams / Manage access).
4. Select Add people. Paste one exact username, inspect the matching profile, then Add to this repository. Repeat for the second actual username only.
5. Teammates accept their invitations from GitHub. Keep repository visibility Private. Do not invite the agent or other people. These are manual instructions; no invitations were sent by the agent.

## 2. Software on the suitable teammate computer

Windows is the provisional group target: Git for Windows, GitHub CLI (`gh`), Python 3.10+ for development tests, Visual Studio Build Tools with Desktop development with C++ / Windows SDK, licensed course LabVIEW (English interface assumed) and MATLAB. MATLAB/LabVIEW are only operated by the team. Course VM is an optional fallback, not mandatory. A C compiler is needed only to rebuild C; Python is a development helper, never a submission runtime dependency. The runtime requires LabVIEW, a target-built OCR executable and MATLAB, plus the supplied launcher.

Official installation starting points: https://git-scm.com/downloads ; https://cli.github.com/ ; https://www.python.org/downloads/ ; https://visualstudio.microsoft.com/downloads/ . Use the institution's licensed NI/MathWorks distribution already available to the group. Do not buy a subscription or paid API credit for this workflow.

## 3. First clone

1. Open Windows Start, type `PowerShell`, open it. Choose a directory where you keep coursework.
2. Paste `gh auth login --hostname github.com --git-protocol https --web`. Choose your own GitHub account, follow the displayed one-time code procedure in your own browser. Do not paste credentials into this project or chat.
3. Paste `gh auth setup-git`.
4. Paste `git clone https://github.com/Midiansi/projet-binairo.git`.
5. Paste `cd projet-binairo`.
6. Paste `git status`. Expect `On branch main` and a clean working tree.
7. Restore excluded files: copy the delivered course_materials files into this clone's course_materials folder. Keep the original course download and transcript archive in your separate private backup. They are intentionally missing from GitHub.
8. Follow C_OPERATOR_GUIDE.md to build the executable for this computer, then run `python tools/prepare_runtime.py`. Follow MATLAB_OPERATOR_GUIDE.md and LABVIEW_CONSTRUCTION_GUIDE.md. No Mac binary may substitute for OCR.exe.

## 4. Get updates before editing

1. Close LabVIEW VIs to avoid saving over incoming changes. In PowerShell inside the clone paste `git status`.
2. If clean: paste `git fetch origin`, then `git log --oneline --left-right HEAD...origin/main`, then `git pull --ff-only`.
3. If Git reports local changes: preserve and commit your own changes with the procedure below before pulling. Never use reset --hard, clean -fd, checkout --, force push, or discard changes to get past an error.
4. If pull cannot fast-forward, stop and return the command output to this task. The agent fetches and inspects both histories and reconciles ordinary text changes. Binary VIs require preserving both files and manual reconciliation, below.
5. Reassemble runtime with `python tools/prepare_runtime.py`. Authoritative VIs live in labview/. Do not edit an old runtime copy after newer source VIs were copied.

## 5. One writer per VI

The LabVIEW builder owns every `.vi` initially; the MATLAB/test operator and coordinator must not edit the same VI concurrently. Record the builder's actual name/username in state/VI_OWNERSHIP.md when assigned. To transfer ownership: current writer saves, closes, commits and pushes; next writer pulls, records the transfer and starts. One writer also applies final reconciliation. Git cannot merge graphical VI edits safely.

## 6. Return changes with minimal work

Option A, agent-managed commits: zip only labview/ source VIs and the complete evidence folder, return that archive to this task and state which VI you edited. The agent inspects, commits and pushes. Until returned and pushed, those teammate-only edits are NOT backed up remotely.

Option B, teammate push:
1. Save and close LabVIEW. Ensure source VIs are saved in labview/, not only runtime/.
2. Put run logs/screenshots into evidence/ followed by a new descriptive folder name (example: evidence/windows-first-run/). Remove personal paths or unrelated windows from screenshots when possible; preserve technical error text.
3. Paste `git status` and review every listed file. Course assets and conversations should not appear.
4. Paste `git add labview evidence state/VI_OWNERSHIP.md` (omit evidence if it does not yet exist).
5. Paste `git diff --cached --stat`, `git diff --cached --name-only`, then `git diff --cached`. Inspect contents: only project work, no secrets or course PDFs/transcripts. Binary VI entries have no text diff; inspect their filenames and open them manually before saving.
6. Paste `git commit -m "Add LabVIEW construction and native test evidence"`.
7. Paste `git fetch origin`, then `git log --oneline --left-right HEAD...origin/main`. If remote-only commits appear, return that output to the agent before pushing; do not force.
8. Paste `git push origin main`.
9. Paste `git rev-parse HEAD` and `git ls-remote origin refs/heads/main`. The two hashes must agree. A local commit alone is not an off-device backup.

## 7. Conflicting binary VIs

Do not select an arbitrary winner. Before merge, the agent exports local and remote versions with distinct names into work/vi-conflicts/ and notes their original file names and commit hashes. The designated writer opens each version in separate LabVIEW windows, compares the changed front panels, connector panes and diagrams, and applies both intended edits manually into a new authoritative VI in labview/. Preserve both originals outside the submission folder until native tests pass. The writer returns before/after screenshots, reconciled VI and test evidence; the agent then commits and pushes. Never auto-merge binary bytes.

## 8. Recover after a computer failure

1. On replacement computer install Git/GitHub CLI, then authenticate and clone using section 3.
2. Run `git log -1 --oneline`. Compare the latest saved hash in the last project handoff; a later teammate commit can legitimately be newer.
3. Restore course_materials from the separate excluded-files backup and complete conversation PDFs into transcripts/. Restore any submission-required native executable, example outputs and licenses/environment from that backup or rebuild them.
4. Rebuild C for the replacement OS/CPU; run tests; assemble runtime; open BinairoSolver.vi from runtime/. Run the complete native acceptance sequence again in the new directory.

## 9. Separate backup for excluded submission files

Copy the unchanged original course download plus the latest complete delivery archive and transcripts to an encrypted external disk or a private institution-approved cloud folder. Also copy native generated Cell.bin, CellValue.txt, solve.m, solution/error PDFs and the final target executable. These are needed for submission/restore but intentionally excluded from GitHub. Name the backup by UTC date and verify opening one file from the backup. This copy is not claimed complete until someone actually performs and checks it. GitHub backs up committed project sources, guides, tests and accepted evidence only.

## 10. If authentication later fails

Use only `gh auth login --hostname github.com --git-protocol https --web`, then `gh auth setup-git`, then retry `git push origin main` and hash verification. Never share the one-time code/token in chat. Remote backup is pending until a push succeeds. Do not create a second public repository as a workaround.
