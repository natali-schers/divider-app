# 📱 Divider App (em desenvolvimento)

---

## 📌 Sobre o projeto

O Divider App foi construído como parte de um projeto de portfólio full-stack com foco em exercitar conhecimentos de Flutter e integração com APIs. O app consome a API [Divider](https://github.com/natali-schers/divider-api), cuja URL é definida na variável `API_BASE_URL` do arquivo .env.

## ✨ Funcionalidades

- **Autenticação completa** — cadastro, login e sessão persistente (token armazenado de forma criptografada no dispositivo), com retorno automático ao login quando a sessão expira
- **Grupos** — criação, listagem e exclusão (apenas grupos sem despesas), restritos aos grupos em que o usuário participa
- **Despesas** — criação com divisão igualitária e exclusão (apenas por quem pagou)
- **Saldos simplificados** — tela dedicada mostrando quem deve pagar para quem, já com o número mínimo de transferências (calculado pela API)
- **Modelo misto convidado/conta** — é possível adicionar participantes ao grupo sem exigir que todos tenham conta na plataforma

## 🏗️ Arquitetura
```
models/        → dados puros (Group, Member, Expense, User, Settlement...)
repositories/  → abstração da fonte de dados — interfaces + implementação em api/
providers/     → estado reativo (ChangeNotifier) que a UI observa
screens/       → telas, sem lógica de negócio — só leem e reagem ao estado dos providers
config/        → leitura do .env e configuração de rotas (go_router)
```

## 🖥️ Telas

| Tela | Descrição |
|---|---|
| Login / Cadastro | Autenticação via e-mail e senha |
| Lista de grupos | Grupos em que o usuário participa |
| Criar grupo | Nome do grupo + participantes |
| Detalhe do grupo | Despesas do grupo, valor total e exclusão de despesas/grupo |
| Adicionar despesa | Descrição, valor e quem pagou (divisão igualitária) |
| Saldos | Transferências simplificadas para quitar o grupo |

## 🛠️ Stack técnica

- **Flutter**
- **Provider** — gerenciamento de estado
- **go_router** — navegação com rotas nomeadas, rotas aninhadas e proteção de rotas autenticadas
- **http** — comunicação com a API
- **flutter_secure_storage** — armazenamento criptografado do token de autenticação (Keychain/KeyStore)
- **flutter_dotenv** — configuração de ambiente (URL base da API)

## ⚙️ Configuração

Crie um arquivo `.env` na raiz do projeto (veja `.env.example` como referência):

```
API_BASE_URL=https://divider-api.onrender.com/api
```

- `API_BASE_URL` → URL base da API consumida pelo app

## 🔗 Projeto relacionado

Este app consome o backend Divider, construído em ASP.NET Core:
👉 **[divider-api](https://github.com/natali-schers/divider-api)**
