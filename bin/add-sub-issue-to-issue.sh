#!/bin/bash

# Adds a sub-issue (child) to an issue (parent)

if [ -z "$4" ]; then
  echo "Usage: $0 <org> <repo> <parent-issue-number> <child-issue-number>"
  echo "Example: ./add-sub-issue-to-issue.sh my-org my-repo 5 6"
  exit 1
fi

org="$1"
repo="$2"
parent_issue_number="$3"
child_issue_number="$4"

# Define color codes
RED='\033[0;31m'
NC='\033[0m' # No Color

fetch_issue_id() {
  local org=$1
  local repo=$2
  local issue_number=$3

  issue_id=$(gh api graphql -F owner="$org" -f repository="$repo" -F number="$issue_number" -f query='
  query ($owner: String!, $repository: String!, $number: Int!) {
    repository(owner: $owner, name: $repository) {
      issue(number: $number) {
        id
      }
    }
  }' --jq '.data.repository.issue.id')

  if [ $? -ne 0 ] || [ -z "$issue_id" ]; then
    echo -e "${RED}Issue #$issue_number not found in repository '$repo' of organization '$org'.${NC}"
    exit 1
  fi

  echo "$issue_id"
}

parent_issue_id=$(fetch_issue_id "$org" "$repo" "$parent_issue_number")

child_issue_id=$(fetch_issue_id "$org" "$repo" "$child_issue_number")

# Add the sub-issue to the parent issue
gh api graphql -H GraphQL-Features:issue_types -H GraphQL-Features:sub_issues -f parentIssueId="$parent_issue_id" -f childIssueId="$child_issue_id" -f query='
mutation($parentIssueId: ID!, $childIssueId: ID!) {
  addSubIssue(input: { issueId: $parentIssueId, subIssueId: $childIssueId }) {
    issue {
      title
      number
      url
      id
      issueType {
        name
      }
    }
    subIssue {
      title
      number
      url
      id
      issueType {
        name
      }
    }
  }
}'

if [ $? -eq 0 ]; then
  echo "Successfully added issue $org/$repo#$child_issue_number as a sub-issue to $org/$repo#$parent_issue_number."
else
  echo -e "${RED}Failed to add issue $org/$repo#$child_issue_number as a sub-issue to $org/$repo#$parent_issue_number.${NC}"
  exit 1
fi
