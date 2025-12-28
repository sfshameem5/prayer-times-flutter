---
trigger: always_on
---


# Project Guidelines for AI Agents

1. **Always use context7 MCP server** for technical questions and library documentation
2. **Proper context7 usage**:
   - First call `resolve-library-id` to get the correct library ID
   - Then use `get-library-docs` with the resolved ID
   - Specify `mode=code` for API references or `mode=info` for conceptual guides
3. Follow existing project patterns and conventions
4. Verify all code changes against project dependencies
5. Maintain consistent code style throughout the project

## Context7 Best Practices
- Always check for the latest library versions
- When documentation is unclear, search for code examples
- Verify API compatibility with our project's dependencies
- Report any documentation gaps to the maintainers

## Project Structure Guidelines

- Follow **feature-based architecture** with directories:
  - `common/` for shared services
  - `config/` for theme and constants
  - `core/` for application logic
  - `features/<feature_name>/` for feature implementation
- Maintain **separation of concerns** within each feature
- There can only be one widget per file. If there are more per feature, you can move them to the widgets folder

## Feature Organization

Each feature should follow this structure:
```
features/<feature_name>/
  data/
    repositories/
    models/
    datasources/
  presentation/
    views/
    widgets/
    controllers/
  services/
```
- **Data Layer**: Handle data sources and business logic
- **Presentation Layer**: Manage UI components and state
- **Services**: Feature-specific service implementations

## Code Conventions

- Use **Material 3** theming system
- Apply **Google Fonts** for consistent typography
- Implement **Workmanager** for background tasks
- Handle timezones with **tz** package
- Follow existing **color scheme** (appOrange, appBlue, navySurface)

## Theme Implementation

- Support both **light and dark** modes
- Use **ThemeMode.system** for automatic theme selection
- Define gradients for card backgrounds
- Maintain consistent text styling across themes
