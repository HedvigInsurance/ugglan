#!/bin/bash
mkdir -p Src/Assets/Localization

curl -s 'https://api-euwest.graphcms.com/v1/cjmawd9hw036a01cuzmjhplka/master' -H 'Accept-Encoding: gzip' -H 'Content-Type: application/json' -H 'Accept: */*' -H 'Connection: keep-alive' --data-binary '{"query":"query AppTranslationsMeta {\n    languages {\n      code\n      translations(where: { project: App }) {\n        text\n        key {\n          value\n        }\n        language {\n   code\n        }\n    \t}\n    }\n  \tkeys(where: { translations_every: { project: App } }) {\n      value\n description    }\n  }","variables":null,"operationName":"AppTranslationsMeta"}' --compressed -o Src/Assets/Localization/Localization.json

node scripts/generate-translations-swift.js
