# r/SelfHosted Wiki

## 🎉 Welcome!

This is the official GitHub repository for the [r/SelfHosted](https://www.reddit.com/r/selfhosted/) wiki.

## 📖 Learning

If you want to learn more about self hosting, start [here](https://wiki.r-selfhosted.com).

## 👷 Contributing

If you would like to contribute please visit [this page](https://wiki.r-selfhosted.com/contributing/getting-started/).

## Custom Icons

Retype custom icons live in `_components/icon/<pack>/<name>.svg` and are referenced in `retype.yml` as `<pack>-<name>`. For example, `_components/icon/fa/discord.svg` is used with `icon: fa-discord`.

Retype renders custom icons inside a `24x24` SVG wrapper. Font Awesome icons usually use a larger viewBox, such as `0 0 640 640`, so they must be normalized before Retype builds the site.

Run the icon normalizer after adding or replacing custom SVG icons:

```bash
bash scripts/normalize-icons.sh
```

The Docker build runs this script automatically before `retype build`, so deployed builds normalize icons as part of the normal build process.
