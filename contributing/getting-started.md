---
label: Getting Started
icon: dot
order: 100
---

This guide shows you how to set up a local environment to edit, create, or update content. If you only want to make a small edit, you can also submit a quick pull request by using the edit button on the file in the [GitHub repository](https://github.com/r-selfhosted/wiki).

## Installing Retype

Because the wiki uses [Retype](https://retype.com), getting a local copy up and running is fairly simple.

### OS Independent

Retype is cross-platform, and operating system choice is far from uniform in this community. Follow the official [Retype Getting Started](https://retype.com/guides/getting-started/) documentation for your operating system. Once `retype version` returns a version number, you are ready to continue.

On macOS ARM64, this repository also includes an npm dependency for Retype. After cloning your fork, run:

```bash
npm install
```

### Fork the Repository

The first thing you'll want to do is create a fork of the [/r/SelfHosted wiki repository](https://github.com/r-selfhosted/wiki). Your work will be done within this fork.

Clone your fork, then start the local Retype server from the repository root:

```bash
retype start
```

You should see output similar to this. The exact page and warning counts may differ:

```console
INPUT: /home/jimmy/Developer/github.com/r-selfhosted/wiki
OUTPUT: [in-memory]
Retype finished in 3.5 seconds!
21 pages built
0 errors
2 warnings

View at http://127.0.0.1:5000/
Press Ctrl+C to shut down
```

Navigate to `http://localhost:5000` in your web browser. The wiki will rebuild and refresh automatically when you save pages in your editor.

Before opening a pull request, run a production build:

```bash
retype build
```

If you add or replace custom SVG icons, run the icon normalizer before building:

```bash
bash scripts/normalize-icons.sh
```

You are now ready to start adding or modifying content.
