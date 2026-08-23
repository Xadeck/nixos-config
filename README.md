# nixos-config

```shell
nixos-rebuild --sudo switch --flake ~/nixos-config#gmktec
```

```shell
nix flake update --flake ~/nixos-config 
```

## Caddy

Check systemd service:

```shell
systemctl status caddy.service
```

Check service logs:

```shell
journalctl -u caddy.service -n 20 --no-pager
```

Reload configuration after rebuilding or modifying Caddyfile:

```shell
sudo systemctl reload caddy
```

For local dev:

```shell
caddy run --config ~/nixos-config/caddy/Caddyfile.dev
```

## Time machine

```
journalctl -u podman-timemachine.service -n 20 --no-pager
```

The password to connect to the TimeMachine is not versioned but stored in
`/var/lib/secrets/timemachine.env`. The same password was used in TimeMachine
on the Macbook to encrypt the data.
