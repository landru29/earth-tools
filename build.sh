#!/bin/bash

# apt-get install gdal-bin
# npm install -g topojson

FOLDER=tmp
DEST=build
COAST_SERVER=http://naciscdn.org/naturalearth

rm -rf $FOLDER
mkdir -p $FOLDER
mkdir -p $DEST

echo "==== Downloading ne_10m_lakes.zip ===="
curl "$COAST_SERVER/10m/physical/ne_10m_lakes.zip" -o tmp/ne_10m_lakes.zip
echo "==== Downloading ne_10m_coastline.zip ===="
curl "$COAST_SERVER/10m/physical/ne_10m_coastline.zip" -o tmp/ne_10m_coastline.zip
echo "==== Downloading ne_50m_lakes.zip ===="
curl "$COAST_SERVER/50m/physical/ne_50m_lakes.zip" -o tmp/ne_50m_lakes.zip
echo "==== Downloading ne_50m_coastline.zip ===="
curl "$COAST_SERVER/50m/physical/ne_50m_coastline.zip" -o tmp/ne_50m_coastline.zip
echo "==== Downloading ne_110m_lakes.zip ===="
curl "$COAST_SERVER/110m/physical/ne_110m_lakes.zip" -o tmp/ne_110m_lakes.zip
echo "==== Downloading ne_110m_coastline.zip ===="
curl "$COAST_SERVER/110m/physical/ne_110m_coastline.zip" -o tmp/ne_110m_coastline.zip

echo "==== Unzipping ===="
for zip in $FOLDER/*.zip; do
	unzip -o -d $FOLDER $zip
done

echo "==== Converting to JSON ===="
ogr2ogr -f GeoJSON $FOLDER/coastline_50m.json $FOLDER/ne_50m_coastline.shp
ogr2ogr -f GeoJSON $FOLDER/coastline_110m.json $FOLDER/ne_110m_coastline.shp
ogr2ogr -f GeoJSON -where "scalerank < 4" $FOLDER/lakes_50m.json $FOLDER/ne_50m_lakes.shp
ogr2ogr -f GeoJSON -where "scalerank < 2 AND admin='admin-0'" $FOLDER/lakes_110m.json $FOLDER/ne_110m_lakes.shp
ogr2ogr -f GeoJSON -simplify 1 $FOLDER/coastline_tiny.json $FOLDER/ne_110m_coastline.shp
ogr2ogr -f GeoJSON -simplify 1 -where "scalerank < 2 AND admin='admin-0'" $FOLDER/lakes_tiny.json $FOLDER/ne_110m_lakes.shp

echo "==== Merging JSON ===="
geo2topo $FOLDER/coastline_50m.json $FOLDER/coastline_110m.json $FOLDER/lakes_50m.json $FOLDER/lakes_110m.json > $DEST/earth-topo.json
geo2topo $FOLDER/coastline_110m.json $FOLDER/coastline_tiny.json $FOLDER/lakes_110m.json $FOLDER/lakes_tiny.json > $DEST/earth-topo-mobile.json

#for shp in $FOLDER/*coastline.shp; do
#	xbase=${shp##*/}
#	xpref=${xbase%.*}
#	ogr2ogr -f $FOLDER/${xpref}.json $shp
#done

rm -rf $FOLDER
