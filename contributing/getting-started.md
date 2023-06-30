---
label: Getting Started
icon: dot
order: 100
---

This guide will show you how to setup a local environment for you to edit, create, or update content! Please note, if you wish to make a simple edit, you can always submit a quick pull request by utilizing the edit button on the file in question directly on the [GitHub repo online](https://github.com/r-selfhosted/wiki).

## Installing Retype

Since we are using [Retype](https://retype.com), getting a local copy of the wiki up and running is fairly simple.

### OS Independent

Since Retype is cross-platform, and OS choice is far from uniform in this community, I won't go into how to get Retype functioning on your OS of choice. Follow the [Getting Started](https://retype.com/guides/getting-started/) documentation. Once you can successfully get a version number from the command `retype version`, you're ready to continue.

!!!warning
At the time of writing it appears [Retype supports macOS ARM64](https://retype.com/guides/getting-started/#macos) however I've been unable to get it to work.
!!!

### Fork the Repository

First thing you'll want to do is create a fork of the [/r/SelfHosted wiki repository](https://github.com/r-selfhosted/wiki). Your work will be done within this fork.

4. Run the server locally with the following command:
    ```bash
    retype start --host 0.0.0.0
    ```
    You should see some output about the success/launch of the local server, similar to below:
    ```
    INPUT: /home/jimmy/Developer/github.com/r-selfhosted/wiki
    OUTPUT: [in-memory]
    Retype finished in 3.5 seconds!
    13 pages built
    0 errors
    3 warnings

    View at http://127.0.0.1:5000/
    Press Ctrl+C to shut down
    ```
    Navigate your web browser to `http://localhost:5000` and you should see the wiki. The wiki will be rebuilt and the pages will refresh automatically in your browser when you save them in your editor. You're now ready to start adding or modifying content!
