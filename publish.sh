#!/bin/bash
export TOOLSDIR=packages/FSharp.Formatting.CommandTool/tools/
mono .paket/paket.exe restore
mono ${TOOLSDIR}/fsformatting.exe literate --processDirectory --lineNumbers false --inputDirectory "code" --outputDirectory "_posts" --templateFile "template.html"

# git add --all .
# git commit -a -m %1
# git push
