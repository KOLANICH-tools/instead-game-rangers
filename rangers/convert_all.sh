for f in games/*.[qQ][mM]; do
	echo -n "$f..."
	lua ./convert.lua "$f"
	echo "ok"
done