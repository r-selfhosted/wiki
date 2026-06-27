---
label: Style Guide
icon: dot
order: 60
---

Read about our best practices for writing and formatting content on the r/SelfHosted wiki!

## Writing Style

Write for people who are learning. Keep the tone friendly, practical, and direct. Prefer plain language over jargon, and explain technical terms the first time they appear if a beginner may not know them.

Use complete sentences and standard punctuation. Avoid long paragraphs; two to four sentences is usually enough before a new paragraph or heading helps.

## Page Structure

Start each page with Retype front matter. Use a clear `label`, set `icon: dot` for regular pages, and use `title` when the full page title should be longer than the sidebar label.

Use headings to make pages easy to scan. Keep heading levels in order, and avoid skipping from `##` to `####`.

## Links and References

Use descriptive link text. For example, write "read the Retype formatting guide" instead of "click here."

Prefer internal links for other wiki pages. Use lowercase paths and include the trailing slash for page links, such as `/guides/software/virtual-private-networks/wireguard/`.

When linking to external documentation, choose stable official sources whenever possible.

## Code and Commands

Use fenced code blocks for commands, configuration, and longer examples. Add a language tag when one applies:

```bash
npm run build
```

Use inline code for filenames, commands, package names, and configuration keys.

## Content Quality

Before opening a pull request, check that your page:

- Fits the section where you placed it.
- Uses accurate, current information.
- Explains any required prerequisites.
- Includes useful next steps or references when readers may need more detail.
- Builds or previews cleanly with Retype.
