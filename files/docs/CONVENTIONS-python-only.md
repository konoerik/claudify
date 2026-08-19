# Conventions

> Reference style — pattern-match against these before writing or editing code.
> Modify to reflect actual project choices.

## Module

```python
from __future__ import annotations

import json
from pathlib import Path

__all__ = ["load_config", "ConfigError"]


class ConfigError(ValueError):
    """Raised when configuration is invalid or missing."""


def load_config(path: Path) -> dict:
    """Load and validate a JSON config file.

    Args:
        path: Path to the config file.

    Returns:
        Parsed configuration dict.

    Raises:
        ConfigError: If the file is missing or malformed.
    """
    try:
        return json.loads(path.read_text())
    except FileNotFoundError as exc:
        raise ConfigError(f"Config not found: {path}") from exc
    except json.JSONDecodeError as exc:
        raise ConfigError(f"Invalid JSON in {path}: {exc}") from exc
```

## Stub (pre-implementation)

> Write this first for new public functions and pause for review — see `## Behavior Rules` in `.claude/claudify.md`.

```python
def merge_configs(base: dict, override: dict) -> dict:
    """Merge two config dicts, with override values taking precedence.

    Args:
        base: The base configuration.
        override: Values to layer on top of base.

    Returns:
        Merged configuration dict.

    Raises:
        ConfigError: If a key's type differs between base and override.
    """
    raise NotImplementedError


# Test scenarios (names only, no bodies yet):
# test_merge_configs_override_wins_on_conflict
# test_merge_configs_type_mismatch_raises
# test_merge_configs_empty_override_returns_base
# test_merge_configs_nested_dict_merges_recursively
```

## CLI entry point

```python
# main.py
from __future__ import annotations

import argparse
import sys
from pathlib import Path


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="One-line description of the tool.")
    parser.add_argument("input", type=Path, help="Input file to process")
    parser.add_argument("--output", "-o", type=Path, help="Output file (default: stdout)")
    parser.add_argument("--verbose", "-v", action="store_true", help="Enable verbose output")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    # ...
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

## Tests

```python
import unittest
from pathlib import Path
from mymodule import load_config, ConfigError


class TestLoadConfig(unittest.TestCase):
    def test_missing_file_raises(self):
        with self.assertRaises(ConfigError):
            load_config(Path("nonexistent.json"))


class TestCLI(unittest.TestCase):
    def test_parse_args_defaults(self):
        from main import parse_args
        args = parse_args(["input.txt"])
        self.assertEqual(args.input, Path("input.txt"))
        self.assertFalse(args.verbose)

    def test_parse_args_verbose(self):
        from main import parse_args
        args = parse_args(["input.txt", "--verbose"])
        self.assertTrue(args.verbose)


if __name__ == "__main__":
    unittest.main()
```
