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
