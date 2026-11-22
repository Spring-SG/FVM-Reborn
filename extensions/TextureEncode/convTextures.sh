#!/bin/bash

cd "$(dirname "$0")"

if [[ -z "$ToolType" ]]; then
echo "Missing ToolType definition!"
exit 1
fi

if [ "$ToolType" = "ASTC" ]; then
echo "Encoding as ASTC"
export ToolPath=${PWD}/astcenc
chmod +x "$ToolPath"
"$ToolPath" -cl "$InputFile" "$OutputFile.astc" $CustomOptions
cp -f "$OutputFile.astc" "$OutputFile"
fi

if [ "$ToolType" = "BCN" ]; then
echo "Encoding as BCn"
export ToolPath=${PWD}/bc7enc
chmod +x "$ToolPath"
"$ToolPath" -g $CustomOptions "$InputFile" "$OutputFile.dds"
cp -f "$OutputFile.dds" "$OutputFile"
fi

cd -
