# Containerfile for Opentofu.
# Building
# >podman build -t alpine-tofu:1.9 -f Containerfile.tofu .
# Dev instructions
# >podman run --rm alpine-tofu:1.9 tofu --version
# >podman run --rm -v "./tfenv/local:/workspace" --env-file .env_kc alpine-tofu:1.9 tofu init
# git add ./tfenv/local/.terraform.lock.hcl
# generate file vars ./tfenv/local/local.tfvars
# and setup environment variables for tofu TF_VAR_* to be used with file vars for tfenv/local/variables.tf
# >podman run --rm -v "./tfenv/local:/workspace" --env-file .env_kc alpine-tofu:1.9 tofu plan
# >podman run --rm -v "./tfenv/local:/workspace" --env-file .env_kc alpine-tofu:1.9 tofu plan -var-file=local.tfvars
# >podman run --rm -v "./tfenv/local:/workspace" --env-file .env_kc alpine-tofu:1.9 tofu apply -var-file=local.tfvars

FROM ghcr.io/opentofu/opentofu:minimal AS tofu
FROM alpine:3.20
COPY --from=tofu /usr/local/bin/tofu /usr/local/bin/tofu
# prevent tofu interactivity for CI and to keep it simple
ENV TF_INPUT=0
#RUN apk add --no-cache git curl
WORKDIR /workspace
