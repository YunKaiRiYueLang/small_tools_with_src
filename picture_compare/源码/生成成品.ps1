# 把 源码\index.html 与两个解码库合并成单个 HTML，输出到 成品\图片比对.html
# 用法：右键本文件 -> 使用 PowerShell 运行；或在 PowerShell 里执行 .\生成成品.ps1
$ErrorActionPreference = 'Stop'

$srcDir  = $PSScriptRoot
$outDir  = Join-Path (Split-Path $srcDir -Parent) '成品'
$outFile = Join-Path $outDir '图片比对.html'

$htmlPath = Join-Path $srcDir 'index.html'
if (-not (Test-Path $htmlPath)) { throw "找不到 index.html：$htmlPath" }

$html = Get-Content -LiteralPath $htmlPath -Raw -Encoding UTF8
if ($html -notmatch '<!--LIBS-->') { throw 'index.html 里找不到 <!--LIBS--> 占位符' }

$pako = Get-Content -LiteralPath (Join-Path $srcDir 'pako.min.js') -Raw -Encoding UTF8
$utif = Get-Content -LiteralPath (Join-Path $srcDir 'UTIF.js')     -Raw -Encoding UTF8
foreach ($lib in @($pako, $utif)) {
  if ($lib -match '</script') { throw '库文件里出现了 </script>，内联会破坏页面' }
}

$libs = "<script>`r`n$pako`r`n</script>`r`n<script>`r`n$utif`r`n</script>"
$html = $html.Replace('<!--LIBS-->', $libs)

New-Item -ItemType Directory -Force -Path $outDir | Out-Null
Set-Content -LiteralPath $outFile -Value $html -Encoding UTF8 -NoNewline

'已生成：{0}  ({1:N1} KB)' -f $outFile, ((Get-Item $outFile).Length / 1KB)
