---
label: Adding a Page
icon: dot
order: 80
---

Adding pages with Retype is easy! Each page is its own `.md` file. You can create a new branch in your fork of the wiki if it helps you stay organized.

When naming the pages filename please use dashes in place of spaces. We recommend looking at other pages in the wiki as examples.

At the top of every page you should have something similar to the following. We will call this the pages meta section.

```markdown
---
label: Page Title
icon: dot
order: 100
---
```

The label will be used in the sidebar of the left of the page and at the top of your page. There are times when you may want a shorter label than the title of page. In this case you can use 'title':

```markdown
---
label: Short Sidebar Text
title: Longer More Descriptive Title
icon: dot
order: 100
---
```

For pages located at the third level please set the `icon` to `dot`. An example of this our [page on WireGuard](/guides/virtual-private-networks/wireguard/).

Below the meta section ensure you have a single newline and then begin your content. For example:

```markdown
---
label: Page Title
icon: dot
order: 100
---

Content goes here...
```

See? It's easy!

Retype uses Markdown syntax for text styles, formatting, hyperlinks, and all kinds of stuff. You can learn more about how to configure a page in the [Retype documentation](https://retype.com/configuration/page/). You can also learn more about the different types of components that Retype supports [here](https://retype.com/components/) - there's a lot!

If you want more information on how to use Markdown syntax in content, we recommend [this page](https://retype.com/guides/formatting/) and [this one](https://daringfireball.net/projects/markdown/basics).

Once you've finished your work push it to your fork and then [create a pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request)!
