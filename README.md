# nixos-config

```shell
nixos-rebuild --sudo switch --flake ~/nixos-config#gmktec
```

```shell
nix flake update --flake ~/nixos-config 
```

## Podmand / caddy

Check systemd container service:

```
systemctl status podman-caddy.service
```

Check container logs (because NixOS runs system-level OCI containers as root):

```
sudo podman logs -f caddy
```

or without sudo:

```
journalctl -u podman-caddy.service -n 20 --no-pager
```

Because Caddyfile is mounted into the container, here is how Caddy handles updates:

│ [!IMPORTANT]
│ Simply editing and saving Caddyfile does NOT immediately publish changes live. Caddy caches its configuration in\
│ memory and only updates when explicitly told to reload.

```
caddy validate --config ~/nixos-config/caddy/Caddyfile && sudo podman exec caddy caddy reload
```

For local dev:

```
caddy run --config ~/nixos-config/caddy/Caddyfile.dev
```
