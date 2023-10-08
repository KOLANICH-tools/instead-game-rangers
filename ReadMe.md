Space Rangers inSTEAD module
============================
**We have moved to https://codeberg.org/KOLANICH-tools/instead-game-rangers, grab new versions there.**

Under the disguise of "better security" Micro$oft-owned GitHub has [discriminated users of 1FA passwords](https://github.blog/2023-03-09-raising-the-bar-for-software-security-github-2fa-begins-march-13/) while having commercial interest in success of [FIDO 1FA specifications](https://fidoalliance.org/specifications/download/) and [Windows Hello implementation](https://support.microsoft.com/en-us/windows/passkeys-in-windows-301c8944-5ea2-452b-9886-97e4d2ef4422) which [it promotes as a replacement for passwords](https://github.blog/2023-07-12-introducing-passwordless-authentication-on-github-com/). It will result in dire consequencies and is competely inacceptable, [read why](https://codeberg.org/KOLANICH/Fuck-GuanTEEnomo).

If you don't want to participate in harming yourself, it is recommended to follow the lead and migrate somewhere away of GitHub and Micro$oft. Here is [the list of alternatives and rationales to do it](https://github.com/orgs/community/discussions/49869). If they delete the discussion, there are certain well-known places where you can get a copy of it. [Read why you should also leave GitHub](https://codeberg.org/KOLANICH/Fuck-GuanTEEnomo).

---

This is my try to reimplement Space Rangers module for inSTEAD above Kaitai Struct.

The original sources were obtained from https://instead-games.ru/game.php?ID=126 .

The spec is here: https://codeberg.org/KOLANICH/kaitai_struct_formats/blob/space_rangers/game/space_rangers_qm.ksy

You would need a MIT-licensed (copyright 2017-2023 Kaitai Project) lua runtime, it can be obtained here: https://github.com/kaitai-io/kaitai_struct_lua_runtime . The runtime may need a patch to support UTF-16. The one here already has one, the UTF16-to UTF-8 decoder was taken from this file.

