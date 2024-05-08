# Contributing Guidelines

This repository automatically releases when an approved PR is merged. So please
adhere to these rules for a smooth fast PR approval.

**Rules**S

* follow the [Commit Message Format] described here. These commits will appear
  in the changelog and MUST be comprehensible by humans. 
* provide test where possible to ensure this continue to work.
* rebase your branch with latest `main` trunk as often as needed.

### Commit Message Format

Each commit message consists of a **header**, a **body** and a **footer**. The
header has a special format that includes a **type**, a **scope** and a
**subject**:

```
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

The **header** is mandatory and the **scope** of the header is optional.

Example — `fix: Error When Downloading VS Code Server`

Any line of the commit message cannot be longer 100 characters. This allows the
message to be easier to read on GitHub as well as in various git tools.

#### Type

Must be one of the following:

* **feat**: A new feature.
* **fix**: A bug fix.
* **docs**: Documentation only changes.
* **style**: Changes that do not affect the meaning of the code (white-space,
  formatting, missing semi-colons, etc).
* **refactor**: A code change that neither fixes a bug nor adds a feature.
* **perf**: A code change that improves performance.
* **test**: Adding missing tests.
* **chore**: Changes to the build process or auxiliary tools and libraries such
  as documentation generation.

#### Scope

The scope is optional and could be anything specifying place of the commit
change. For example `win32`, `mac`, `linux`, etc...

#### Subject

The subject contains succinct description of the change:

* use the past tense: `changed` or `changes` not `change` since the commit
  should accomplish what is described,
* Capitalize letters as you would in a header,
* no punctuation at the end.

#### Body

Briefly describe what the commit accomplishes, it should be done, so you past
tense, "changed" not "changes" not "change" as if your going to do it.

#### Footer

The footer should contain any information about **Breaking Changes** and is
also the place to reference GitHub issues that this commit **Closes**.


**Breaking Changes** should start with the word `BREAKING CHANGE:` with a
space or two newlines. The rest of the commit message is then used for this.

This document is based on [Conventional Commits].

[Conventional Commits]: https://www.conventionalcommits.org/en/v1.0.0/
[Commit Message Format]: #commit-message-format