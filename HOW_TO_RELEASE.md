# How to release a new version?

### 1st commit
1. After making all changes, run `pnpm build` to build the project if changes are applied in `src/`
2. Commit the changes by `git commit` where the commit message must start with `fix: `, `feat: ` or `chore: `

### 2nd commit
1. Update version in `package.json`
2. Run `pnpm tag` to append the latest tag to the commit
3. Update `publish_note.json` to describe eg. `"v1.0.0": "The very first stable version"`
4. Run `pnpm release` to update `CHANGELOG.md`
5. Run `npm publish` to publish to NPM
6. Commit the changes. Commit message must start with Release, eg. `Release: 1.0.0`
7. Push the changes to remote