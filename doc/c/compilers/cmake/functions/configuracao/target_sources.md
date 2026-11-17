**target_sources**

> comando nativo do CMake, não precisa de include

O `target_sources` adiciona arquivos de código a um target já criado, permitindo montar a lista de fontes aos poucos, conforme uma condição ou em outro `CMakeLists.txt`

```cmake
target_sources(<target> <PRIVATE|PUBLIC|INTERFACE> <fonte>...)
```

- `target`: o target que recebe os fontes. Precisa ter sido criado antes
- `PRIVATE`: o normal. Os fontes são compilados no próprio target
- `PUBLIC` / `INTERFACE`: os fontes também seriam compilados em quem linka o target, o que quase nunca é o desejado
- `fonte`: os `.c`, relativos ao `CMakeLists.txt` atual

```cmake
add_executable(app src/main.c)

if(WIN32)
    target_sources(app PRIVATE src/plataforma_win.c)
else()
    target_sources(app PRIVATE src/plataforma_posix.c)
endif()
```
