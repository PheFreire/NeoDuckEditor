**djb33**

É uma variação do `djb2` que troca a soma do caractere pela operação XOR (`h ^= *s++`), mantendo a mesma base de multiplicação por 33 feita via shift

- Velocidade: tão rápido quanto o `djb2`, com o mesmo custo de shift e um XOR no lugar de uma soma
- Qualidade: em alguns benchmarks apresenta uma distribuição um pouco melhor que a do `djb2` original, já que o XOR mistura melhor os bits que a soma em certos padrões de entrada
- Quando usar: no mesmo cenário do `djb2`, como uma alternativa quase idêntica quando vale a pena testar se o XOR melhora a distribuição para o conjunto de dados específico
- Observação: assim como o `djb2`, não é resistente a colisões propositais

```c
uint32_t djb33_hash(const char* s, size_t len) {
    uint32_t h = 5381;
    while (len--) {
        h += (h << 5);  
        h ^= *s++;
    }
    return h;
}
```

