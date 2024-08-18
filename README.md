# MeshConvert

A module that can import/export 3D model formats from Roblox.

## Getting Started

Example:

```luau
local MeshConvert = require(script.MeshConvert)

local EM = MeshConvert.Import(MeshConvert.Enums.MeshFileFormat.OBJ, script.StringValue.Value, MeshConvert.Enums.MeshOutput.EditableMesh)
EM.Parent = script.Parent
```

For more help, check out [the Rojo documentation](https://rojo.space/docs).