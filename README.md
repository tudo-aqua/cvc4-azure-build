[![Azure DevOps builds](https://img.shields.io/azure-devops/build/tudo-aqua/cvc4-azure-build/2?logo=azure-pipelines)](https://dev.azure.com/tudo-aqua/cvc4-azure-build)

### The CVC4 Azure Build

[CVC4](https://cvc4.github.io/) is a modular SMT solver that wraps numerous other open source packages. Unfortunately,
the authors only provide static binary builds of the solver executable, making reuse difficult. This project aims to use
Azure Pipelines to provide these artifacts.

#### Overview

A build control script is provided in `build.sh`. The script does not parse parameters, but is controlled using the
following environment variables:

* `BUILD_NAME` sets the build environment. On Azure, this is set to the VM image name. If unset or set to `local`, a
  local build without preparation is performed.
* `CVC4_VERSION` sets the version (i.e., git tag) of CVC4 to build.
* `UBUNTU_MIRROR` is required on Azure VMs lacking [SWIG 4](http://www.swig.org/) and defines an Ubuntu source
  repository.
* `SWIG_VERSION` is required on Azure VMs lacking [SWIG 4](http://www.swig.org/) and sets the SWIG version to package.
* `SWIG_BUILD` is required on Azure VMs lacking [SWIG 4](http://www.swig.org/) and sets the SWIG debian packaging to
  use.
 
The build script the performs the following steps:

1. Preparation: The build environment is prepared:
   * On `ubuntu-latest` VMs, [SWIG 4](http://www.swig.org/) is installed or built and installed, if necessary.
   * On `macOS-latest` VMs, [automake](https://www.gnu.org/software/automake/) and
   [coreutils](https://www.gnu.org/software/coreutils/) are installed and added to the `PATH`.
   * On `local` build, nothing happens.
2. CVC4 preparation: CVC4 is checked out from git. Then, the patch is applied. At the moment:
   * An install script for [CLN](https://www.ginac.de/CLN/) is added.
   * A workaround for Mac OS's intentionally broken `<experimental/optional>` header is added to the
     [drat2er](https://github.com/alex-ozdemir/drat2er) install script.
   * A workaround for Mac OS calling `libtoolize` `glibtoolize` is added to the
     [glpk-cut-log](https://github.com/timothy-king/glpk-cut-log) install script.
   * [GMP](https://gmplib.org/) is compiled as a position-independent binary, includes all optimized assembly paths,
     and selects optimal paths at runtime.
   * The script-installed version of [GMP](https://gmplib.org/) is preferred for building.
   * Shared object versioning is disabled.
   * The SWIG file lists in the CMake configuration are fixed.
   * The SWIG-generated Java sources and the native support libraries are installed by `make install`.
3. All dependency install scripts are run.
4. Two versions of CVC4, one with GPL-licensed libraries and one without, are built and installed locally.
5. The installed files are postprocessed. All debug information is stripped and on Mac OS, `@rpath` is replaced by
   `@loader_path` in the linkage specification.

#### License

CVC4 and its dependencies are licensed under various licenses. The support files in this project are licensed under the
[ISC License](https://opensource.org/licenses/ISC).