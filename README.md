### The CVC4 Azure Build

[CVC4](https://cvc4.github.io/) is a modular SMT solver that wraps numerous other open source packages. Unfortunately,
the authors only provide static binary builds of the solver executable, making reuse difficult. This project aims to use
Azure Pipelines to provide these artifacts.

#### Structure

The build wrapper logic resides in `build.sh`, while necessary patches to the CVC4 sources are collected in the
`.patch` file. 

#### License

CVC4 is licensed under various licenses. The support files in this project are licensed under the
[ISC License](https://opensource.org/licenses/ISC).