# Releaset

Releaset is designed to automatically generate changelogs for your repositories by CLI.

## Why Releaset?

- <b>Auto Changelogs</b>: Generate changelogs based on git tag and git commit history.
- <b>CICD Friendly</b>: Embed the command in your CICD work flow to update changelogs automatically.
- <b>Pre-release Friendly</b>: Support pre-relase and production publishing.
- <b>Support Publish Note</b>: Update `.releaset/publish_note.json` manually set publish note for each version.

## Prerequisites

Ensure your project uses semantic versioning for git tags.

## Example

Releaset uses this command to generate logs:
```
npx releaset --projectUrl https://github.com/AlfredChow2338/releaset --title @Releaset --filterCommit Release
```

[CHANGELOG Example](https://github.com/AlfredChow2338/releaset/blob/main/CHANGELOG.md)

Project applied pre-release practice and want to publish production logs in `CHANGELOG.md`:
```
npx releaset --projectUrl {PROJECT_URL} \
  --title {LOG_FILE_TITLE}
  --prTag {PR_TAG}
```

Project applied pre-release practice and publish pre-release logs in `CHANGELOG_PR.md`:
```
npx releaset --projectUrl {PROJECT_URL} \
  --title {LOG_FILE_TITLE}
  --prTag {PR_TAG} \
  --pr
```

Include tags that contain specific keywords:
```
npx releaset --projectUrl {PROJECT_URL} \
  --title {LOG_FILE_TITLE}
  --filterTag {FILTER_TAG}
```
Note: Support version >= 0.1.9 `filterTag` can be more than one, which has to be separate by commas (eg. tag1,tag2,tag3)

Exclude tags that contain specific keywords:
```
npx releaset --projectUrl {PROJECT_URL} \
  --title {LOG_FILE_TITLE}
  --filterOutTag {FILTER_TAG}
```
Note: Support in version >= 0.2.0 `filterOutTag` can be more than one, which has to be separate by commas (eg. tag1,tag2,tag3)

Output logs to specified directory eg. `packages/foo`:
```
npx releaset --projectUrl {PROJECT_URL} \
  --title {LOG_FILE_TITLE}
  --outDir packages/foo
```

## Installation

No installation is needed. We suggest directly use the `npx releaset` command for ease. 

## Pre-release version

The script will create a changelog file:

- Pre-release mode: `CHANGELOG_PR.md`
- Production mode: `CHANGELOG.md`

`info.json` will also be created to record all releaset information. <b>No change is needed for this configuration file.</b>

## Publish note
`publish_note.json` will be created if arguements `ver` and `note` are passed. 

You can manually update `publish_note.json` to list the publish note in each version.

JSON Structure: `[TAG]: [PUBLISH_NOTE]`