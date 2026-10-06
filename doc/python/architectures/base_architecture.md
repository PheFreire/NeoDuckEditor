# Especificação Técnica de Padrão de Implementação — APIs Python/Django

> **Objetivo deste documento:** permitir que qualquer time (ou agente) implemente um backend novo seguindo exatamente o mesmo padrão de arquitetura, nomenclatura, modularização, segurança, testes, qualidade e entrega — sem precisar conhecer nenhum outro sistema que já use esse padrão.
>
> **Como ler:** as palavras **DEVE**, **NÃO DEVE**, **DEVERIA** e **PODE** têm sentido normativo (estilo RFC 2119). Tudo marcado com **DEVE** é obrigatório para o projeto ser considerado aderente. Os exemplos de código usam um domínio fictício (`organizations/organization` como *tenant* e `catalog/product` como entidade de negócio) — substitua pelos nomes do seu domínio.

---

## Sumário

1. [Princípios](#1-princípios)
2. [Stack e dependências](#2-stack-e-dependências)
3. [Estrutura do repositório](#3-estrutura-do-repositório)
4. [Arquitetura em camadas](#4-arquitetura-em-camadas)
5. [Anatomia de um domínio](#5-anatomia-de-um-domínio)
6. [Templates por camada (código de referência)](#6-templates-por-camada-código-de-referência)
7. [Injeção de dependência (`duckdi`)](#7-injeção-de-dependência-duckdi)
8. [Framework de domínio (`dddk`)](#8-framework-de-domínio-dddk)
9. [Autenticação, autorização e escopo de dados](#9-autenticação-autorização-e-escopo-de-dados)
10. [Infra transversal: erros, middlewares, logs, settings](#10-infra-transversal-erros-middlewares-logs-settings)
11. [Banco de dados e migrations](#11-banco-de-dados-e-migrations)
12. [Testes](#12-testes)
13. [Estilo de código e convenções de escrita](#13-estilo-de-código-e-convenções-de-escrita)
14. [Configuração e segredos](#14-configuração-e-segredos)
15. [Container e execução](#15-container-e-execução)
16. [Pipeline de qualidade (pre-push) e CI/CD](#16-pipeline-de-qualidade-pre-push-e-cicd)
17. [Commits e fluxo de Git](#17-commits-e-fluxo-de-git)
18. [Cliente de API versionado (Bruno)](#18-cliente-de-api-versionado-bruno)
19. [Anti-padrões proibidos](#19-anti-padrões-proibidos)
20. [Checklists](#20-checklists)

---

## 1. Princípios

1. **O domínio depende de interfaces, nunca de implementações.** Regra de negócio não importa Django, SQL, boto3, requests etc. A escolha da implementação concreta é *configuração* (TOML), não código.
2. **Cada camada tem um papel único.** Entrada (preparar e delegar) → Fluxo (orquestrar regra de negócio) → Blocos (operação técnica concreta). Nenhuma camada faz o trabalho da outra.
3. **Tudo que atravessa uma fronteira é um DTO tipado (Pydantic v2).** Nunca `dict` solto entre camadas de domínio.
4. **Um único formato de erro** (`AppError`) em toda a stack, convertido automaticamente em resposta HTTP.
5. **Nada de N+1.** Toda leitura de relação é em lote; toda escrita em massa é em lote.
6. **Soft-delete por padrão.** Registros não são apagados fisicamente pela aplicação.
7. **Segurança derivada do servidor.** Escopo de dados (tenant, "meus itens") é sempre derivado do chamador autenticado, nunca de campos enviados pelo cliente.
8. **Teste de integração real** (Postgres real, repositórios reais) cobrindo todos os fluxos de negócio e todas as regras de acesso.
9. **Qualidade bloqueante antes do push** (testes + formatação + lint + tipos + segurança).
10. **Código autoexplicativo.** Sem comentários explicativos; docstrings descrevem propósito, regras e entradas/saídas.

---

## 2. Stack e dependências

| Item | Escolha | Observação |
|---|---|---|
| Linguagem | Python **3.12+** | `pyupgrade --py312-plus` aplicado automaticamente |
| Web | **Django 5.2+** + **Django REST Framework** | Uma `APIView` por rota |
| DTOs | **Pydantic v2** | Todos os DTOs herdam de `dddk.BaseDto` |
| Banco | **PostgreSQL 17** | Local via `docker compose` |
| Pacotes | **Poetry** (`poetry-core>=2`) | Grupos `main` e `dev` |
| Framework de domínio | **`duck-domain-django-kit`** (import `dddk`) `^0.3.0` | PyPI; ver [§8](#8-framework-de-domínio-dddk) |
| DI | **`duckdi`** `^0.1.13` | PyPI; ver [§7](#7-injeção-de-dependência-duckdi) |
| Servidor | **gunicorn** + **whitenoise** | Config em `gunicorn.conf.py` |
| Infra Django | `django-cors-headers`, `dj-database-url`, `psycopg2` | |
| Auth | `pyjwt`, `bcrypt` | Quando o sistema emite tokens próprios |
| Opcionais por necessidade | `boto3` (storage/e-mail/custos), `numpy` (agregações numéricas pesadas), `openpyxl` (planilhas), `reportlab` (PDF), `locust` (carga) | Só entram se um adapter precisar |

**Grupo `dev` obrigatório:** `black`, `isort`, `flake8`, `flake8-bugbear`, `mypy`, `django-stubs`, `pyright`, `bandit`, `pyupgrade`, `autoflake`, `pytest-django`, `pytest-order`, `pytest-cov`, stubs de tipos usados (`types-*`).

**`pyproject.toml` — trechos obrigatórios:**

```toml
[tool.poetry]
packages = [
    { include = "infra", from = "src" },
    { include = "apps", from = "src" },
]

[tool.pytest.ini_options]
DJANGO_SETTINGS_MODULE = "infra.django.rest_api.settings"
python_files = "test_*.py"
testpaths = ["tests"]
pythonpath = ["src"]
addopts = ["--create-db", "--ds=infra.django.rest_api.settings", "-s", "-v"]

[tool.isort]
profile = "black"
force_grid_wrap = 1
length_sort = true

[tool.black]
line-length = 79

[tool.mypy]
mypy_path = "src"
exclude = "tests"
explicit_package_bases = true
plugins = ["pydantic.mypy"]
ignore_missing_imports = true
no_implicit_optional = true
warn_return_any = true

[[tool.mypy.overrides]]
module = [
    "apps.*.*.infra.django.models.*",
    "apps.*.*.infra.django.admins.*",
]
ignore_errors = true

[tool.pyright]
typeCheckingMode = "basic"
extraPaths = ["src"]
reportMissingTypeStubs = false
reportMissingImports = true
```

**`.flake8`:**

```ini
[flake8]
per-file-ignores =
    __init__.py:F401
    admin.py:F401
    src/infra/django/rest_api/apps.py:F401
    src/infra/django/rest_api/settings.py:F401,E402
ignore = E501,W503,B008,E701,E704,E741,B009,B010,B042,E203
extend-select = B
max-line-length = 79
```

Justificativa dos `ignore`: `E501` (black cuida), `W503`/`E203` (estilo do black), `B008` (defaults de `Field` em DTO), `E701`/`E704` (stubs `...` de interface), `B009`/`B010` (getattr/setattr em código de framework), `B042` (`AppError` tem argumentos estruturados).

---

## 3. Estrutura do repositório

```
<repo>/
├── .githooks/pre-push          # pipeline de qualidade (§16)
├── .github/workflows/          # deploy por branch (§16)
├── bruno/                      # coleção de API versionada (§18)
├── docs/                       # documentação adicional
├── src/
│   ├── apps/                   # TODA a regra de negócio, por grupo/domínio
│   │   └── <grupo>/<domínio>/  # ver §5
│   ├── infra/                  # infraestrutura global, SEM regra de negócio
│   │   ├── container.py        # registro de TODOS os adapters globais no DI
│   │   ├── clients/            # interfaces + adapters de serviços externos compartilhados
│   │   ├── providers/          # interfaces + adapters de operações técnicas compartilhadas
│   │   ├── factories/          # IRepositoryFactory + DjangoRepositoryFactory
│   │   ├── log/                # configuração de logging (dictConfig + formatter)
│   │   └── django/
│   │       ├── manage.py
│   │       ├── rest_api/       # settings, urls raiz, wsgi/asgi, apps.py, management commands
│   │       ├── customs/        # middlewares, exception handler, payload builder, utils de admin/migration
│   │       └── templates/      # overrides de templates do admin
│   └── entrypoint.sh           # boot do container
├── tests/
│   ├── conftest.py             # fixtures globais (ex.: bearer_header)
│   ├── unit/                   # testes puros (sem banco), espelhando src/
│   └── integration/            # testes com banco, espelhando src/apps/ e src/infra/
├── envs.toml                   # mapa de injeção de dependência (§14)
├── gunicorn.conf.py
├── dockerfile                  # nome em minúsculo
├── docker-compose.yml          # SÓ o Postgres local
├── Makefile
├── pyproject.toml / poetry.lock
├── .flake8
└── README.md
```

**Regras:**
- `src/infra/` **NÃO DEVE** conter regra de negócio. Contém só o que é compartilhado por vários domínios (auth técnico, storage, e-mail, logging, factories).
- Um cliente/provider usado por **um único** domínio vive dentro desse domínio (`apps/<grupo>/<domínio>/domain/clients/` + `infra/adapters/clients/`), não em `src/infra/`.

---

## 4. Arquitetura em camadas

Arquitetura Hexagonal / Clean Architecture com 3 camadas conceituais, mapeadas para 3 diretórios em cada domínio:

```
                ┌────────────────────────────────────────────┐
   HTTP / cron  │  ENTRADA  (entrypoints/)                   │
  ────────────► │  Route → Controller (+ decorators de auth) │
                └───────────────┬────────────────────────────┘
                                │ InputDto de domínio
                ┌───────────────▼────────────────────────────┐
                │  FLUXO  (domain/usecases, domain/flows)    │
                │  Usecase → Flows / State machine           │
                └───────────────┬────────────────────────────┘
                                │ chama INTERFACES (domain/*)
                ┌───────────────▼────────────────────────────┐
                │  BLOCOS  (infra/adapters)                  │
                │  Repository · Provider · Client · Factory  │
                └────────────────────────────────────────────┘
```

### 4.1 Camada de Entrada (`entrypoints/`)
Prepara o ambiente de execução, valida e estrutura a entrada, delega ao fluxo. **Não implementa regra de negócio.**

| Entidade | Papel | Regras |
|---|---|---|
| **Route** | Gatilho HTTP | `APIView` do DRF; instancia o controller como **atributo de classe**; um método HTTP por classe; só monta o payload (`build_controller_payload`) e devolve `Response(controller(payload), status=...)` |
| **Cron** | Gatilho por tempo | Management command Django em `entrypoints/crons/` (ou `infra/django/management/commands/`) que chama um controller/usecase |
| **Request** | Contrato HTTP de entrada | `RequestDto` (rejeita campos extras), em `entrypoints/requests/`; campo `user: UserArgument` quando autenticado |
| **Controller** | Adaptador entrada → domínio | **Classe** com `__call__(self, request: dict) -> dict \| list`; decorators de auth/permissão/escopo no `__call__`; valida o `Request`; resolve dependências via DI; monta o `InputDto` do usecase; chama `usecase.call(...)`; serializa a saída |

### 4.2 Camada de Fluxo (`domain/usecases`, `domain/flows`)
Orquestra blocos e flows para resolver um problema de negócio: decide ordem, condições, validações e erros. **Não implementa lógica técnica de baixo nível** (SQL, HTTP, criptografia, arquivos).

| Entidade | Papel | Regras |
|---|---|---|
| **Usecase** | Ponto de entrada da regra de negócio | Sufixo `Usecase`; dependências (interfaces) no `__init__`; **um único método público `call(data: <X>InputDto)`**; `call()` fino delegando para métodos privados (`__nome_do_passo`) nomeados pelo passo de negócio |
| **Flow** | "Mini usecase" reutilizável/injetável | Sufixo `Flow`; vive em `domain/flows/`; usado quando a lógica é compartilhada por 2+ usecases/decorators ou merece teste isolado; recebe repositórios/providers no `__init__`; métodos com nome de negócio (`is_member`, `resolve`, `has_permission`) |
| **State machine** | Usecase com múltiplas etapas/transições | Cada `state` decide e retorna o próximo `state`; o usecase só executa o laço |
| **Decorator de domínio** | Regra de acesso reaproveitável | Em `domain/decorators/`; aplicado no `__call__` do controller; ver [§9](#9-autenticação-autorização-e-escopo-de-dados) |

### 4.3 Camada de Blocos (interfaces em `domain/`, adapters em `infra/adapters/`)
Operações concretas, pequenas, previsíveis, testáveis isoladamente. **Um bloco só depende de infraestrutura — nunca de outro bloco, flow ou usecase.** Todo bloco tem **interface** (ABC em `domain/`) + **adapter** (em `infra/`), com DTOs de entrada e saída.

| Entidade | Papel | Nome da interface → adapter |
|---|---|---|
| **Repository** | CRUD em banco | `I<Entity>Repository` → `Django<Entity>Repository` |
| **Query repository** | Leitura analítica/agregada (read model) | `I<X>QueryRepository` → `Django<X>QueryRepository` |
| **Provider** | Operação técnica padronizada com variações internas (hash, token, encoder, cálculo, planilha) | `I<X>Provider` → `<Tecnologia><X>Provider` (ex.: `BcryptPasswordHasherProvider`) |
| **Client** | Comunicação com serviço externo (storage, e-mail, outras APIs) | `I<X>Client` → `<Tecnologia><X>Client` (ex.: `AwsS3StorageClient`, `HttpPaymentClient`) |
| **Factory** | Agrupa e instancia adapters de um contexto de DI | `IRepositoryFactory` → `DjangoRepositoryFactory` |

**Read models:** quando uma leitura junta muitas tabelas/dimensões, **DEVE** ser feita em SQL (view do Postgres ou query agregada num *query repository*/*provider*) mapeada 1:1 para um DTO de resposta — nunca laços Python sobre o ORM.

---

## 5. Anatomia de um domínio

Domínios são agrupados por **grupo** de negócio: `apps/<grupo>/<domínio>/`. Cada domínio vira **um Django app** próprio. Todo domínio **DEVE** ter exatamente 3 diretórios de topo:

```
apps/catalog/product/
├── domain/                                   # Python puro + dddk; ZERO import de Django/infra concreta
│   ├── dtos/
│   │   └── product/                          # um pacote por entidade
│   │       ├── __init__.py                   # re-exporta e define __all__
│   │       ├── product_dto.py
│   │       ├── product_where_dto.py
│   │       ├── product_create_dto.py
│   │       ├── product_update_dto.py
│   │       ├── product_include_dto.py
│   │       └── product_query_response_dto.py
│   ├── repositories/i_product_repository.py
│   ├── providers/i_price_calculator_provider.py   # se houver
│   ├── clients/i_supplier_client.py               # se houver (cliente exclusivo deste domínio)
│   ├── flows/check_product_member_flow.py         # se houver
│   ├── decorators/                                # se houver
│   └── usecases/
│       ├── create_product_usecase.py
│       ├── find_product_usecase.py
│       ├── update_product_usecase.py
│       └── delete_product_usecase.py
├── infra/
│   ├── adapters/
│   │   ├── repositories/django_product_repository.py
│   │   ├── providers/...
│   │   └── clients/...
│   └── django/
│       ├── apps.py                           # AppConfig do domínio
│       ├── admin.py
│       ├── urls.py                           # rotas do domínio
│       ├── models/
│       │   ├── __init__.py
│       │   └── product.py
│       └── migrations/
└── entrypoints/
    ├── requests/
    │   ├── create_product_request.py
    │   └── ...
    ├── controllers/
    │   ├── __init__.py                       # re-exporta os controllers
    │   ├── create_product_controller.py
    │   └── ...
    └── routes/
        └── django/
            ├── django_create_product_route.py
            └── ...
```

**Regras de nomenclatura de arquivos:** um arquivo por classe pública; nome do arquivo = nome da classe em `snake_case` (`CreateProductUsecase` → `create_product_usecase.py`); interfaces com prefixo `I` e arquivo `i_<nome>.py`; adapters prefixados pela tecnologia (`django_`, `http_`, `aws_s3_`, `bcrypt_`).

**Tabela de sufixos:**

| Sufixo | Onde | Exemplo |
|---|---|---|
| `Dto` | `domain/dtos/<entity>/` | `ProductDto`, `ProductWhereDto` |
| `InputDto` | no mesmo arquivo do usecase | `CreateProductInputDto` |
| `Errors` | no mesmo arquivo do usecase de busca | `FindProductErrors` |
| `Usecase` | `domain/usecases/` | `FindProductUsecase` |
| `Flow` | `domain/flows/` | `CheckProductMemberFlow` |
| `Repository` / `Provider` / `Client` | interface em `domain/`, adapter em `infra/adapters/` | `IProductRepository` / `DjangoProductRepository` |
| `Request` / `Argument` | `entrypoints/requests/` | `CreateProductRequest`, `CreateArgument` |
| `Controller` | `entrypoints/controllers/` | `CreateProductController` |
| `Route` | `entrypoints/routes/django/` | `DjangoCreateProductRoute` |
| `Config` | `infra/django/apps.py` | `ProductConfig` |

**Fronteiras entre domínios:** um domínio **PODE** importar DTOs e interfaces de outro domínio (ex.: um usecase de `catalog/product` recebe `IOrganizationRepository`). **NÃO DEVE** importar adapters, models ou controllers de outro domínio — exceto em `infra/` (factories, admin, migrations).

---

## 6. Templates por camada (código de referência)

> Todos os imports usam o estilo parentizado multilinha (§13). O código abaixo é o formato canônico — copie a forma, troque os nomes.

### 6.1 DTOs de domínio (`domain/dtos/product/`)

```python
# product_dto.py
from datetime import (
    datetime,
)

from dddk import (
    BaseDto,
)
from pydantic import (
    Field,
)


class ProductDto(BaseDto):
    uuid: str
    name: str
    organization_id: str
    category_id: str | None = Field(default=None)
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None = Field(default=None)
```

```python
# product_where_dto.py — filtros; todo campo é NullOr com default Null
from dddk import (
    Null,
    NullOr,
    WhereDto,
)
from pydantic import (
    Field,
)


class ProductWhereDto(WhereDto):
    name: NullOr[str] = Field(default=Null)
    organization_id: NullOr[str] = Field(default=Null)
    category_id: NullOr[str] = Field(default=Null)
    category_ids: NullOr[list[str]] = Field(default=Null)
```

```python
# product_create_dto.py — campos obrigatórios sem default
class ProductCreateDto(CreateDto):
    name: str
    organization_id: str
    category_id: str | None = Field(default=None)
```

```python
# product_update_dto.py — update parcial; Null = "não alterar"
class ProductUpdateDto(UpdateDto):
    name: NullOr[str] = Field(default=Null)
    category_id: NullOr[str | None] = Field(default=Null)
```

```python
# product_include_dto.py — uma flag booleana por relação carregável
class ProductIncludeDto(BaseDto):
    category: bool = Field(default=False)
```

```python
# product_query_response_dto.py — DTO base + campos de relação (None/[] até serem incluídos)
class ProductQueryResponseDto(ProductDto):
    category: CategoryDto | None = Field(default=None)
```

```python
# __init__.py
from apps.catalog.product.domain.dtos.product.product_dto import (
    ProductDto,
)
# ... demais imports

__all__ = [
    "ProductDto",
    "ProductWhereDto",
    "ProductCreateDto",
    "ProductUpdateDto",
    "ProductQueryResponseDto",
]
```

**Regras de DTO:**
- `Null` (sentinel do `dddk`) ≠ `None`: `Null` = "campo não informado / não filtrar / não alterar"; `None` = "valor nulo de fato". Em `UpdateDto`, `NullOr[str | None]` permite **limpar** um campo (enviar `None`) distinto de **não mexer** (`Null`).
- Filtro por lista usa o plural + sufixo do campo: `category_ids` → `category_id__in` (o repositório genérico resolve).
- IDs trafegam como `str` (UUID em texto).

### 6.2 Interface de repositório (`domain/repositories/`)

```python
from dddk import (
    IRepository,
)

from apps.catalog.product.domain.dtos.product import (
    ProductDto,
    ProductWhereDto,
    ProductCreateDto,
    ProductUpdateDto,
    ProductQueryResponseDto,
)


class IProductRepository(
    IRepository[
        ProductDto,
        ProductWhereDto,
        ProductCreateDto,
        ProductUpdateDto,
        ProductQueryResponseDto,
    ]
): ...
```

### 6.3 Usecase de criação (`domain/usecases/`)

```python
from dddk import (
    AppError,
    BaseDto,
)

from apps.catalog.product.domain.dtos.product import (
    ProductDto,
    ProductWhereDto,
    ProductCreateDto,
)
from apps.catalog.product.domain.repositories.i_product_repository import (
    IProductRepository,
)


class CreateProductInputDto(BaseDto):
    create: ProductCreateDto


class CreateProductUsecase:
    """Creates a `Product` inside an organization.

    Rejects a duplicate name inside the same organization (409); the same
    name in another organization, or a soft-deleted homonym, is allowed.
    """

    def __init__(self, product_repository: IProductRepository) -> None:
        self.product_repository = product_repository

    def call(self, data: CreateProductInputDto) -> ProductDto:
        self.__ensure_name_is_free(data.create)
        return self.product_repository.create(data.create)

    def __ensure_name_is_free(self, create: ProductCreateDto) -> None:
        self.product_repository.find(
            ProductWhereDto(
                name=create.name, organization_id=create.organization_id
            )
        ).empty_or_error(self)
```

### 6.4 Usecase de busca com includes

```python
class FindProductErrors(BaseDto):
    should_exist: bool = False


class FindProductInputDto(BaseDto):
    where: ProductWhereDto = ProductWhereDto()
    include: ProductIncludeDto = ProductIncludeDto()
    errors: FindProductErrors = FindProductErrors()


class FindProductUsecase:
    """Finds products and batch-loads the relations flagged in `include`."""

    def __init__(
        self,
        product_repository: IProductRepository,
        category_repository: ICategoryRepository,
    ) -> None:
        self.product_repository = product_repository
        self.category_repository = category_repository
        self.relation_loader = RelationLoader()

    def call(
        self, data: FindProductInputDto = FindProductInputDto()
    ) -> list[ProductQueryResponseDto]:
        found = self.__find(data)
        return self.__load_included_relations(found, data)

    def __find(self, data: FindProductInputDto) -> list[ProductQueryResponseDto]:
        result = self.product_repository.find(data.where)
        return result.all_or_error(self) if data.errors.should_exist else result.all

    def __load_included_relations(
        self, products: list[ProductQueryResponseDto], data: FindProductInputDto
    ) -> list[ProductQueryResponseDto]:
        return self.relation_loader.load(
            dtos=products,
            include=data.include,
            config=RelationLoaderConfig(
                fk_relations=[
                    FkRelationConfig(
                        include_field="category",
                        source_id_field="category_id",
                        target_field="category",
                        repository=self.category_repository,
                        where_dto=CategoryWhereDto,
                        where_ids_field="uuids",
                    )
                ]
            ),
        ).items
```

Update e delete seguem o mesmo formato: `UpdateProductInputDto(id: str, update: ProductUpdateDto)`, `DeleteProductInputDto(id: str)`; validações de existência/escopo como passos privados antes de chamar o repositório.

### 6.5 Flow

```python
class CheckProductMemberFlow:
    """Answers whether a product belongs to the caller's organization,
    against a real lookup of the product's own `organization_id`."""

    def __init__(self, product_repository: IProductRepository) -> None:
        self.product_repository = product_repository

    def is_member(self, product_id: str, caller_organization_id: str) -> bool:
        return bool(
            self.product_repository.find(
                ProductWhereDto(
                    uuid=product_id, organization_id=caller_organization_id
                )
            ).all
        )
```

### 6.6 Model (`infra/django/models/product.py`)

```python
from dddk import (
    SoftDeleteModel,
    get_if_active,
)
from django.db import (
    models,
)

from apps.catalog.product.domain.dtos.product.product_dto import (
    ProductDto,
)


class Product(SoftDeleteModel):
    name = models.CharField(max_length=255)
    organization = models.ForeignKey(
        "organizations_organization.Organization",
        on_delete=models.CASCADE,
        related_name="products",
    )
    category = models.ForeignKey(
        "catalog_category.Category",
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="products",
    )

    class Meta:
        db_table = "products"

    def as_dto(self) -> ProductDto:
        return ProductDto(
            uuid=str(self.uuid),
            name=self.name,
            organization_id=str(self.organization_id),
            category_id=get_if_active(self.category) if self.category else None,
            created_at=self.created_at,
            updated_at=self.updated_at,
            deleted_at=self.deleted_at,
        )

    def __str__(self) -> str:
        return self.name
```

**Regras de model:** herda `SoftDeleteModel` (PK `uuid`, `created_at`, `updated_at`, `deleted_at`, managers `objects`/`everything`); `db_table` explícito, plural, `snake_case`; toda FK com `on_delete` e `related_name` explícitos e referência por string `"<app_label>.<Model>"`; `as_dto()` é o **único** ponto de conversão model → DTO; `__str__` legível (usado no admin).

### 6.7 Repositório concreto (`infra/adapters/repositories/`)

```python
from dddk import (
    SoftDeleteDjangoRepository,
)


class DjangoProductRepository(
    SoftDeleteDjangoRepository[
        Product,
        ProductDto,
        ProductWhereDto,
        ProductCreateDto,
        ProductUpdateDto,
        ProductQueryResponseDto,
    ],
    IProductRepository,
):
    model = Product
    dto = ProductDto
    response = ProductQueryResponseDto
    select_related_fields = ("category",)
```

- `select_related_fields` **DEVE** listar toda FK desreferenciada em `as_dto()` (evita N+1).
- `where_field_to_filter: dict[str, str]` mapeia um campo do `WhereDto` para uma expressão ORM arbitrária (ex.: `"supplier_name": "supplier__name__icontains"`) quando o nome não bate 1:1.
- Métodos extras só quando o CRUD genérico não basta — e sempre declarados também na interface.

### 6.8 Registro na factory de repositórios (`src/infra/factories/`)

```python
# interfaces/i_repository_factory.py
@Interface(label="repository")
class IRepositoryFactory(ABC):
    @property
    @abstractmethod
    def product_repository(self) -> IProductRepository: ...


# adapters/django_repository_factory.py
class DjangoRepositoryFactory(IRepositoryFactory):
    @property
    def product_repository(self) -> DjangoProductRepository:
        return DjangoProductRepository()
```

### 6.9 Request (`entrypoints/requests/`)

```python
from dddk import (
    RequestDto,
)
from pydantic import (
    Field,
)

from infra.django.customs.dtos.user_argument import (
    UserArgument,
)


class CreateArgument(RequestDto):
    name: str = Field(..., description="Product display name.")
    category_id: str | None = Field(default=None)


class CreateProductRequest(RequestDto):
    user: UserArgument = Field(default_factory=UserArgument)
    create: CreateArgument = Field(..., description="Creation payload.")
```

`UserArgument` (`id`, `role_id`, `<tenant>_id`) é preenchido **pelo servidor** (decorator de autenticação), nunca pelo cliente.

### 6.10 Controller (`entrypoints/controllers/`)

```python
from typing import (
    Any,
)

from duckdi import (
    Get,
)

from infra.factories.interfaces.i_repository_factory import (
    IRepositoryFactory,
)


class CreateProductController:
    @require_authentication
    @require_permission("products_create")
    @require_own_organization()
    def __call__(self, request: dict[str, Any]) -> dict:
        data = CreateProductRequest.validate_or_error(request)
        assert data.user.organization_id
        factory = Get(IRepositoryFactory, "repository")

        usecase = CreateProductUsecase(
            product_repository=factory.product_repository,
        )

        created = usecase.call(
            CreateProductInputDto(
                create=ProductCreateDto(
                    name=data.create.name,
                    organization_id=data.user.organization_id,
                    category_id=data.create.category_id,
                )
            )
        )

        return {"created": created.uuid}
```

**Regras de controller:**
- Ordem dos decorators: **autenticação → permissão → escopo/relação**.
- O tenant (`organization_id`) vem de `data.user`, **nunca** do corpo da requisição.
- Retorno: `dict`/`list` serializável (`model_dump()`), sem `Response` do DRF.
- Respostas padronizadas: create → `{"created": uuid}`; update → `{"updated": uuid}`; delete → `{"deleted": uuid}`; find → `list[dict]`.

### 6.11 Route e URLs

```python
class DjangoCreateProductRoute(APIView):
    create_controller = CreateProductController()

    def post(self, request):
        return Response(
            self.create_controller(build_controller_payload(request)),
            status=201,
        )
```

```python
# infra/django/urls.py
class _DjangoProductRoute(DjangoCreateProductRoute, DjangoUpdateProductRoute):
    """URL-wiring composition: `/products/` accepts POST (create) and PUT
    (update); each verb's logic stays in its own route class."""


urlpatterns = [
    path("", _DjangoProductRoute.as_view(), name="product"),
    path("find/", DjangoFindProductRoute.as_view(), name="find_products"),
    path("<str:product_id>/", DjangoDeleteProductRoute.as_view(), name="delete_product"),
]
```

- `build_controller_payload(request, **path_params)` combina: corpo JSON + header `Authorization` (numa chave interna) + parâmetros de URL. É o único formato que o controller recebe.
- Buscas com filtros usam **POST** em `.../find/` (corpo JSON), ou rotas de contexto fixas (§9.4).
- `urls.py` raiz: `path("api/<recurso-no-plural>/", include("apps.<grupo>.<domínio>.infra.django.urls"))`. Todo endpoint de negócio fica sob `/api/`.

### 6.12 AppConfig e admin

```python
class ProductConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "apps.catalog.product.infra.django"
    label = "catalog_product"
    verbose_name = "Catalog · Products"
```

`INSTALLED_APPS` lista cada domínio por esse caminho, agrupados por grupo. Admin: herda um `BaseSoftDeleteAdmin` do projeto (que estende `dddk.SoftDeleteAdmin`), com `list_display`, `list_select_related`, `search_fields` (`"=uuid"` incluso), `autocomplete_fields` para FKs e links para entidades filhas.

---

## 7. Injeção de dependência (`duckdi`)

Biblioteca mínima (PyPI `duckdi`) com 3 peças públicas:

| Peça | Uso |
|---|---|
| `@Interface(label="x")` | Decora a ABC. O label é a chave no TOML. Sem label → nome da classe em snake_case. Label duplicado → erro no boot |
| `register(Adapter, "adapter-label", True)` | Registra o adapter concreto. `True` = singleton instanciado no registro (padrão do projeto: adapters são stateless) |
| `Get(IInterface, "x")` | Resolve em runtime: lê `[injections].x` no TOML → busca o adapter registrado com aquele label → valida que é subclasse da interface → devolve a instância. `adapter="..."` força uma implementação (útil em testes) |

**Ligação interface → adapter é configuração** (`envs.toml`):

```toml
[injections]
env = 'toml'
repository = 'django'
storage_client = 's3'
mail_client = 'smtp'
password_hasher = 'bcrypt'
token_provider = 'jwt'
authentication_ensurer = 'jwt_bearer'
```

```python
# src/infra/container.py — TODOS os register() do projeto em um só lugar
from duckdi import (
    register,
)

register(DjangoRepositoryFactory, "django", True)
register(AwsS3StorageClient, "s3", True)
register(SmtpMailClient, "smtp", True)
register(SesMailClient, "ses", True)
register(BcryptPasswordHasherProvider, "bcrypt", True)
register(JwtTokenProvider, "jwt", True)
register(JwtAuthenticationEnsurerProvider, "jwt_bearer", True)
```

**Regras:**
- `container.py` é carregado por **import de efeito colateral** no topo de `settings.py` e em `ready()` do `AppConfig` raiz, marcado com `# noqa: F401`. Por isso `autoflake --remove-all-unused-imports` é **proibido** (apagaria esses imports e quebraria o DI silenciosamente).
- Trocar implementação = registrar o novo adapter e mudar o valor no TOML. Nenhum usecase/controller muda.
- Toda chave em `[injections]` **DEVE** corresponder a um `@Interface` real; não manter chaves mortas.
- Repositórios **não** são registrados um a um: são expostos pela `IRepositoryFactory` (uma propriedade por repositório). `Get()` não instancia adapters com argumentos de construtor — por isso flows/usecases são instanciados manualmente no controller com os repositórios da factory.
- Erros do `duckdi` são exceções nativas de boot (configuração), não `AppError`.

---

## 8. Framework de domínio (`dddk`)

PyPI `duck-domain-django-kit`, import `dddk`, versão mínima `0.3.x`. Depende só de `django`, `duckdi`, `pydantic`, `toml`. Símbolos que dependem de Django são carregados preguiçosamente (pode ser importado em `settings.py`).

### 8.1 Tipos base
- **`BaseDto`** — `BaseModel` com `arbitrary_types_allowed` e serialização `Null → None`. `.get(attr, type)` lança `AppError(500)` se ausente/tipo errado.
- **`Null` / `NullOr[T]`** — sentinel de 3 estados (valor / explicitamente nulo / ausente). `bool(Null) is False`.
- **`RequestDto`** — `extra="forbid"`; `validate_or_error(dict)` converte `ValidationError` em `AppError(422)` com `details={"provided", "error"}`.

### 8.2 CRUD
- **`CreateDto` / `UpdateDto` / `WhereDto`** — `WhereDto` já traz `uuid`, `uuids`, `created_at`, `updated_at`, `deleted_at` (todos `NullOr`).
- **`IRepository[DTO, WHERE, CREATE, UPDATE, RESPONSE]`** — `create`, `create_many`, `find`, `update(id, update)`, `delete(id) -> str`.
- **`QueryResponse`** (retorno de `find`/`create_many`):

| Método | Comportamento |
|---|---|
| `.all` / `.first` | Lista / primeiro ou `None`; nunca lança |
| `.all_or_error(self)` / `.first_or_error(self)` / `.exists_or_error(self)` | `AppError(404)` padronizado se vazio |
| `.empty_or_error(self)` | `AppError(409)` se **existir** resultado (checagem de duplicata) |
| `.to_dict()` | `{"data", "count", "filters"}` |
| `.parallel_map(func, divisions=4)` | Map em thread pool; falhas viram `AppError(500)` |
| `len()`, iteração, `[i]`, `bool()` | Suportados |

### 8.3 Implementação Django
- **`SoftDeleteModel`** — PK `uuid`, timestamps, `deleted_at`; managers `objects` (só ativos) e `everything` (todos); `soft_delete()`, `restore()`; `as_dto()` abstrato.
- **`SoftDeleteDjangoRepository`** — implementação genérica: `create`; `create_many` via `bulk_create(batch_size=500)`; `find` traduz o `WhereDto` (ignora `Null`, `uuids → pk__in`, sufixos `_id` e `__in`, `where_field_to_filter`); `update` ignora `Null`; `delete` faz soft-delete; 404 padronizado; `select_related_fields` aplicado em `find`/`create_many`/`update`.
- **`SoftDeleteAdmin`** — filtro "Soft Delete", actions `soft_delete_selected` / `restore_selected` / `duplicate_selected`, mostra também os apagados.
- **`get_if_active(model)`** — `str(uuid)` se ativo, senão `None`.

### 8.4 `RelationLoader` (padrão *include*)
`RelationLoader().load(dtos, include, config).items` popula relações **em lote**, só as que estiverem `True` no `IncludeDto`:

| Config | Relação | Queries |
|---|---|---|
| `FkRelationConfig` | N:1 (`source_id_field` → entidade) | 1 |
| `HasManyRelationConfig` | 1:N (filhos com FK para o pai) | 1 |
| `M2MRelationConfig` | N:N via pivot, devolve só a entidade | 2 |
| `M2MWithPivotRelationConfig` | N:N mantendo o registro pivot enriquecido | 2 |

Configuração errada (campo de filtro inexistente no `WhereDto`) lança `AppError(500)` imediatamente. Para casos fora desse padrão existe `IIncludeProvider` (mesmas regras: só em lote, sem alterar filtros/paginação).

### 8.5 `AppError`
`AppError(class_pointer, title, message, details: dict = {}, code: int = 400)`. Captura arquivo/linha de origem. `.error` é o corpo JSON da resposta (`class_name`, `caller`, `title`, `message`, `details`, `code`). **Toda** falha de domínio usa `AppError` — nunca `Exception`/`ValueError` crus.

Códigos usados: `400` regra violada · `401` não autenticado · `403` sem permissão/fora do escopo · `404` não encontrado · `409` duplicado · `422` payload inválido · `500` configuração/estado interno inválido.

### 8.6 Configuração
`IEnvs` (label `env`, adapter `EnvsToml` registrado por `from dddk import container  # noqa: F401`) expõe **apenas** `database` (a partir de `DATABASE_URL`, validada por regex). Hosts, CORS, debug e log são lidos de variáveis de ambiente diretamente no `settings.py`.

### 8.7 Utilitários
`Parser.toml_load`, `match_any_filter`/`unmatch_any_filter` (regras de inclusão/exclusão configuráveis por dado). **Não usar** `Parser.json_load` (lê TOML internamente).

---

## 9. Autenticação, autorização e escopo de dados

### 9.1 Autenticação
- Interface `IAuthenticationEnsurerProvider` (label `authentication_ensurer`) com `ensure(handler, request)`: valida o token do header (chave interna inserida por `build_controller_payload`), resolve o chamador e **escreve** `request["user"] = {"id", "role_id", "<tenant>_id"}`; remove o header bruto do payload.
- **Dados de autorização (papel/role) DEVEM ser relidos do banco a cada requisição** — nunca confiados do conteúdo do token (troca de papel tem efeito imediato).
- Access token curto + refresh token; senhas e códigos com hash (`bcrypt`); OTP gerado por provider próprio.
- Decorator `@require_authentication` para endpoints que só exigem "chamador válido".

### 9.2 Autorização por permissão (RBAC)
- Modelo: `Role` ⟷ `RolePermission` ⟷ `Permission(name)`. Permissões e grants são **dados**, criados/alterados **por data migration** (reversível), nunca à mão em produção.
- `@require_permission("slug", ("a", "b"), include_permissions={"flag": "slug"})`: string = obrigatória; tupla = "qualquer uma"; callable = derivada da requisição; `include_permissions` exige permissão extra por relação pedida em `include`. Falha → `AppError(403)` com o slug faltante em `details`.
- O front-end decide visibilidade **apenas por slugs de permissão** (`can("slug")`), nunca por nome de papel.

**Convenção de nomes de permissão:**

| Forma | Significado |
|---|---|
| `<recurso>_create` / `_read` / `_edit` / `_delete` | Ação sobre o recurso no tenant do chamador |
| `<recurso>_read_scoped` | Leitura restrita ao recorte do chamador (itens que lidera/participa) |
| `<recurso>_read_pickable` | Forma "achatada" (id/nome) para seletores |
| `<recurso>_read_pickable_scoped` | Seletor restrito ao recorte do chamador |
| `<recurso>_<ação>_all` / `access_all_<tenants>` | Atravessa o limite de tenant (só papéis internos) |
| `own_<recurso>_<ação>_if_<relação>` | Ação condicionada a relação verificada no banco (ex.: `own_team_edit_if_team_leader`) |
| `<recurso>_<ação>_self` | Ação apenas sobre o próprio registro do chamador |

### 9.3 Escopo de tenant
- `@require_own_<tenant>()` garante que toda entidade referenciada pertence ao tenant do chamador, resolvendo cada tipo via um `Check<Entity>MemberFlow` (consulta real ao banco), despachado por um enum `MemberTarget`. Chamador sem tenant → `403`.
- Para adicionar uma entidade: criar `Check<Entity>MemberFlow.is_member(id, caller_tenant_id)`, novo membro no enum, novo ramo no despachante.

### 9.4 Controllers de contexto (acesso por relação)
Para regras que RBAC não expressa ("líder edita o próprio time", "vejo só meus itens"):
1. **Usecase permanece genérico** (recebe `WhereDto`/`IncludeDto`).
2. **Um controller dedicado por contexto** monta `where`/`include` **a partir do chamador** — o cliente não envia `where`/`include`. Pode acrescentar flags por linha (ex.: `can_edit`).
3. **Decorator relacional reutilizável** (`require_<relação>(id_field=...)`) faz a checagem de escrita no banco.
4. **Flow de resolução de escopo** quando o recorte é uma união de relações (ex.: `ResolveCallerTeamScopeFlow.resolve(caller_id, tenant_id) -> list[id]`).
5. **Rotas dedicadas** (`/api/<recurso>/scoped/`, `/api/<recurso>/pickable/`, `/api/my-<contexto>/...`).
6. **Slug de contexto** libera o acesso ao endpoint; o slug amplo é **revogado** do papel restrito (por migration).

**Regra geral:** endpoints que aceitam `where`/`include` livres do cliente são superfície de exfiltração — só para papéis privilegiados. O padrão é **N rotas de contexto fixas chamando o mesmo usecase**.

### 9.5 Endpoints públicos e admin
- Endpoints sem autenticação descartam explicitamente o header de autorização do payload (`discard_authorization_header`).
- Ações sensíveis de suporte ficam no Django admin, protegidas por permissão Django própria e registradas no histórico do admin.

---

## 10. Infra transversal: erros, middlewares, logs, settings

### 10.1 Tratamento de erro global
- `REST_FRAMEWORK = {"EXCEPTION_HANDLER": "...django_app_error_handler"}` — converte `AppError` em `Response(exc.error, status=exc.code)`.
- `DjangoAppErrorMiddleware` — mesma conversão para erros fora do DRF (`JsonResponse`, `ensure_ascii=False`).

### 10.2 Middlewares (ordem)
```python
MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",
    "...HealthCheckMiddleware",            # /health e /health/ → 200 sem tocar no banco
    "...RequestConsoleLogMiddleware",      # 1 linha "MÉTODO rota status duração" em DEBUG/ALL
    "django.middleware.security.SecurityMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",
    "...RequestLogMiddleware",             # persiste requests /api/ de forma assíncrona
    # middlewares padrão do Django (sessions, common, csrf, auth, messages, clickjacking)
]
```

**`RequestLogMiddleware`:**
- Só registra caminhos com prefixo `/api/` (allow-list).
- Enfileira e grava por **thread de background** (nunca bloqueia a resposta).
- Sanitiza chaves sensíveis (`password`, `token`, `secret`, ... → `"***"`) e base64 grandes (→ `"base_64"`); ignora multipart, streaming e corpos grandes.
- Anexa o chamador resolvido (`payload["user"]`, guardado na request pelo payload builder).
- Qualquer falha de log é engolida — log nunca derruba requisição.

### 10.3 Logging
- `src/infra/log/` define `build_logging()` (dict para `logging.config.dictConfig`), usado **tanto** por `settings.LOGGING` quanto por `gunicorn.conf.py` (`logconfig_dict`).
- Nível por `LOG_LEVEL` (`DEBUG`/`INFO`/`WARNING`/`ERROR`/`ALL`); um único handler stderr com formatter de console; loggers ruidosos (`boto3`, `botocore`, `urllib3`, `django.db.backends`...) fixados em `WARNING`; access log do gunicorn desligado; sob pytest o handler é no-op (o `caplog` continua funcionando).
- Código de domínio usa `logging.getLogger(__name__)`; nunca `print`.

### 10.4 Settings
- `SECRET_KEY` obrigatório por env; `DEBUG` por env (default `false`).
- `ALLOWED_HOSTS`, `CORS_ALLOWED_ORIGINS`, `CSRF_TRUSTED_ORIGINS` por env (lista separada por vírgula).
- `DATABASES` a partir de `Get(IEnvs, "env").database.url`; `TEST_DATABASE_URL` opcional para o banco de teste.
- **Efeitos colaterais externos com chave de desligamento default-off** (ex.: `SEND_EMAILS=false`): nenhum ambiente envia e-mail/integração por acidente; em debug, o conteúdo (ex.: código de login) é logado no servidor, **nunca** devolvido na resposta HTTP.
- `TIME_ZONE = "UTC"`, `USE_TZ = True`.

---

## 11. Banco de dados e migrations

- **Toda coluna em `snake_case`.** Renomear coluna/tabela = **migration real** (`RenameField`/`RunSQL`), nunca `db_column=` como apelido permanente.
- Toda tabela de entidade de negócio tem `uuid` (PK), `created_at`, `updated_at`, `deleted_at`.
- Migrations geradas por `make migrations`; `manage.py makemigrations --check` **DEVE** sair limpo antes de commitar.
- **Data migrations** (seed de permissões, grants, renomes de dado) são **reversíveis** (`RunPython(forward, backward)`) e atualizam no lugar quando é rename (preserva IDs e vínculos).
- **Mover model entre apps:** `SeparateDatabaseAndState` sem operações de banco → `CreateModel` no app novo → uma migration de `AlterField` por app que tem FK para ele → `DeleteModel` no app antigo **por último**, dependendo de todas as anteriores.
- **Adoção de banco legado (opcional):** helper `adopt_or_create_table(table, create_sql, renames, alter_statements)` — adapta a tabela existente ou cria do zero, mantendo `state_operations` alinhado ao model.
- Seeds operacionais (admin inicial, catálogos) são **management commands idempotentes** com alvo no `Makefile`.
- Depois de mexer em migrations, testes rodam com `--create-db` (já no `addopts`).

---

## 12. Testes

### 12.1 Princípios
- **Integração real**: Postgres real (banco de teste efêmero), repositórios reais, sem mock de repositório. Mock/fake só para **clients externos** (HTTP, storage, e-mail) — via `Get(..., adapter=...)`, fakes injetados ou backends em memória do Django.
- Toda unidade de fluxo (usecase, flow, decorator) e **todo controller** tem teste.

### 12.2 Localização (espelha `src/`)
```
tests/integration/<grupo>/<domínio>/
├── domain/usecases/<usecase>/          conftest.py + test_<cenário>.py
├── domain/flows/<flow>/
├── domain/decorators/<decorator>/
└── entrypoints/controllers/<controller>/
tests/unit/infra/...                     # código puro (formatters, parsers, helpers)
```
Toda pasta tem `__init__.py` (evita colisão de módulos no pytest).

### 12.3 Fixtures
```python
# conftest.py de um usecase
@pytest.fixture()
def usecase():
    from apps.catalog.product.domain.usecases.create_product_usecase import (
        CreateProductUsecase,
    )
    from apps.catalog.product.infra.adapters.repositories.django_product_repository import (
        DjangoProductRepository,
    )

    return CreateProductUsecase(product_repository=DjangoProductRepository())


@pytest.fixture()
def db_state(db):
    from apps.organizations.organization.infra.django.models.organization import (
        Organization,
    )

    organization = Organization.objects.create(name="Acme")
    other_organization = Organization.objects.create(name="Globex")

    yield {"organization": organization, "other_organization": other_organization}
```

- Imports **dentro** das fixtures (após o setup do Django).
- `db_state` monta o grafo de dependências **de baixo para cima** (tenant → pais → entidade), incluindo **variantes irmãs** (outro tenant/pai) para provar isolamento e **registros soft-deleted** quando relevante.
- Fixture global `bearer_header(user_id, role_id, tenant_id)` em `tests/conftest.py`: cria/atualiza o usuário com o papel e gera um token real → testes de controller passam pela verificação real de autenticação e permissão, sem camada HTTP.
- Fixture `autouse` que liga as chaves de efeito colateral (ex.: `SEND_EMAILS=True`) com backends em memória, para exercitar os caminhos de entrega.
- `pytestmark = pytest.mark.django_db` no topo do arquivo de teste.
- Criação em massa: lista de `CreateDto` + `repository.create_many(dtos).all`; nunca laço de `create`.

### 12.4 Cenários obrigatórios

| Tipo | Cenários |
|---|---|
| **Create** | DTO retornado correto (uuid, timestamps, `deleted_at=None`); persistido; variante com escopo diferente **não** é duplicata; duplicata no mesmo escopo → `409`; soft-deleted não bloqueia nova criação; pai inexistente → erro |
| **Find** | Lista do DTO correto; soft-deleted nunca aparece; filtro por **cada** campo do `WhereDto`; `should_exist=True` vazio → `404`; cada include: ausente sem a flag, populado com a flag |
| **Update** | Altera só campos enviados; `Null` não altera; `None` limpa; inexistente → `404`; fora do escopo → erro |
| **Delete** | Soft-delete (`deleted_at` preenchido, some do `find`); inexistente → `404` |
| **Flow** | Cada ramo de decisão do método público |
| **Decorator** | Permite com permissão/relação; nega (`403`) sem; bypass por permissão ampla quando previsto |
| **Controller** | Sem token → `401`; sem permissão → `403`; isolamento de tenant (dados de outro tenant nunca aparecem); recorte correto em rotas `scoped`; formato da resposta |

### 12.5 Comandos
`make test` · `make test-unit` · `make test-integration` · `make test-coverage` (`--cov=src`). Carga: `locust/` separado, `make locust`.

---

## 13. Estilo de código e convenções de escrita

- **Idioma: inglês** em código, nomes, docstrings, mensagens de erro e commits.
- **Sem comentários explicativos (`#`).** Se algo precisa de explicação: nome melhor, método auxiliar nomeado ou docstring. Permitidos só pragmas de ferramenta (`# noqa: ...`, `# nosec ...`, `# type: ...`) e cabeçalhos gerados (migrations).
- **Docstrings** descrevem propósito, regras de negócio, entradas/saídas e detalhes técnicos relevantes. Não narram histórico ("antes era...", "portado de...").
- **Imports parentizados multilinha sempre**, mesmo para um símbolo:
  ```python
  from dddk import (
      AppError,
  )
  ```
  `isort` com `profile=black`, `force_grid_wrap=1`, `length_sort=true` (linhas mais curtas primeiro). Imports longos demais recebem `# noqa: E501`.
- `black` com `line-length = 79`.
- Type hints em tudo; `X | None` (nunca `Optional`); genéricos nativos (`list[str]`).
- Métodos privados de passo de negócio com `__` (name mangling); helpers de módulo com `_`.
- `assert` só para estreitar tipos após validação (ex.: `assert data.user.organization_id`), nunca para regra de negócio.
- Sem números mágicos ou strings repetidas: constantes de módulo em `UPPER_SNAKE_CASE`.

---

## 14. Configuração e segredos

| Onde | O quê |
|---|---|
| `envs.toml` (versionado) | **Só** `[injections]` (interface → adapter). Nada de segredo |
| Variáveis de ambiente | Tudo que varia por ambiente ou é segredo |
| `.envrc` (direnv, **não versionado**) | Variáveis locais de desenvolvimento |
| Secret store do provedor (ex.: SSM/Secrets Manager) | Segredos de staging/produção, injetados na task/container |

**Variáveis base:**

| Variável | Uso |
|---|---|
| `SECRET_KEY` | Django (obrigatória) |
| `DEBUG` | `true`/`false` |
| `DATABASE_URL` / `TEST_DATABASE_URL` | Banco da app / banco de teste |
| `INJECTIONS_PATH`, `SETTINGS_PATH` | Caminho do `envs.toml` (ambas apontam para o mesmo arquivo) |
| `ALLOWED_HOSTS`, `CORS_ALLOWED_ORIGINS`, `CSRF_TRUSTED_ORIGINS` | Listas separadas por vírgula |
| `API_HOST`, `API_PORT`, `WEB_WORKERS`, `WEB_THREADS` | Servidor |
| `LOG_LEVEL` | Nível de log |
| `DJANGO_SUPERUSER_EMAIL`, `DJANGO_SUPERUSER_PASSWORD` | Seed do admin no boot |
| `SEND_EMAILS` (e chaves análogas) | Liga efeitos colaterais externos (default `false`) |
| Credenciais de serviços externos | **Uma credencial por serviço/finalidade**, com política mínima |

Toda variável nova **DEVE** ser documentada em `docs/envs.md` (nome, obrigatória?, default, exemplo, quem lê).

---

## 15. Container e execução

**`dockerfile`** (multi-stage):
1. *builder* `python:3.12-slim`: dependências de build + Poetry (script oficial) → `poetry install --only main --no-root` com venv no projeto.
2. *runtime* `python:3.12-slim`: só `libpq5`, `make`, `bash`; copia o venv e o código; define `API_HOST=0.0.0.0`, `API_PORT`, `INJECTIONS_PATH`/`SETTINGS_PATH`; cria e usa usuário **não-root** `app`; `ENTRYPOINT ["/bin/bash", "/app/src/entrypoint.sh"]`.

**`src/entrypoint.sh`** (`set -e`): `make migrate` → `make superuser` (comando idempotente `seed_admins`) → `make collectstatic` → `make run`.

**`gunicorn.conf.py`:** `wsgi_app`, `bind` de `API_HOST:API_PORT`, `workers` (4) e `threads` (8) por env, `timeout=60`, `accesslog=None`, `logconfig_dict=build_logging()`.

**`docker-compose.yml`:** **apenas** o Postgres local (com volume nomeado, rede nomeada e healthcheck `pg_isready`). A aplicação roda localmente via Poetry.

**`Makefile` — alvos obrigatórios (com `## descrição` para `make help`):**

| Grupo | Alvos |
|---|---|
| Setup | `help`, `hooks-install`, `pre-push` |
| Run | `run`, `kill`, `collectstatic`, `superuser`, seeds específicos |
| Format | `format-pyupgrade`, `format-autoflake`, `format-isort`, `format-black`, `format` |
| Check | `check-bandit`, `check-black`, `check-isort`, `check-flake8`, `check-mypy`, `check-pyright`, `check` |
| Test | `test`, `test-unit`, `test-integration`, `test-coverage` |
| Container | `build`, `build-run`, `db-up`, `db-down` |
| Django | `migrations`, `migrate` |
| API client | `bruno`, `bruno-staging` |

`MANAGE = poetry run python -m infra.django.manage`, executado a partir de `src/`.

---

## 16. Pipeline de qualidade (pre-push) e CI/CD

### 16.1 Hook `pre-push` (`.githooks/pre-push`, ativado com `make hooks-install` → `git config core.hooksPath .githooks`)
Executa em sequência e **aborta o push** se algo falhar:

1. **Testes** — `poetry run pytest` (suíte completa).
2. **Auto-format** — `pyupgrade --py312-plus` → `autoflake --in-place --imports=typing -r ./src` → `isort .` → `black .`.
3. **Checker** — `flake8 ./src`, `mypy ./src`, `pyright ./src`, `bandit -r ./src --skip B605,B101,B105,B608`.
4. **Commit de formatação** — se o passo 2 alterou arquivos, cria o commit `style: apply automatic code formatting` e aborta pedindo novo push.

`make pre-push` roda o mesmo pipeline sem push.

**Cuidado conhecido:** o passo 4 adiciona **todo** arquivo rastreado modificado na árvore. Rode o pipeline com a árvore limpa (trabalho já commitado ou em `git stash`), senão mudanças não relacionadas entram no commit `style:`. (Melhoria recomendada para projetos novos: capturar a lista de arquivos alterados **antes** e **depois** da formatação e commitar só a diferença.)

### 16.2 CI/CD
- Workflows **finos** que delegam para um **workflow reutilizável central da organização** (build da imagem a partir do `dockerfile` + deploy no orquestrador de containers).
- Autenticação no provedor de nuvem por **OIDC** (`permissions: id-token: write`, `contents: read`) — **sem segredos de longa duração no repositório**.
- Um workflow por ambiente, disparado por push na branch:
  - `dev` → serviço `dev-<sistema>` (deploy contínuo, sem gate manual).
  - `production` → serviço `<sistema>` (promoção de `dev` para `production` **por Pull Request**).
- Rota de saúde `/health/` usada pelo load balancer.
- **DEVERIA** existir um job de CI rodando `make check` + `make test` antes do deploy, como segunda camada além do hook local.

---

## 17. Commits e fluxo de Git

- **Formato:** `type(scope): description` — uma linha, inglês, imperativo, minúsculas.
  - `type`: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`, `style`.
  - `scope`: grupo/domínio/módulo afetado (`catalog`, `users`, `infra`, `bruno`...).
  - Ex.: `feat(catalog): add product subdomain with full CRUD`.
- **Commits coesos:** cada commit é uma mudança lógica completa (código + migration + testes do mesmo assunto), e o projeto passa nos checks em cada um.
- **Autoria do time:** mensagens, código e docstrings não citam ferramentas de geração de código (nem co-autoria, nem comentário).
- **Push e merge são decisões humanas** — automações/agentes não fazem `git push`.
- Branches: `dev` (integração + deploy dev), `production` (produção), `main`/`master` conforme o repositório; features em branches curtas.

---

## 18. Cliente de API versionado (Bruno)

- Pasta `bruno/` na raiz, coleção em texto plano (`.bru`), **uma subpasta por domínio** e **um arquivo por request**.
- Ambientes em `bruno/environments/<env>.bru` (`local`, `staging`, ...); segredos em `*.bru.env` **não versionados**.
- Toda rota nova ganha seu `.bru` no mesmo commit/PR.
- `make bruno` / `make bruno-staging` → `bru run --env <env>`.

---

## 19. Anti-padrões proibidos

| Proibido | Faça assim |
|---|---|
| Usecase/flow importando Django, ORM, boto3, requests | Interface em `domain/` + adapter em `infra/` |
| Lógica de negócio no controller/route | Mover para usecase/flow |
| Controller como função | Classe com `__call__` |
| `dict` cru entre camadas de domínio | DTO Pydantic |
| `raise Exception/ValueError` em domínio | `AppError(self, title, message, details, code)` |
| Query dentro de laço (N+1) | `RelationLoader`, `select_related_fields`, `__in` em lote |
| Laço de `create()` | `create_many()` |
| `.delete()` físico pela aplicação | `soft_delete()` via repositório |
| Tenant/escopo vindo do corpo da request | Derivar de `request["user"]` |
| Confiar no papel gravado no token | Reler do banco a cada request |
| `where`/`include` livres do cliente em rota de papel restrito | Controller de contexto com `where`/`include` fixos |
| Lógica de negócio dentro de Provider | Provider é técnico; decisão de negócio vai para Flow |
| Bloco chamando outro bloco | Orquestrar no usecase/flow |
| Segredo no `envs.toml` ou no código | Variável de ambiente / secret store |
| `autoflake --remove-all-unused-imports` | Só `--imports=typing` |
| Comentários `#` explicativos | Nome melhor, helper ou docstring |
| `db_column=` para esconder nome legado | Migration de rename real |
| Devolver código/token de login na resposta HTTP | Logar no servidor só em debug; entregar por canal próprio |
| Mock de repositório em teste de integração | Banco real + `db_state` |

---

## 20. Checklists

### 20.1 Novo projeto
- [ ] `pyproject.toml` com `packages`, deps `main`/`dev`, configs de pytest/isort/black/mypy/pyright (§2)
- [ ] `.flake8`, `.gitignore` (inclui `.envrc`, `*.bru.env`), `.dockerignore`
- [ ] Estrutura `src/apps`, `src/infra`, `tests/unit`, `tests/integration` (§3)
- [ ] `src/infra/django/rest_api/` (settings, urls com `/health/` e `/admin/`, wsgi, `apps.py` com import do container)
- [ ] `src/infra/container.py` + `envs.toml [injections]` + `from dddk import container  # noqa: F401`
- [ ] `IRepositoryFactory` / `DjangoRepositoryFactory`
- [ ] `build_controller_payload`, `UserArgument`, exception handler, middlewares (§10)
- [ ] `src/infra/log/` + `gunicorn.conf.py`
- [ ] Autenticação (`IAuthenticationEnsurerProvider` + adapter), `require_authentication`, `require_permission`, `require_own_<tenant>`
- [ ] `BaseSoftDeleteAdmin`, management command `seed_admins`
- [ ] `dockerfile`, `src/entrypoint.sh`, `docker-compose.yml` (só Postgres), `Makefile` (§15)
- [ ] `.githooks/pre-push` + `make hooks-install` (§16)
- [ ] Workflows `dev` e `production` via OIDC
- [ ] `bruno/` com ambientes, `docs/envs.md`, `README.md`
- [ ] `tests/conftest.py` com `bearer_header` e fixtures de efeito colateral

### 20.2 Novo domínio / entidade
- [ ] `apps/<grupo>/<domínio>/{domain,infra,entrypoints}` (§5)
- [ ] DTOs: `Dto`, `WhereDto`, `CreateDto`, `UpdateDto`, `IncludeDto`, `QueryResponseDto`, `__init__` com `__all__`
- [ ] `I<Entity>Repository` + `Django<Entity>Repository` (com `select_related_fields`)
- [ ] Propriedade na `IRepositoryFactory` e na `DjangoRepositoryFactory`
- [ ] Model `SoftDeleteModel` com `db_table`, `as_dto()`, `__str__`; `AppConfig` com `label` `<grupo>_<domínio>`; entrada em `INSTALLED_APPS`
- [ ] Migration gerada; `makemigrations --check` limpo; permissões novas seedadas por data migration reversível
- [ ] Usecases (`call(InputDto)` + passos privados), flows se compartilhados
- [ ] Requests, controllers (decorators na ordem certa), routes, `urls.py`, `include` em `urls.py` raiz sob `/api/`
- [ ] Rotas de contexto (`scoped`/`pickable`/`my-*`) quando houver papéis com recorte
- [ ] Admin registrado
- [ ] Testes: usecases, flows, decorators e controllers com os cenários obrigatórios (§12.4)
- [ ] Requests `.bru` na coleção
- [ ] `make pre-push` limpo (testes, format, flake8, mypy, pyright, bandit)
- [ ] Commits coesos no formato `type(scope): description`

### 20.3 Novo adapter (provider/client)
- [ ] Interface ABC com `@Interface(label="...")` (em `domain/` do domínio dono ou em `src/infra/` se compartilhado)
- [ ] DTOs de entrada/saída
- [ ] Adapter prefixado pela tecnologia; credenciais lidas de env vars de forma preguiçosa (no primeiro uso)
- [ ] `register(Adapter, "label", True)` em `src/infra/container.py`
- [ ] Chave em `envs.toml [injections]`
- [ ] Variáveis novas documentadas em `docs/envs.md`
- [ ] Efeito colateral externo atrás de chave default-off quando aplicável
