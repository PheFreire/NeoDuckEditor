**foreach**

> comando nativo do CMake, não precisa de include

O `foreach` repete um bloco de comandos para cada item de uma lista, sendo usado para criar vários targets parecidos sem repetir os mesmos comandos

```cmake
foreach(<variável> <item>...)
foreach(<variável> IN LISTS <lista>... ITEMS <item>...)
foreach(<variável> RANGE <início> <fim> [<passo>])
    ...
endforeach()
```

- `variável`: recebe o item atual a cada volta
- `item`: os itens escritos direto no comando
- `IN LISTS`: percorre o conteúdo de variáveis de lista, passadas pelo nome e sem `${}`
- `RANGE`: percorre os números de `início` até `fim`, incluindo o `fim`

- `break()` sai do laço e `continue()` (3.2+) pula para o próximo item

```cmake
set(EXEMPLOS basico fila_dupla servidor_eco)

foreach(nome IN LISTS EXEMPLOS)
    add_executable(${nome} exemplos/${nome}.c)
    target_link_libraries(${nome} PRIVATE lista)
endforeach()
# cria os targets basico, fila_dupla e servidor_eco
```
