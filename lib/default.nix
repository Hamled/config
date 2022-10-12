{ lib }:
lib.makeExtensible (self: {
  sharedOverlays = self:
    [
      (final: prev: {
        __dontExport = true;
        lib = prev.lib.extend (lfinal: lprev: { our = self.lib; });
      })
    ];
})
