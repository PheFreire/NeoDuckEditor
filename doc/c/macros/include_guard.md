**Include guard**

> diretiva do pré-processador, não precisa de nenhum header

O include guard é um padrão com `#ifndef`, `#define` e `#endif` colocado em volta de todo o conteúdo de um header, garantindo que ele seja processado só uma vez por arquivo `.c`, mesmo que seja incluído várias vezes direta ou indiretamente

> O `#include` também é feito pelo pré-processador e apenas copia o conteúdo do arquivo incluído para o lugar da diretiva. Se o mesmo header for incluído duas vezes, todo o seu conteúdo aparece duas vezes, e definições de `struct`, `enum` ou `typedef` repetidas geram erro de redefinição

```c
#ifndef NOME_DO_ARQUIVO_H
#define NOME_DO_ARQUIVO_H

// conteúdo do header

#endif // NOME_DO_ARQUIVO_H
```

- `NOME_DO_ARQUIVO_H`: um nome único para cada header, normalmente o nome do arquivo em maiúsculas, trocando `.` e `/` por `_` (`utils/lista.h` vira `UTILS_LISTA_H`)
- Na primeira inclusão, a macro ainda não existe: o `#ifndef` é verdadeiro, a macro é definida e o conteúdo é mantido
- Nas inclusões seguintes, a macro já existe: o `#ifndef` é falso e todo o conteúdo é apagado

- Os nomes não devem começar com `_` seguido de maiúscula (`_LISTA_H`) nem conter `__`, pois esses são reservados para o compilador e a biblioteca padrão
- Se dois headers diferentes usarem o mesmo nome de guard, o segundo é apagado sem nenhum aviso, o que causa erros confusos de "tipo não declarado"

**O problema sem o guard**

```c
// ponto.h
struct ponto {
  int x;
  int y;
};

// linha.h
#include "ponto.h"
struct linha {
  struct ponto a;
  struct ponto b;
};

// main.c
#include "ponto.h"
#include "linha.h" // inclui ponto.h de novo

// erro: redefinition of 'struct ponto'
```

**Com o guard**

```c
// ponto.h
#ifndef PONTO_H
#define PONTO_H

struct ponto {
  int x;
  int y;
};

#endif // PONTO_H
```

Agora, quando `linha.h` inclui `ponto.h` pela segunda vez, `PONTO_H` já está definida e o conteúdo é apagado

**#pragma once**

Uma alternativa de uma linha só, que pede ao compilador para não incluir o arquivo mais de uma vez:

```c
// ponto.h
#pragma once

struct ponto {
  int x;
  int y;
};
```

- Não precisa inventar um nome único, então não tem o risco de dois headers usarem o mesmo guard
- Não faz parte do padrão C, mas é suportado por todos os compiladores populares (GCC, Clang, MSVC)
- Identifica o arquivo pelo caminho no disco, então pode falhar em casos raros, como o mesmo arquivo acessível por dois caminhos diferentes (links simbólicos, pastas de rede)

> Diferente do `#pragma once`, o include guard com `#ifndef` é 100% padrão e funciona em qualquer compilador, por isso continua sendo o mais usado em bibliotecas. Em projetos próprios, os dois funcionam e a escolha é de estilo. O que não pode é um header sem nenhum dos dois
