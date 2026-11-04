# Orchino
## Introduction
[SORESPO](https://github.com/stratoweave/sorespo) is our primary
example on how to implement your own orchestrator. If you have not yet read
through the SORESPO documentation and its [tutorials](https://github.com/stratoweave/sorespo/docs/tutorials/README.md),
we strongly recommend you start there. When you are ready to design your own
Orchestron-based orchestrator, we recommend you fork SORESPO and modify it to
fit your needs.

But, we also very much understand that the SORESPO project with its many bells
and whistles can be a little overwhelming when you are just starting out with
developing for Orchestron. That's where Orchino comes in. Use this project as
a playground for your first baby steps with the platform.

##  Getting Started
Orchino is really just a stripped-down version of SORESPO, so all the same
principles still apply here.

The default `stable` branch works with the *stable* Acton release and the latest
StratoWeave release, while development happens on `main`. See
[Development](#development) for how the two branches relate.

Whenever you have modified the YANG models, re-generate the Acton modules for
your service layers:
```shell
make gen
```

Whenever you have modified the transform code, rebuild:
```shell
make build
```

Throughout your development, run the `quicklab-notconf` test environment:
```
cd test/quicklab-notconf
make start copy run-and-configure
```

Note: if you have the XRd image, try the `quicklab` instead.

## Files to explore
The key files you may want look into and or modify are:
* `gen/src/orchino_gen.act` which you'll see reference:
  * `spec/yang/cfs/netinfra.yang`
  * `spec/yang/rfs/orchino-rfs.yang`
  * `spec/yang/rfs/CiscoIosXr_24_1_ncs55a1/*`
* `src/orchino/cfs.act`
* `src/orchino/rfs.act`

## Development
The development branch is `main`. It depends on the `main` branch of
StratoWeave, which is upgraded automatically as StratoWeave changes, and CI
tests it with the Acton *tip* release. StratoWeave and Acton both change often,
including backwards incompatible changes, so `main` may need unreleased
versions of both.

The `stable` branch is for users, and works with the *stable* Acton release and
the latest StratoWeave release. Its content is `main` with the `stratoweave`
dependency in `spec/Build.act` pinned to the release tag, and the code
regenerated with `make gen`. On every push to `main`, the
[Advance stable branch](.github/workflows/advance-stable.yml) workflow makes
this change, builds and tests the result with *stable* Acton, and commits it to
`stable` if it passes. The commit has both the previous `stable` and `main` as
parents, so `stable` only moves forward and `git pull` keeps working on a clone
of it. Once `main` relies on a change in StratoWeave or Acton that is not in a
release yet, `stable` stops advancing until the next release.

The default branch in this repository is set to `stable`, so anyone that clones
this repository gets this branch. GitHub also uses the default branch as the
base for pull requests, but a pull request that targets `stable` must not be
merged, so the [Retarget stable pull requests](.github/workflows/retarget-stable-prs.yml)
workflow changes its base branch to `main` and comments in the PR with an
explanation.

Note: The Retarget stable pull requests workflow and Dependabot read their
configuration from the default (`stable`) branch, so changes to them take
effect once they reach `stable`.
