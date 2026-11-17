**target_compile_features**

> comando nativo do CMake, não precisa de include

O `target_compile_features` declara o padrão mínimo de C que um target exige, e o CMake escolhe a flag `-std` que atende esse mínimo

```cmake
target_compile_features(<target> <PRIVATE|PUBLIC|INTERFACE> <feature>...)
```

- `target`: o target. Precisa ter sido criado antes
- `PRIVATE`, `PUBLIC`, `INTERFACE`: `PUBLIC` exige o mesmo mínimo de quem linka o target, útil quando os headers públicos usam recursos do padrão
- `feature`: `c_std_90`, `c_std_99`, `c_std_11`, `c_std_17` ou `c_std_23` (3.21+)

- É um mínimo, e não um valor fixo. Se dois targets ligados pedem padrões diferentes, vale o maior
- Se o padrão do compilador já atende o mínimo, nenhuma flag é adicionada
- Para fixar o padrão de todo o projeto, `set(CMAKE_C_STANDARD 17)` é mais simples (ver `functions/projeto/set.md`)

```cmake
add_library(lista STATIC lista.c)
target_compile_features(lista PUBLIC c_std_11)   # lista.h usa _Static_assert

add_executable(app main.c)
target_link_libraries(app PRIVATE lista)         # o app também compila com C11 ou mais novo
```
