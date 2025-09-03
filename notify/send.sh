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
COLOR="${COLOR:-good}"
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

# Format status for display
if [ "$STATUS" == "success" ]; then
  STATUS_EMOJI="✅"
  STATUS_TEXT="Success"
elif [ "$STATUS" == "failure" ]; then
  STATUS_EMOJI="❌"
  STATUS_TEXT="Failure"
elif [ "$STATUS" == "cancelled" ]; then
  STATUS_EMOJI="⚠️"
  STATUS_TEXT="Cancelled"
else
  STATUS_EMOJI="ℹ️"
  STATUS_TEXT="$STATUS"
fi

# Create payload based on platform
if [ "$PLATFORM" == "slack" ]; then
  # Slack payload
  PAYLOAD=$(cat <<EOF
{
  "attachments": [
    {
      "color": "$COLOR",
      "blocks": [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "$STATUS_EMOJI *$STATUS_TEXT:* $MESSAGE"
          }
        },
        {
          "type": "section",
          "fields": [
            {
              "type": "mrkdwn",
              "text": "*Job:*\n$JOB_NAME"
            },
            {
              "type": "mrkdwn",
              "text": "*Repo:*\n<$REPO_URL|$REPOSITORY>"
            },
            {
              "type": "mrkdwn",
              "text": "*Branch:*\n$REF"
            },
            {
              "type": "mrkdwn",
              "text": "*Commit:*\n<$COMMIT_URL|$SHORT_COMMIT>"
            },
            {
              "type": "mrkdwn",
              "text": "*Actor:*\n$ACTOR"
            }
          ]
        }
      ]
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
      "color": $([ "$COLOR" == "good" ] && echo "65280" || [ "$COLOR" == "danger" ] && echo "16711680" || echo "16776960"),
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
