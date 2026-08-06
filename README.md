# 📱 Divider App (em desenvolvimento)

---

## 📌 Sobre o projeto

O Divider App foi construído como parte de um projeto de portfólio full-stack com foco em exercitar conhecimentos de Flutter e integração com APIs. O app consome a API [Divider](https://github.com/natali-schers/divider-api), mas também roda de forma independente com dados mockados, de acordo com a configuração da variável "USE_MOCK_DATA" do arquivo .env.

## ✨ Funcionalidades

- **Autenticação completa** — cadastro, login e sessão persistente (token armazenado de forma criptografada no dispositivo)
- **Grupos** — criação e listagem, restritos aos grupos em que o usuário participa
- **Despesas** — criação com divisão igualitária
- **Saldos simplificados** — tela dedicada mostrando quem deve pagar para quem, já com o número mínimo de transferências
- **Modelo misto convidado/conta** — é possível adicionar participantes ao grupo sem exigir que todos tenham conta na plataforma

## 🏗️ Arquitetura
```
models/        → dados puros (Group, Member, Expense, User, Settlement...)
repositories/  → abstração da fonte de dados — interface + implementação mock/ e api/, escolhidas via Factory
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
| Detalhe do grupo | Despesas do grupo e valor total |
| Adicionar despesa | Descrição, valor, quem pagou e tipo de divisão |
| Saldos | Transferências simplificadas para quitar o grupo |

## 🛠️ Stack técnica

- **Flutter**
- **Provider** — gerenciamento de estado
- **go_router** — navegação com rotas nomeadas, rotas aninhadas e proteção de rotas autenticadas
- **http** — comunicação com a API
- **flutter_secure_storage** — armazenamento criptografado do token de autenticação (Keychain/KeyStore)
- **flutter_dotenv** — configuração de ambiente (mock vs. API, URL base)

## ⚙️ Configuração

Crie um arquivo `.env` na raiz do projeto (veja `.env.example` como referência):

```
USE_MOCK_DATA=true
API_BASE_URL=https://divider-api.onrender.com/api
```

- `USE_MOCK_DATA=true` → o app roda inteiramente com dados fictícios em memória, sem precisar da API no ar
- `USE_MOCK_DATA=false` → o app consome a API real, definida em `API_BASE_URL`

## 🔗 Projeto relacionado

Este app consome o backend Divider, construído em ASP.NET Core:
👉 **[divider-api](https://github.com/natali-schers/divider-api)**
