# Third-party notices

## Microsoft Windows classic SampleIME

apps/windows/tsf is derived from Microsoft's Windows-classic-samples / Samples/IME/cpp/SampleIME.

- Source: https://github.com/microsoft/Windows-classic-samples
- Upstream revision: 434f6002bdf9cf9829406c3ff2b33387982d6168
- Copyright: Microsoft Corporation
- License: MIT, included in apps/windows/tsf/LICENSE.Microsoft.txt

Jiuyun changes include distinct COM/profile GUIDs, independent product registration, scheme dictionary loading, semicolon input, candidate colors, a standalone settings application, and installer integration. The original sample dictionary is not bundled; all shipped dictionaries derive from this project's original starter lexicon.

The optional Rime adapter does not bundle Rime binaries or external lexicons. Rime and all externally installed platform frameworks retain their own licenses.
