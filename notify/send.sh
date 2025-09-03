#!/bin/bash

set -e

# Check required environment variables
if [ -z "$WEBHOOK_URL" ]; then
  echo "Error: WEBHOOK_URL is required"
  exit 1
fi

# Default values
STATUS="${STATUS:-success}"
PLATFORM="${PLATFORM:-slack}"
MESSAGE="${MESSAGE:-GitHub Action completed}"
JOB_NAME="${JOB_NAME:-GitHub Action}"
REPOSITORY="${REPOSITORY:-Unknown repository}"
REF="${REF:-main}"
COMMIT="${COMMIT:-Unknown commit}"
ACTOR="${ACTOR:-Unknown actor}"
GITHUB_SERVER_URL="${GITHUB_SERVER_URL:-https://github.com}"

# Format commit SHA to short version
SHORT_COMMIT=$(echo "$COMMIT" | cut -c1-7)

# Create repository URL
REPO_URL="${GITHUB_SERVER_URL}/${REPOSITORY}"
COMMIT_URL="${REPO_URL}/commit/${COMMIT}"

# Format status for display and set color
if [ "$STATUS" == "success" ]; then
  STATUS_EMOJI="✅"
  STATUS_TEXT="Success"
  COLOR="good"
elif [ "$STATUS" == "failure" ]; then
  STATUS_EMOJI="❌"
  STATUS_TEXT="Failure"
  COLOR="danger"
elif [ "$STATUS" == "cancelled" ]; then
  STATUS_EMOJI="⚠️"
  STATUS_TEXT="Cancelled"
  COLOR="warning"
else
  STATUS_EMOJI="ℹ️"
  STATUS_TEXT="$STATUS"
  COLOR="good"
fi

# Create payload based on platform
if [ "$PLATFORM" == "slack" ]; then
  # Slack payload
  PAYLOAD=$(cat <<EOF
{
  "attachments": [
    {
      "color": "$COLOR",
      "fallback": "$STATUS_TEXT: $MESSAGE",
      "text": "$STATUS_EMOJI *$STATUS_TEXT:* $MESSAGE",
      "fields": [
        {
          "title": "Job",
          "value": "$JOB_NAME",
          "short": true
        },
        {
          "title": "Repository",
          "value": "<$REPO_URL|$REPOSITORY>",
          "short": true
        },
        {
          "title": "Branch",
          "value": "$REF",
          "short": true
        },
        {
          "title": "Commit",
          "value": "<$COMMIT_URL|$SHORT_COMMIT>",
          "short": true
        },
        {
          "title": "Actor",
          "value": "$ACTOR",
          "short": true
        }
      ],
      "mrkdwn_in": ["text", "fields"]
    }
  ]
}
EOF
)
elif [ "$PLATFORM" == "discord" ]; then
  # Discord payload
  PAYLOAD=$(cat <<EOF
{
  "embeds": [
    {
      "title": "$STATUS_TEXT: $MESSAGE",
      "color": $([ "$COLOR" == "good" ] && echo "65280" || [ "$COLOR" == "danger" ] && echo "16711680" || [ "$COLOR" == "warning" ] && echo "16776960" || echo "3447003"),
      "fields": [
        {
          "name": "Job",
          "value": "$JOB_NAME",
          "inline": true
        },
        {
          "name": "Repository",
          "value": "[$REPOSITORY]($REPO_URL)",
          "inline": true
        },
        {
          "name": "Branch",
          "value": "$REF",
          "inline": true
        },
        {
          "name": "Commit",
          "value": "[$SHORT_COMMIT]($COMMIT_URL)",
          "inline": true
        },
        {
          "name": "Actor",
          "value": "$ACTOR",
          "inline": true
        }
      ]
    }
  ]
}
EOF
)
else
  echo "Error: Unsupported platform '$PLATFORM'. Use 'slack' or 'discord'."
  exit 1
fi

# Send the notification
curl -s -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL"

echo "Notification sent to $PLATFORM successfully."
