**ejb**

É um hash com uma fórmula (dois primos e uma correção pelo caractere de espaço) bem menos difundida que os outros dessa lista, provavelmente vindo de algum material didático específico, e não amplamente documentado ou usado como o `djb2` ou o `FNV`. Multiplica pelo primo `37`, faz XOR com o caractere já deslocado por `' '`, e no final reduz o resultado com um módulo por outro primo (`1048583`)

- Velocidade: mais lento que os anteriores, pois soma o custo de uma operação de módulo (divisão) no final, bem mais cara que shifts/XORs
- Qualidade: pouco documentada e testada fora de contexto acadêmico, sem garantias conhecidas nem comparações publicadas contra hashes consolidados
- Quando usar: evite em código novo, principalmente porque a subtração de `' '` (espaço) assume que a entrada é sempre texto ASCII imprimível, quebrando por underflow para bytes menores que `0x20`, como texto binário ou caracteres de controle
- Observação: o módulo final já embute um tamanho de tabela fixo dentro da própria função de hash, o que a torna pouco reutilizável para tabelas de tamanhos diferentes

```c
uint32_t ejb_hash(const char *s, size_t len)
{
	unsigned char *key = (unsigned char*) s;
	const uint32_t PRIME1 = 37;
	const uint32_t PRIME2 = 1048583;
	uint32_t h = 0;

	while (len--) {
		h = h * PRIME1 ^ (*key++ - ' ');
	}
	h %= PRIME2;

	return h;
}
```

