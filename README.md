### multi sub MAIN

```raku
multi sub MAIN(
    *@args
) returns Mu
```

Turn a spoken command request into a shell command and explanation. Prompt the user before executing.

### multi sub MAIN

```raku
multi sub MAIN(
    "help"
) returns Mu
```

show this help

### multi sub MAIN

```raku
multi sub MAIN(
    "config"
) returns Mu
```

configure defaults

