# Releaset

Releaset is designed to automatically generate changelogs for your repositories by CLI.

## Why Releaset?

- <b>Auto Changelogs</b>: Generate changelogs based on git tag and git commit history.
- <b>CICD Friendly</b>: Embed the command in your CICD work flow to update changelogs automatically.
- <b>Pre-release Friendly</b>: Support pre-relase and production publishing.

## Prerequisites

Ensure your project uses semantic versioning for git tags.

## Example

Releaset uses this command to generate logs:
```
npx releaset --project AlfredChow2338/releaset --title @Releaset
```

![releaset example](https://github.com/AlfredChow2338/releaset/blob/main/assets/example.png?raw=true)

Project applied pre-release practice and want to publish production logs in `CHANGELOG.md`:
```
npx releaset --project {PROJECT_NAME} \
  --title {LOG_FILE_TITLE}
  --prTag {PR_TAG}
```

Project applied pre-release practice and publish pre-release logs in `CHANGELOG_PR.md`:
```
npx releaset --project {PROJECT_NAME} \
  --title {LOG_FILE_TITLE}
  --prTag {PR_TAG} \
  --pr
```

Export CHANGELOG which tags contain specific tag identifier:
```
npx releaset --project {PROJECT_NAME} \
  --title {LOG_FILE_TITLE}
  --filterTag {FILTER_TAG}
```

Output CHANGELOG to specified directory eg. `.releaset/`:
```
npx releaset --project {PROJECT_NAME} \
  --title {LOG_FILE_TITLE}
  --outDir .releaset
```

## Installation

No installation is needed. We suggest directly use the `npx releaset` command for ease. 

## Pre-release version

The script will create a changelog file:

- Pre-release mode: `CHANGELOG_PR.md`
- Production mode: `CHANGELOG.md`

`releaset-info.json` will also be created to record all releaset information. <b>No change is needed for this configuration file.</b>