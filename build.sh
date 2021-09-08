
echo "deb11builder:"
echo "  building"
docker build -t deb11builder .
echo "  create runtime container"
docker create --name=deb11builder deb11builder
echo "  grab results"
docker cp deb11builder:/root/hithere ./hithere.deb11
echo "  stop runtime container"
docker stop deb11builder
echo "  delete runtime container"
docker rm deb11builder
