**bit fields**

> regra da linguagem, não precisa de header

Um bit field é um campo de struct que ocupa só a quantidade de bits indicada, e não o tamanho inteiro do seu tipo. Vários bit fields seguidos são agrupados dentro de um mesmo inteiro, economizando memória

```c
struct nome {
  tipo campo : largura;
};
```

- `tipo`: `unsigned int`, `signed int`, `int` ou `bool`. Outros tipos inteiros são extensão do compilador
- `largura`: quantos bits o campo ocupa, de `1` até o número de bits do tipo

- Um campo `unsigned` de `n` bits guarda de `0` até `2ⁿ - 1`
- Em um campo `int` puro, se ele tem sinal ou não depende do compilador. Use sempre `unsigned int` ou `signed int` de forma explícita

---

**Exemplo**

```c
struct flags {
  unsigned int ativo   : 1;  // 1 bit: 0 ou 1
  unsigned int visivel : 1;
  unsigned int nivel   : 4;  // 4 bits: 0 a 15
};                           // os três cabem em um único unsigned int

struct flags f = {.ativo = 1, .nivel = 9};

f.visivel = 1;
f.nivel = 16;  // não cabe em 4 bits: vira 0, sem nenhum erro
sizeof f;      // 4
```

- Um valor que não cabe na largura é truncado. Em campos `unsigned` ele dá a volta (`16` em 4 bits vira `0`)
- O acesso é igual ao de um campo normal, o compilador gera as máscaras e deslocamentos por baixo

---

**Campos sem nome**

```c
struct registro {
  unsigned int modo  : 3;
  unsigned int       : 5;  // 5 bits de espaço reservado, sem nome
  unsigned int canal : 4;
  unsigned int       : 0;  // largura 0: o próximo campo começa em um novo unsigned int
  unsigned int erro  : 1;
};
```

- Um campo sem nome reserva bits que não podem ser acessados
- Um campo sem nome de largura `0` força o próximo bit field a começar no início de um novo inteiro

---

**Limitações**

- Não é possível pegar o endereço de um bit field (`&f.ativo` é erro de compilação), então ele também não pode ser passado para `scanf` ou para uma função que recebe ponteiro
- `sizeof` e `offsetof` não funcionam em um bit field
- Ler e escrever um bit field é mais lento que um campo normal, pois exige máscaras e deslocamentos
- Bit fields vizinhos ficam no mesmo inteiro, então duas threads escrevendo em campos diferentes ao mesmo tempo podem apagar a escrita uma da outra

> A ordem dos bits dentro do inteiro, o tamanho do inteiro usado e o padding entre os grupos dependem do compilador e da arquitetura. Por isso bit fields não servem para formatos de arquivo, protocolos de rede e registradores de hardware que exigem uma posição exata. Nesses casos, use um inteiro de tamanho fixo (`uint32_t`) com máscaras feitas à mão usando `&`, `|`, `~` e `<<`
