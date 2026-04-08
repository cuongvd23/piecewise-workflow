---
name: plan-task
description: Break down a GitHub issue into sub-issues with acceptance criteria, then create and link them.
---

# Plan Task

Break down a GitHub issue into manageable sub-issues.

## Step 1: Gather Issue Information

Fetch the issue details:

- Run `gh issue view {{ARG1}}` to get the issue description
- Look for linked parent issues or sub-issues
- Identify the scope and requirements

## Step 2: Analyze the Issue

Understand:

- What is the main goal/feature?
- What are the technical components involved?
- What services/layers need changes? (proto, backend, frontend, infra)
- Are there any constraints or dependencies mentioned?

## Step 3: Explore the Codebase

Use the Task tool with subagent_type=Explore to:

- Understand the relevant parts of the codebase
- Identify existing patterns to follow
- Find files that will need modification
- Check for similar implementations

## Step 4: Break Down into Sub-Issues

Create sub-issues following this pattern:

### Cross-Service Feature Pattern (if applicable)

1. **Proto/API definitions** - Define interfaces first
2. **Backend service** - Implement core logic (Python/Go)
3. **Client module** - Create client to call the service
4. **Feature flag** - Add configuration for gradual rollout
5. **Integration** - Wire everything together
6. **Infrastructure** - Security groups, permissions, etc.

### For Each Sub-Issue, Define:

- **Title**: Clear, descriptive title (NO parent issue reference)
- **Description**: Self-contained explanation of what needs to be done — **NO cross-references** (see anti-patterns below)
- **Files to modify/create**: List specific paths
- **Acceptance criteria**: Checkboxes for completion

**No cross-references:** Do not include issue numbers (`#NNN`), relative references (`Sub-Issue N`, `from the proto issue`), dependency sections (`Blocked by:`, `Depends on:`, `Part of:`), or inline mentions of other issues. Write each description as if it were the only issue — describe *what* to do and *where*, not *which other issue* it relates to. GitHub's native sub-issue hierarchy handles all linking.

## Step 5: Ask for Permission

Before creating any issues, use the AskUserQuestion tool to confirm:

- Show summary of all sub-issues to be created
- Ask: "Should I create these issues in GitHub?"
- Options: "Yes, create all", "Let me review first", "Cancel"

## Step 6: Create Issues in GitHub (Only after approval)

If user approves:

### For each sub-issue:

1. Create the issue with assignee:

```bash
gh issue create \
  --title "..." \
  --body "..." \
  --assignee "@me"
```

2. Save the issue number
3. Report progress to user

### Error Handling:

- After each issue creation, verify the issue number was returned
- If issue creation fails, report to user and ask whether to continue with remaining issues
- Keep track of successfully created issues
- If linking fails, report which issues were created but not linked

**CRITICAL: After all issues are created, link them using the bundled script:**

```bash
org=$(gh repo view --json owner -q '.owner.login')
repo=$(gh repo view --json name -q '.name')
${CLAUDE_PLUGIN_ROOT}/bin/add-sub-issue-to-issue.sh "$org" "$repo" {{ARG1}} <sub-issue-number>
```

## Step 7: Output Summary

Provide:

- Issue hierarchy diagram showing all created sub-issues
- List of issue numbers for reference

## Important Notes

- **ALWAYS** use the linking script to establish parent-child relationships in GitHub
- Consider infrastructure needs (security groups, permissions)
- Include feature flags for gradual rollout of new features
- Follow existing patterns in the codebase

### No Cross-References in Issue Text

**DO NOT** include any form of cross-referencing in issue titles, descriptions, or comments:
- Issue numbers (`#NNN`)
- Relative references (`Sub-Issue N`, `from the proto issue`, `as defined in the parent`)
- Dependency sections (`Blocked by:`, `Depends on:`, `Part of:`, `Related to:`)
- Inline mentions of other issues (`once X is merged`, `generated from Y`)

The `add-sub-issue-to-issue.sh` script creates GitHub's native sub-issue links, which are the single source of truth for hierarchy. The project board tracks dependencies visually. Write each issue description as if it were the only issue — describe *what* to do and *where*, not *which other issue* it relates to.
