Status of "customized" apps
===========================

* logreader
  - improve logging of exceptions
  - admin delegation is supported upstream in v24
* user_sql
  - admin delegation support
* text
  - done
* maps
  - that one is tricky. Because of some crazy "node-gyp" (what the
    hell is this?) incompatibilities it needs

    CXXFLAGS="-O3 -march=native -std=c++17"

    in the environment.
  - the master, well, is a complicated story. ATM it seems to build
    exactly with node v15 only.
* ldap_write_support
  * not a problem, cherry-picking from the old production branch just
    worked.

Rest is partly from git (no app store), but just can be compiled

