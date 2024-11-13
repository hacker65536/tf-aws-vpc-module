# Test tf12 Atlantis

## Input

```yaml
- name: Should generate README.md for tf12_atlantis
  uses: ./
  with:
    atlantis-file: atlantis.yaml
    args: --hide providers
    indention: 3
```

## Verify

- Should inject below Usage in README.md
- Should not show providers section

## Usage

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->