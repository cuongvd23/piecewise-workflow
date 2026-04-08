---
name: post-task-verification
description: Verify implementation completeness against requirements after finishing a task
---

# Post-Task Verification

Verify that all requirements are met and no similar patterns were missed.

## Context

- Issue/PR: {{ARG1}} (issue number, PR number, or omit for current branch)
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -5`
- Changed files: !`git diff $(git rev-parse --abbrev-ref origin/HEAD | sed 's@origin/@@') --name-only`

## Step 1: Gather Requirements

Fetch the original requirements:

- If issue number: `gh issue view {{ARG1}}`
- If PR number: `gh pr view {{ARG1}}`
- If omitted: Use current branch's associated PR/issue

**Also fetch comments for business requirements:**

- For issues: `gh issue view {{ARG1}} --comments`
- For PRs: `gh pr view {{ARG1}} --comments`

Look for comments containing:
- Expected outcomes or behaviors
- Test scenarios from business perspective
- Acceptance summaries before testing phase
- Keywords: "expected", "should", "must", "verify", "test", "outcome"

Extract and list:
- Core requirements (from issue/PR body)
- **Business expectations (from comments)**
- Acceptance criteria
- Change type: `feature`, `model-update`, `config-change`, `api-change`, `bug-fix`

## Step 2: Analyze Changes

Review the implementation:

- List all modified files from `git diff <base-branch> --name-only`
- Identify new patterns introduced (clients, config fields, methods)
- Note the components touched

## Step 3: Run Project-Specific Checks

Based on change type, run relevant verification:

| Change Type | Verification | Search Command |
|-------------|--------------|----------------|
| New client/service | Check all consumers have access | `grep -r "<pattern>" .` |
| New config field | Check all consumers updated | `grep -r "<field_name>" .` |
| New dependency | Check all consumers updated | Search import statements |
| New method/function | Check similar components | Compare files with similar structure |
| Generated code | Check regeneration needed | Run the project's code generation commands if applicable |

### Cross-Check Strategy

Identify related components by:
1. Finding similar usages of existing patterns in the codebase
2. Checking files with similar structure to modified files
3. Looking for parallel implementations (e.g., handlers, calculators, processors)

For config changes, verify:
- Config definition files are updated
- Config is properly passed to all consumers
- All consumers handle the new config field

## Step 4: Search for Orphaned Patterns

Look for inconsistencies:

```bash
# Example: Find places using old pattern but not new
grep -r "<old_pattern>" . | grep -v "<new_pattern>"
```

Flag any file that:
- Uses the old pattern but not the new one
- Has similar structure to modified files but wasn't updated

## Step 5: Generate Report

### Requirements Coverage

| Source | Requirement | Status | Evidence |
|--------|-------------|--------|----------|
| Issue body | Requirement 1 | ✅/❌ | `file:line` or reason |
| Comment by @user | Expected outcome X | ✅/❌ | `file:line` or reason |

### Business Expectations (from comments)

| Commenter | Expected Outcome | Status | Notes |
|-----------|------------------|--------|-------|
| @business-member | "Feature should do X" | ✅/❌ | Implementation details |

### Potential Gaps

List any findings:
- [ ] **Gap**: Description → Affected: `file1`, `file2`

### Verification Checklist

Based on change type, confirm:

**Config Changes:**
- [ ] Config definition updated
- [ ] Config passed to all consumers
- [ ] All consumers handle new config

**API Changes:**
- [ ] API definitions updated (proto/OpenAPI/etc.)
- [ ] All handlers/endpoints implement changes
- [ ] Tests updated

## Step 6: Final Verification

Run the project's lint and test commands based on the types of files changed.

Report pass/fail status.

## Important Notes

- **READ-ONLY** - This skill only analyzes, does not modify code
- When uncertain, mark as "needs review" rather than assuming OK
- Focus on detecting when same change is needed in multiple places
