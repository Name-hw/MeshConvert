export type FaceData = { vIndices: { number }, vtIndices: { number }, vnIndices: { number } }
export type ParsedData = {
	v: { Vector3 },
	vn: { Vector3 },
	vt: { Vector2 },
	f: { FaceData },
}
export type Options = {
	partAmountInUnion: number?,
}

return nil
