**#undef**

> diretiva do pré-processador, não precisa de nenhum header

O `#undef` apaga uma macro definida antes com `#define`, fazendo com que, das linhas seguintes em diante, o nome deixe de ser substituído e volte a ser um identificador comum

> Uma macro vale da linha do seu `#define` até o fim do arquivo, sem respeitar chaves nem funções. O `#undef` é a única forma de limitar até onde ela vale

```c
#undef NOME
```

- `NOME`: o nome da macro a ser apagada, sem parâmetros, mesmo que ela tenha sido definida com eles

- Dar `#undef` em um nome que não é uma macro não é erro, simplesmente não faz nada
- Redefinir uma macro com um texto diferente sem dar `#undef` antes gera um aviso (ou erro) de redefinição. Com o `#undef` no meio, a redefinição é limpa

**Limitando uma macro a um trecho**

Uma macro auxiliar usada só em um pedaço do arquivo pode ser apagada logo depois, evitando que o nome vaze para o resto do código (ou para quem incluir o header):

```c
#define CAMPO(nome) printf(#nome " = %d\n", p.nome)

void imprimir(struct ponto p) {
  CAMPO(x);
  CAMPO(y);
}

#undef CAMPO
// a partir daqui, CAMPO volta a ser um nome livre
```

**Redefinindo uma macro**

```c
#define TAMANHO 10
int a[TAMANHO]; // int a[10];

#undef TAMANHO
#define TAMANHO 20
int b[TAMANHO]; // int b[20];
```

**Removendo uma macro que conflita com um nome seu**

Alguns headers definem macros com nomes comuns. O `#undef` permite usar o nome para outra coisa:

```c
#include <algum_header.h> // define uma macro chamada max

#undef max

int max(int a, int b) { // agora é uma função normal
  return a > b ? a : b;
}
```

> Diferente de uma variável, que some ao sair do bloco `{ }` onde foi declarada, uma macro continua valendo até o fim do arquivo. Por isso, toda macro auxiliar definida no meio de um arquivo ou de um header deve ser apagada com `#undef` assim que deixa de ser necessária
