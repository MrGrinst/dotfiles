---
name: standup
description: "Draft Kyle's daily standup reply in his team's Slack standup thread: pull his last standup from Slack, review how each planned item went, suggest unplanned work and ticket/PR/doc links from GitHub, Linear and Notion, plan today, and leave a Slack draft in today's thread. Use when Kyle says 'standup', 'do my standup', 'write my standup', or 'pull my last standup'. Pass 'pull' to only save the last Slack standup locally for the `standup` terminal script."
allowed-tools: "Read Write Bash"
---

# Standup

Kyle posts standup as a reply in a daily thread that a workflow starts in a team Slack channel. The workplace-specific settings live outside this repo in `~/.config/standup/config.json`; read it first:

```json
{
  "slack": { "channel": "<channel ID>", "threadMarker": "<text in the daily thread's parent message>" },
  "githubOrg": "<GitHub org>",
  "linear": { "workspace": "<Linear workspace slug>", "teamKeys": ["<issue key prefix>"] }
}
```

If the file or `slack` is missing, ask Kyle for the values and offer to write the file. Kyle's Slack user ID is the logged-in user named in the Slack search tool's description.

The `standup` script (`~/Developer/dotfiles/bin/standup`) owns the output format, emoji names, day labels and link expansion, so never hand-format the final message. Standups are saved as `~/standups/YYYY-MM-DD.md`, named for the day they were posted.

## Shape of a standup

- Statuses go on top-level items only. Sub-bullets describe the item above them: context, where it stands, why it was cut. They never get a status of their own.
- Something that happened on its own deserves its own top-level item, usually `added`.

## Statuses

| Status | Rendered | Meaning | Carries to today |
| --- | --- | --- | --- |
| `done` | `:standup-done:` | finished | no |
| `partial` | `:standup-partway:` | started, not finished; add a note on where it stands | yes |
| `missed` | `:standup-not-started:` | didn't get to it, still on the plate | yes |
| `cut` | `~strikethrough~` + a required "why" sub-bullet | off the plate: dropped, deprioritized, superseded, someone else took it, blocked with no date, or a `(stretch)` item that didn't happen | no |
| `added` | `:standup-added:` | unplanned work that happened | no |

`missed` vs `cut` comes down to one question: will it show up again in today's list? If yes, it's `missed`. If not, it's `cut`.

## Links

The script expands Linear keys like `ABC-123` (for the configured `teamKeys`), `repo#123` (a PR in the configured `githubOrg`), and bare GitHub PR or Linear issue URLs into short links. Write those forms and let it do the rest. Write any other link as `[short label](url)`, for example a Notion doc as `[planning notes](https://www.notion.so/...)`.

When an item clearly refers to a ticket, PR or doc you found in step 2, add the reference: an ID in the item text, or a link in a sub-bullet. Ask before adding more than a couple; a standup full of links is hard to read.

## 1. Find the threads

1. Today's thread: `slack_read_channel` on `slack.channel` with `oldest` set to midnight local time today. The parent is a workflow message containing `slack.threadMarker`; keep its `ts`. If there isn't one yet, carry on and finish with the clipboard only.
2. Last standup: `slack_search_public_and_private` with `filters: "from:<@KYLE_USER_ID> in:<#CHANNEL> is:thread before:<today>"`, `keywords: ["today"]`, `sort: "timestamp"`. Take the newest hit; its permalink has the parent `thread_ts`. Read that thread with `slack_read_thread` to get the raw mrkdwn of Kyle's reply. Search results drop the formatting. Note the date it was posted as `SINCE`.

With the `pull` argument, write that raw reply to `~/standups/<SINCE>.md`, say so in one line, and stop. The terminal `standup` script will review it next.

## 2. Gather evidence since the last standup

Run these together, with `ORG` from `githubOrg`:

```sh
gh search prs --owner ORG --author @me --updated ">=SINCE" --json title,url,state,repository --limit 30
gh search prs --owner ORG --merged-at ">=SINCE" --author @me --json title,url,repository --limit 30
gh search prs --owner ORG --reviewed-by @me --updated ">=SINCE" --json title,url,author,repository --limit 30
```

Also check Linear for issues assigned to `me` that changed state since `SINCE` (`list_issues`), and Notion for pages Kyle edited since then (`notion-search`). Treat all of this as hints. Kyle's own answers decide every status.

## 3. Review the plan

Parse the `today` section of the last standup into top-level items, each keeping its sub-bullets.

Ask about statuses with `AskUserQuestion`, up to 4 items per call. Each question is the item text, and the options are `Done`, `Partway`, `Didn't get to it`, `Cut`. When the evidence points one way (say, a matching PR merged), put that option first and mark it `(Recommended)`. A `Cut` needs a reason: use the note Kyle gave, or ask for one in a follow-up. A note on any other answer becomes a sub-bullet.

Then ask one `multiSelect` question listing likely unplanned work from the evidence that doesn't match a planned item. Kyle can type more through "Other".

## 4. Plan today

Show the carry-overs (`partial` and `missed` items, with their original sub-bullets), then ask in plain chat what else is on for today. He often dictates. Tidy what he says into his voice, staying close to his own words:

- lowercase, except names, products, and "I"
- terse fragments, not sentences
- number emoji for milestones (`Milestone :one:`), time in parens (`meetings (1h)`), `(stretch)` prefix for nice-to-haves
- context goes in sub-bullets under the item it explains

## 5. Render and draft

Write the result as JSON to a scratch file. `previousDate` is `SINCE`; the script turns it into `yesterday` or a weekday name like `Friday`.

```json
{
  "previousDate": "YYYY-MM-DD",
  "reviewed": [{ "text": "...", "status": "done|partial|missed|cut|added", "notes": ["..."] }],
  "today": [{ "text": "...", "notes": ["..."] }]
}
```

```sh
standup --render < standup.json              # Slack mrkdwn: saved to ~/standups/, copied to clipboard
standup --render --markdown < standup.json   # same content as standard markdown, for the draft
```

Create the draft with `slack_send_message_draft` in `slack.channel`, setting `thread_ts` to today's parent and passing the `--markdown` output. Never send it. If the draft call fails (for example `attached_draft_exists`), say so; the mrkdwn version is already on the clipboard. End with the mrkdwn text and the draft link.
