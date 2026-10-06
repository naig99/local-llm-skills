# Local LLM Skills Pack (adapted from ECC)

Готовый набор **skills**, **agents** и **rules** для локальных LLM (Qwen 3.5 4B / MLX и подобных) + агентов Cline, Aider, OpenCode, Continue и т.д.

Источник: [affaan-m/ECC](https://github.com/affaan-m/ECC) (MIT License).  
Отобрано и слегка адаптировано под маленькие модели и ограниченную память (8 ГБ).

## Что внутри

```
local-llm-skills/
├── skills/                 # Модульные инструкции (главное)
│   ├── coding-standards/
│   ├── context-budget/
│   ├── agentic-engineering/
│   ├── api-design/
│   ├── backend-patterns/
│   ├── codebase-onboarding/
│   ├── tdd-workflow/
│   ├── verification-loop/
│   ├── continuous-learning/
│   ├── architecture-decision-records/
│   ├── deep-research/
│   ├── contract-first/
│   ├── delivery-gate/
│   ├── deployment-patterns/
│   ├── design-system/
│   └── e2e-testing/
├── agents/                 # Специализированные роли
│   ├── planner.md
│   ├── architect.md
│   ├── code-reviewer.md
│   ├── security-reviewer.md
│   ├── tdd-guide.md
│   ├── build-error-resolver.md
│   └── code-simplifier.md
├── rules/                  # Короткие always-on правила
│   ├── common/
│   ├── typescript/
│   └── python/
├── prompts/                # Готовые system prompts под 4B
│   ├── system-base.md
│   ├── planner.md
│   ├── implementer.md
│   └── reviewer.md
└── README.md
```

## Как использовать

### 1. Cline (VS Code)
- Скопируй нужные `SKILL.md` в Custom Instructions или создай Custom Agent.
- Или добавь содержимое в System Prompt.

### 2. OpenCode
- Положи skills в `.opencode/skills/` или подключи через instructions.
- Agents можно использовать как отдельные профили.

### 3. Aider
- Используй `--read` или добавь в `.aider.conf.yml` / system prompt.
- Лучше всего работают короткие версии из папки `prompts/`.

### 4. Continue.dev / другие
- Добавь как context provider или в system message.

### Рекомендуемый минимальный набор для 4B
1. `skills/coding-standards/SKILL.md`
2. `skills/context-budget/SKILL.md` (очень важно!)
3. `skills/agentic-engineering/SKILL.md`
4. `agents/planner.md` + `prompts/planner.md`
5. `rules/common/`

## Философия (из ECC)
```
plan → test → implement → review → verify → remember → improve
```

На маленькой модели **всегда** начинай с плана и подтверждения.

## Как сделать свой GitHub-репозиторий

```bash
cd local-llm-skills
git init
git add .
git commit -m "Initial local LLM skills pack (from ECC)"
gh repo create local-llm-skills --public --source=. --push
# или создай репо вручную на github.com и сделай git remote add origin ...
```

## Лицензия
MIT (как у оригинального ECC).  
Оригинал: https://github.com/affaan-m/ECC

---
Создано для MacBook Air M3 8GB + Qwen 3.5 4B MLX.
