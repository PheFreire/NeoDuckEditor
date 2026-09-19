**oat**

É o "One-at-a-Time hash" de Bob Jenkins, um hash clássico desenhado especificamente para ter um bom avalanche, ou seja, para que uma pequena mudança na entrada já cause uma mudança grande e bem distribuída no resultado

- Velocidade: mais pesado que `djb2`/`h31`, pois faz três operações (soma, shift, XOR) por byte, além de uma etapa extra de mistura final antes de retornar
- Qualidade: excelente distribuição estatística, sendo um dos hashes simples mais respeitados em termos de qualidade, historicamente usado em bibliotecas como a do Perl
- Quando usar: quando a qualidade da distribuição é prioridade e vale a pena pagar o custo extra de CPU, por exemplo em tabelas hash onde colisões frequentes seriam custosas
- Observação: apesar de não ser criptográfico, sua boa mistura de bits o torna uma opção comum como base para outros hashes maiores, como o `lookup3` do próprio Jenkins

```c
uint32_t oat_hash(const char *s, size_t len)
{
    unsigned char *p = (unsigned char*) s;
    uint32_t h = 0;

    while(len--) {
        h += *p++;
        h += (h << 10);
        h ^= (h >> 6);
    }

    h += (h << 3);
    h ^= (h >> 11);
    h += (h << 15);

    return h;
}
```
