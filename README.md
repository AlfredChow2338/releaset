# Releaset

Releaset is designed to automatically generate changelogs for your repositories by CLI.

## Why Releaset?

- <b>Auto Changelogs</b>: Generate changelogs based on git tag and git commit history.
- <b>CICD Friendly</b>: Embed the command in your CICD work flow to update changelogs automatically.
- <b>Pre-release Friendly</b>: Support pre-relase and production publishing.

## Prerequisites

Ensure your project uses semantic versioning for git tags.

## Example

Run this in your project:
```
npx releaset --project releaset --repoUrl https://github.com/AlfredChow2338/releaset
```


## Installation

No installation is needed. We suggest use the `npx releaset` command for ease. 

## Pre-release version

The script will create a changelog file inside the .releaset directory:

- Pre-release mode: CHANGELOG_PR.md
- Production mode: CHANGELOG.md

`info.json` will also be created under .releaset directory to record all releaset information. <b>No change is needed.</b>