#!/bin/bash

cd frontend || exit
cp index.html ../docs
cp index.css ../docs
cp tests/resources/schema.json ../docs
elm make src/Main.elm --optimize --output=../docs/index.js
sed -i 's/\/tests\/resources\/schema.json/schema.json/' ../docs/index.js
cd ..
