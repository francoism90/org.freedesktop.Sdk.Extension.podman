# org.freedesktop.Sdk.Extension.podman

This repository provides the Flatpak [Podman](https://podman.io/) extension: `org.freedesktop.Sdk.Extension.podman`.

Numerous attempts were made to include this SDK upstream, but they were [rejected](https://github.com/flathub/flathub/pull/8677) unfortunately.

Instead, this extension is built with [Flatter](https://github.com/andyholmes/flatter) using GitHub Actions and is signed with a GPG key. Please note that you use this extension at your own risk. Alternatively, you can build the extension yourself using Flatpak Builder (see Build instructions).

## Quick Start

Add the remote repository:

```bash
flatpak --user remote-add --if-not-exists francoism90-podman https://francoism90.github.io/org.freedesktop.Sdk.Extension.podman/index.flatpakrepo
```

Update the repository:

```bash
flatpak update
```

Install the extension:

```bash
flatpak install --user francoism90-podman org.freedesktop.Sdk.Extension.podman
```

> Note: The extension will automatically update when you run `flatpak update`.

### Build

It is possible to build the extension yourself using [Flatpak Builder](https://flathub.org/en/apps/org.flatpak.Builder).

Git clone the repository:

```bash
git clone https://github.com/francoism90/org.freedesktop.Sdk.Extension.podman.git
cd org.freedesktop.Sdk.Extension.podman
```

Use `org.flatpak.Builder` to build and install the extension:

```bash
flatpak run org.flatpak.Builder --install --user --force-clean --repo=repo build-dir org.freedesktop.Sdk.Extension.podman.yml
```

## Usage

To use the Podman SDK, enable the environment variable for your target application:

```bash
FLATPAK_ENABLE_SDK_EXT=podman
```

For applications that require Podman socket support, enable the user service and grant the application read-only filesystem access to the socket:

```bash
systemctl --user enable podman.socket --now
```

Grant socket access to your Flatpak app (replace app-id):

```bash
flatpak override --user --filesystem=xdg-run/podman:ro app-id
```

The socket path will then be available inside the Flatpak application at:
`$XDG_RUNTIME_DIR/podman/podman.sock`

### Forcing podman-remote

The `podman` command provided by this extension is a wrapper script. By
default it runs the local `podman` binary. Set `PODMAN_FLATPAK_FORCE_REMOTE`
(to any non-empty value) to make it transparently redirect to
`podman-remote` instead, for example when only a remote/socket-based Podman
connection is usable:

```bash
export PODMAN_FLATPAK_FORCE_REMOTE=1
podman ps   # actually runs podman-remote ps
```

### PhpStorm

To use this extension with [PhpStorm](https://github.com/flathub/com.jetbrains.PhpStorm):

1. Set the connection type to **Podman** in the settings.
2. If required for full container integration, explicitly set the Podman socket path to: `$XDG_RUNTIME_DIR/podman/podman.sock`

### Visual Studio Code / VSCodium

To use with [VSCode](https://github.com/flathub/com.visualstudio.code), first allow access to the Podman socket:

```bash
flatpak override --user --filesystem=xdg-run/podman:ro com.visualstudio.code
```

Open VSCode, run the command `Preferences: Open User Settings (JSON)`, and append the following configuration:

```json
"containers.composeCommand": "/usr/lib/sdk/podman/bin/podman-compose",
"containers.containerCommand": "/usr/lib/sdk/podman/bin/podman-remote",
"dev.containers.dockerComposePath": "/usr/lib/sdk/podman/bin/podman-compose",
"dev.containers.dockerPath": "/usr/lib/sdk/podman/bin/podman-remote",
"dev.containers.dockerSocketPath": "/run/user/<UID>/podman/podman.sock",
"docker.dockerPath": "/usr/lib/sdk/podman/bin/podman-remote"
```

> **Note:** Replace `<UID>` with your actual user ID running the socket (you can find this by running `id -u` in your terminal).

Restart the editor to apply the changes.

### Devcontainers

Update your project's `devcontainer.json` file with `runArgs` optimized for Podman:

```json
{
  "runArgs": ["--userns=keep-id", "--init"]
}
```

#### Optional Flags

- Append `--network=systemd-networkname` to allow network communication between containers.
- Append `--security-opt=label=disable` to prevent SELinux from restricting filesystem labels.

If certain devcontainer images fail to build, you may need to force the Docker format during the build step:

```json
{
  "runArgs": ["--userns=keep-id", "--init"],
  "build": {
    "options": ["--format=docker"]
  }
}
```
