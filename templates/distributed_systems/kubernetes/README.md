## Minimal Kubernetes setup

- [ ] https://oneuptime.com/blog/post/2026-03-18-use-podman-desktop-kind-clusters/view
- [ ] Overview of sane options with trade-offs
- [ ] Basic nix flake setup
- [ ] Running k3s
- [ ] Running apps docker compose

### Debugging

* https://samof76.space/kubernetes-in-anger.html Kubernetes Production Incident Debugging
  - interesting overview on operation complexity
* [Discussion with context](https://lobste.rs/s/iggblv/kubernetes_anger)

### Usage

https://oneuptime.com/blog/post/2026-03-18-use-podman-desktop-kind-clusters/view

Podman desktop has hacks to make podman work with minimal setup in WSL, but no
architectural improvements. Docker has only minor ones allowing cross-WSL
filesystem access.
