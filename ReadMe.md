Space Rangers inSTEAD module
============================

This is my try to reimplement Space Rangers module for inSTEAD above Kaitai Struct.

The original sources were obtained from https://instead-games.ru/game.php?ID=126 .

The spec is here: https://codeberg.org/KOLANICH/kaitai_struct_formats/blob/space_rangers/game/space_rangers_qm.ksy

You would need a MIT-licensed (copyright 2017-2023 Kaitai Project) lua runtime, it can be obtained here: https://github.com/kaitai-io/kaitai_struct_lua_runtime . The runtime may need a patch to support UTF-16. The one here already has one, the UTF16-to UTF-8 decoder was taken from this file.

