**fnv32**

É a versão de 32 bits do FNV (Fowler-Noll-Vo), um hash bastante usado em bibliotecas de sistemas, bancos de dados e protocolos de rede. Essa implementação é a variante FNV-1a, que faz o XOR do byte antes de multiplicar pelo primo mágico do FNV, em vez de multiplicar antes do XOR

- Velocidade: um pouco mais pesado que `djb2`/`h31`, pois usa uma multiplicação real a cada byte em vez de shifts, mas ainda assim considerado rápido
- Qualidade: um dos melhores avalanches entre os hashes não criptográficos simples, com distribuição consistente mesmo entre entradas parecidas entre si
- Quando usar: quando a qualidade da distribuição importa mais que economizar um ciclo de CPU, como em tabelas hash grandes ou sistemas onde colisões acidentais frequentes seriam um problema
- Observação: os parâmetros (primo e valor inicial) são padronizados e documentados oficialmente, então não devem ser alterados sem entender o impacto na distribuição

```c
uint32_t fnv32_hash(const char *str, size_t len)
{
    unsigned char *s = (unsigned char *)str;	/* unsigned string */

    /* See the FNV parameters at www.isthe.com/chongo/tech/comp/fnv/#FNV-param */
    const uint32_t FNV_32_PRIME = 0x01000193; /* 16777619 */

    uint32_t h = 0x811c9dc5; /* 2166136261 */
    while (len--) {
        /* xor the bottom with the current octet */
        h ^= *s++;
        /* multiply by the 32 bit FNV magic prime mod 2^32 */
        h *= FNV_32_PRIME;
    }
    
    return h;
}
```

