---
label: File Structure
title: Folder and File Structure
icon: dot
order: 90
---

Retype's file structure is very simple. The current wiki uses Markdown files for pages and `index.yml` files for folder-level navigation metadata.

This snapshot shows the main content structure as of June 2026. The wiki may have changed by the time you read this page, so use it as a guide rather than an exhaustive list.

```
.
|-- _components/
|   `-- icon/
|       `-- fa/
|-- _includes/
|-- contributing/
|   |-- adding-a-page.md
|   |-- file-structure.md
|   |-- getting-started.md
|   |-- index.yml
|   |-- modifying-a-page.md
|   `-- style-guide.md
|-- guides/
|   |-- hardware/
|   |   |-- coming-soon.md
|   |   `-- index.yml
|   |-- misc/
|   |   |-- fixing-harddrive-error-icon-in-dell-omsa.md
|   |   `-- index.yml
|   `-- software/
|       |-- devops-toolchains/
|       |   |-- gitlab-kubernetes.md
|       |   `-- index.yml
|       |-- reverse-proxy-servers/
|       |   |-- index.yml
|       |   |-- nginx.md
|       |   `-- what-are-reverse-proxies.md
|       |-- virtual-private-networks/
|       |   |-- index.yml
|       |   `-- wireguard.md
|       |-- web-hosting/
|       |   |-- apache.md
|       |   |-- getting-a-free-domain-and-tls-certificates.md
|       |   |-- how-to-host-websites.md
|       |   |-- index.yml
|       |   `-- nginx.md
|       `-- index.yml
|-- learn/
|   |-- common-terms-and-concepts.md
|   |-- difficulty-tiers.md
|   |-- index.yml
|   |-- operating-systems.md
|   |-- self-hosted-alternatives-to-popular-services-and-providers.md
|   `-- what-is-self-hosting.md
|-- static/
|-- index.md
`-- retype.yml
```

When adding a page, place it in the folder that best matches the topic. If no folder fits, create a new folder only when it will be useful for more than one page.
