# Architecture

## Quick Reference
**Stack:** Python 3.10+, Textual
**Entry point:** <!-- e.g. app.py, src/app.py -->
**Key paths:** <!-- screens/, widgets/, app.tcss -->
**Key constraints:** <!-- e.g. single App instance, no blocking I/O on main thread -->
**Patterns:** Reactive state, message passing, screen composition


## Decisions (ADRs)
<!-- Append new ADRs with /decide -->


## Detail

### App structure
```
<!-- Fill in your project layout, e.g.:
src/
├── app.py          # App subclass, screen mounting
├── app.tcss        # Global styles
├── screens/        # Screen subclasses
└── widgets/        # Custom Widget subclasses
-->
```

### State model
<!-- How is state managed? Reactive attributes on App vs per-screen vs per-widget. -->

### Screen map
<!-- Which screens exist, how they're navigated, what each owns. -->
