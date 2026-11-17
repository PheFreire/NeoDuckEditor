**target_compile_options**

> comando nativo do CMake, não precisa de include

O `target_compile_options` adiciona flags de compilação a um target, sendo usado para warnings, sanitizers e flags do compilador que o CMake não gera por um comando próprio

```cmake
target_compile_options(<target> [BEFORE] <PRIVATE|PUBLIC|INTERFACE> <flag>...)
target_link_options(<target> <PRIVATE|PUBLIC|INTERFACE> <flag>...)
```

- `target`: o target que recebe as flags. Precisa ter sido criado antes
- `PRIVATE`, `PUBLIC`, `INTERFACE`: quase sempre `PRIVATE`. Warnings como `PUBLIC` seriam impostos a quem usa a biblioteca
- `flag`: as flags do compilador, como `-Wall` ou `-O2`
- `BEFORE`: coloca as flags antes das que o target já tem

- Só afeta a compilação. Flags de link vão no `target_link_options`, e flags que valem para os dois (como os sanitizers) precisam ir nos dois
- Não use para o que tem comando próprio: `-I` é `target_include_directories`, `-D` é `target_compile_definitions`, `-std` é `CMAKE_C_STANDARD` e `-l` é `target_link_libraries`
- Cada compilador tem flags diferentes. Para um projeto que também compila no MSVC, condicione com `$<$<C_COMPILER_ID:MSVC>:/W4>`

```cmake
target_compile_options(app PRIVATE -Wall -Wextra -Wpedantic -Wshadow)

target_compile_options(app PRIVATE -fsanitize=address,undefined -fno-omit-frame-pointer)
target_link_options(app PRIVATE -fsanitize=address,undefined)
```

> Para aplicar as mesmas flags em vários targets, crie uma biblioteca `INTERFACE` com elas e linke em cada um (ver `functions/targets/add_library.md`)
