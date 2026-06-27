---
label: Adding a Page
icon: dot
order: 80
---

Adding pages with Retype is easy. Each page is its own `.md` file. Create a new branch in your fork of the wiki if it helps you stay organized.

When naming a page file, use lowercase words separated by dashes instead of spaces. For example, use `my-new-guide.md`, not `My New Guide.md`. We recommend looking at existing pages in the same section before choosing a name.

At the top of every page, include a front matter block similar to this:

```markdown
---
label: Page Title
icon: dot
order: 100
---
```

The `label` is used in the left sidebar and at the top of the page. If you want the sidebar label to be shorter than the full page title, use `title`:

```markdown
---
label: Short Sidebar Text
title: Longer More Descriptive Title
icon: dot
order: 100
---
```

For pages below a category folder, set the `icon` to `dot`. For example, see the [page on WireGuard](/guides/software/virtual-private-networks/wireguard/).

If you add a new folder to the navigation, include an `index.yml` file in that folder so Retype can set its sidebar label, icon, and order. Existing `index.yml` files are good examples.

## Custom Icons

Retype custom icons live in `_components/icon/<pack>/<name>.svg` and are referenced as `<pack>-<name>`. For example, `_components/icon/fa/discord.svg` is used with `icon: fa-discord`.

If you add or replace a custom SVG icon, run the icon normalizer before building or opening a pull request:

```bash
bash scripts/normalize-icons.sh
```

This keeps larger icon sets, such as Font Awesome, working correctly inside Retype's `24x24` icon wrapper.

Below the front matter block, leave one blank line before the page content. For example:

```markdown
---
label: Page Title
icon: dot
order: 100
---

Content goes here.
```

Retype uses Markdown syntax for text styles, formatting, hyperlinks, and other page content. You can learn more about page configuration in the [Retype documentation](https://retype.com/configuration/page/) and about supported Retype components in the [Retype components documentation](https://retype.com/components/).

If you want more information on how to use Markdown syntax in content, we recommend [this page](https://retype.com/guides/formatting/) and [this one](https://daringfireball.net/projects/markdown/basics).

Once you have finished your work, build or preview the site locally, push the branch to your fork, and then [create a pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request).
