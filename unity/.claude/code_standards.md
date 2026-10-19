# Code Standards (Unity C#)

`.editorconfig` enforces formatting and naming; this file summarizes it and adds what it can't express. Only non-obvious rules are listed.

## Assemblies & folders
- Folder = assembly: `Assets/Scripts/<Root>/<Feature>/{Runtime,Editor,Tests}` → `<Root>.<Feature>`, `<Root>.<Feature>.Editor`, `<Root>.<Feature>.Tests`.
- Roots: `Modules` (reusable across projects); `Game` or the game name (`EcsTest`) for game code. No code outside an asmdef.
- Namespace = asmdef `rootNamespace`. Runtime max 2 levels (`Modules.UI`); related assemblies add one (`Modules.UI.Tests`). Block-scoped namespaces, never file-scoped.
- Runtime assemblies never use `UnityEditor`; put it in `.Editor` (or `#if UNITY_EDITOR` if unavoidable).

## Formatting
- Tabs, Allman braces, `var` always, target-typed `new()`, explicit `private`.
- Braces required except guard clauses (`return`/`continue`/`break`/`throw`), which stay on two lines:
  ```cs
  if (target == null)
  	return;
  ```
- Expression bodies for properties only; methods use block bodies.
- Wrapped conditions start the line with the operator (`&&`, `||`).

## Naming
- Private fields (incl. `[SerializeField]`): `_camelCase`. Consts & `static readonly`: `PascalCase`. Local consts: `camelCase`.
- Events: `public event Action<int> HealthChanged;` (past tense, no `On`); handlers `OnHealthChanged`. `UnityEvent` only for Inspector wiring.

## Fields & data
- MonoBehaviour/ScriptableObject: `[SerializeField] private _field`, exposed via property. No public fields.
- Plain data (`IComponentData`, `[Serializable]` configs, structs): public `PascalCase` fields.

## Unity specifics
- `UnityEngine.Object`: `== null` or implicit bool. Never `?.`, `??`, `is null` (fake null).
- Async: UniTask if `com.cysharp.unitask` is in `Packages/manifest.json`, else coroutines.

## Member order
consts/statics → serialized fields → private fields → events → properties → Unity messages (lifecycle order) → public methods → private methods → nested types.

## Comments
Why-only. No XML docs.

## Tests
- `Modules`: new/changed logic requires tests. EditMode by default; PlayMode only for lifecycle/physics. `Game`: optional.
- Keep logic in plain C# classes so it's EditMode-testable.
- Tests live in `<Assembly>.Tests`; names `Method_Condition_Result`.
