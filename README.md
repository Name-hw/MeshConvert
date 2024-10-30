# **MeshConvert**

Library for converting meshes in various ways

## **Features**

1. You can convert a mesh(EditableMesh) to Parts, Unions, or obj file.
2. Converting MeshParts to Parts or Unions can achieve a variety of effects (since each face can be moved independently).
3. It can be used without significant performance degradation.

## **Getting Started**

You can get the converted mesh with the MeshConvert.Convert function.

> MeshConvert.Convert(InputType, MeshData, OutputType)

1. InputType: One of MeshConvert.Enums.InputType

2. MeshData: The mesh you want to convert (depending on InputType)

3. OutputType: One of MeshConvert.Enums.OutputType

> If InputType or OutputType is MeshPart, Please turn on EditableImage and EditableMesh in the beta features.

## **Example**

```luau
local MeshConvert = require(script.MeshConvert)

local Output = MeshConvert.Convert(MeshConvert.Enums.InputType.MeshPart, workspace.Meshes/something, MeshConvert.Enums.OutputType.UnionGroup)

Output.Parent = workspace
```

## **Links**

1. [Library link](https://create.roblox.com/store/asset/132609822030597/MeshConvert)
2. [DevForum](https://devforum.roblox.com/t/meshconvert-library-for-converting-meshes-in-various-ways/3230079)
