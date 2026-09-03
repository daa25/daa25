$ErrorActionPreference='Continue'
$Root='C:\VibeOps_Control'
$Reports=Join-Path $Root 'Reports'
New-Item -ItemType Directory -Force -Path $Root,$Reports|Out-Null
$Stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
$Run=Join-Path $Reports "Audit_$Stamp"
New-Item -ItemType Directory -Force -Path $Run|Out-Null

Write-Host ''
Write-Host 'VIBEOPS MASTER RECOVERY AUDIT' -ForegroundColor Yellow
Write-Host 'READ-ONLY: source files will not be deleted, moved, renamed, or edited.' -ForegroundColor Green
Write-Host ''

$Biz=@{
'VibeFlex'=@('vibeflex','lacedup','490 movement','uncooked');
'VibeLink'=@('vibelink','property enhancement');
'VibeOps'=@('vibeops');
'VibeDeal AI'=@('vibedeal','vibe-deal','deal flow');
'ReapSow'=@('reapsow','reap sow');
'Elite Eleven'=@('elite eleven','elite11','elite-eleven');
'WinRep'=@('winrep');
'Vela'=@('vela','luxury curtains')}
$Markers=@('package.json','pyproject.toml','requirements.txt','Pipfile','composer.json','Cargo.toml','go.mod','Gemfile','pom.xml','build.gradle','build.gradle.kts','pubspec.yaml')
$CodeExt=@('.js','.jsx','.ts','.tsx','.py','.rb','.php','.java','.kt','.go','.rs','.cs','.swift','.dart','.html','.css','.scss','.sql','.json','.toml','.yaml','.yml','.xml','.liquid','.graphql','.gql')
$AssetExt=@('.png','.jpg','.jpeg','.webp','.svg','.ai','.eps','.psd','.tif','.tiff','.dxf')
$AudioExt=@('.wav','.mp3','.aiff','.aif','.flac','.m4a','.mid','.midi','.als','.flp','.ptx','.ptf')
$DocExt=@('.pdf','.doc','.docx','.xls','.xlsx','.ppt','.pptx','.txt','.md','.csv')
$ArchiveExt=@('.zip','.rar','.7z','.tar','.gz','.tgz')
$InstallExt=@('.exe','.msi','.msix','.appx')
$JunkDirs=@('node_modules','.next','.nuxt','dist','build','__pycache__','.pytest_cache','.mypy_cache','.cache','.gradle','.expo','.turbo','.parcel-cache')
$SystemDirs=@('$recycle.bin','system volume information','windows','program files','program files (x86)','programdata','recovery','msocache','appdata')

function BizHits([string]$Text){$l=$Text.ToLowerInvariant();$o=@();foreach($k in $Biz.Keys){foreach($w in $Biz[$k]){if($l.Contains($w)){$o+=$k;break}}};@($o|Sort-Object -Unique)}
function Classify($f){$e=$f.Extension.ToLowerInvariant();if($CodeExt-contains$e){'CODE'}elseif($AssetExt-contains$e){'ASSET'}elseif($AudioExt-contains$e){'AUDIO'}elseif($DocExt-contains$e){'DOCUMENT'}elseif($ArchiveExt-contains$e){'ARCHIVE'}elseif($InstallExt-contains$e){'INSTALLER'}else{'OTHER'}}

$Roots=@();if(Test-Path $env:USERPROFILE){$Roots+=$env:USERPROFILE};foreach($d in Get-PSDrive -PSProvider FileSystem|Where-Object{$_.Root-match'^[A-Z]:\\$'}){if($d.Name-ne'C'){$Roots+=$d.Root}};$Roots=@($Roots|Sort-Object -Unique)
Write-Host ('Scanning: '+($Roots-join', ')) -ForegroundColor Cyan

$Files=New-Object System.Collections.Generic.List[object]
$Projects=@{}
$Junk=New-Object System.Collections.Generic.List[object]
$Errors=New-Object System.Collections.Generic.List[object]
$count=0
foreach($root in $Roots){$stack=New-Object System.Collections.Generic.Stack[string];$stack.Push($root);while($stack.Count-gt0){$cur=$stack.Pop();try{$entries=@([IO.Directory]::EnumerateFileSystemEntries($cur))}catch{$Errors.Add([pscustomobject]@{Path=$cur;Error=$_.Exception.GetType().Name});continue};$names=@{};foreach($x in $entries){try{$names[[IO.Path]::GetFileName($x).ToLowerInvariant()]=$x}catch{}};foreach($m in $Markers){if($names.ContainsKey($m.ToLowerInvariant()) -and [IO.File]::Exists($names[$m.ToLowerInvariant()])){if(-not$Projects.ContainsKey($cur)){$Projects[$cur]=New-Object System.Collections.Generic.HashSet[string]};[void]$Projects[$cur].Add($m)}};if($names.ContainsKey('.git')-and[IO.Directory]::Exists($names['.git'])){if(-not$Projects.ContainsKey($cur)){$Projects[$cur]=New-Object System.Collections.Generic.HashSet[string]};[void]$Projects[$cur].Add('.git')};foreach($x in $entries){try{if([IO.Directory]::Exists($x)){$leaf=[IO.Path]::GetFileName($x).ToLowerInvariant();if($JunkDirs-contains$leaf){$Junk.Add([pscustomobject]@{Path=$x;Reason='generated/cache directory'});continue};if($SystemDirs-contains$leaf -or $leaf-eq'.git'){continue};$stack.Push($x);continue};if(-not[IO.File]::Exists($x)){continue};$f=[IO.FileInfo]$x;$Files.Add([pscustomobject]@{Path=$f.FullName;Size=$f.Length;Modified=$f.LastWriteTime.ToString('s');Extension=$f.Extension.ToLowerInvariant();Classification=(Classify $f);Businesses=((BizHits $f.FullName)-join'; ')});$count++;if(($count%10000)-eq0){Write-Host("Inventoried {0:N0} files..."-f$count)}}catch{$Errors.Add([pscustomobject]@{Path=$x;Error=$_.Exception.GetType().Name})}}}}

$ProjectRows=@();foreach($p in $Projects.Keys){$score=8;$caps=@('project code');$names=@();try{$names=@([IO.Directory]::EnumerateFileSystemEntries($p)|ForEach-Object{[IO.Path]::GetFileName($_).ToLowerInvariant()})}catch{};if($Projects[$p].Contains('package.json')){$score+=12;$caps+='application code'};if($Projects[$p].Contains('.git')){$score+=8;$caps+='version control'};if($names-contains'readme.md'){$score+=5;$caps+='documentation'};if($names-contains'vercel.json' -or $names-contains'netlify.toml' -or $names-contains'dockerfile' -or $names-contains'.github'){$score+=10;$caps+='deployment/CI'};$text='';foreach($n in @('package.json','README.md','readme.md')){$q=Join-Path $p $n;if(Test-Path $q){try{$fi=Get-Item $q;if($fi.Length-lt2000000){$text+=[IO.File]::ReadAllText($q).ToLowerInvariant()}}catch{}}};foreach($z in @(@('shopify',8,'Shopify'),@('printful',6,'fulfillment'),@('stripe',6,'payments'),@('supabase',8,'Supabase'),@('auth',5,'authentication'),@('openai',4,'AI'),@('revenuecat',5,'subscriptions'),@('expo',5,'mobile app'),@('next',5,'Next.js'),@('react',3,'React'),@('webhook',4,'webhooks'))){if($text.Contains($z[0])){$score+=[int]$z[1];$caps+=$z[2]}};$bh=@(BizHits $p);if($bh.Count-gt0){$score+=[Math]::Min(10,3*$bh.Count)};$score=[Math]::Min(100,$score);$cl=if($score-ge60){'LAUNCH CANDIDATE'}elseif($score-ge35){'KEEP / DEVELOP'}else{'ARCHIVE / REVIEW'};$ProjectRows+=[pscustomobject]@{Name=[IO.Path]::GetFileName($p.TrimEnd('\'));Path=$p;Businesses=($bh-join'; ');ReadinessScore=$score;Classification=$cl;Markers=(@($Projects[$p])-join'; ');Capabilities=(($caps|Sort-Object -Unique)-join'; ')}}
$ProjectRows=@($ProjectRows|Sort-Object ReadinessScore -Descending)

Write-Host 'Checking exact duplicates...' -ForegroundColor Cyan
$Duplicates=@();$gid=0;$groups=$Files|Where-Object{$_.Size-gt0 -and $_.Size-le2147483648}|Group-Object Size|Where-Object Count-gt1;$n=0;foreach($g in $groups){$n++;$hg=@{};foreach($i in $g.Group){try{$h=(Get-FileHash -LiteralPath $i.Path -Algorithm SHA256 -ErrorAction Stop).Hash;if(-not$hg.ContainsKey($h)){$hg[$h]=@()};$hg[$h]+=$i}catch{}};foreach($h in $hg.Keys){if($hg[$h].Count-gt1){$gid++;foreach($i in $hg[$h]){$Duplicates+=[pscustomobject]@{Group=$gid;SHA256=$h;Path=$i.Path;Size=$i.Size}}}};if(($n%250)-eq0){Write-Host("Duplicate analysis: $n / $($groups.Count) groups...")}}

$ProjectRows|Export-Csv(Join-Path $Run 'PROJECTS.csv')-NoTypeInformation-Encoding UTF8
$Files|Export-Csv(Join-Path $Run 'FILE_INVENTORY.csv')-NoTypeInformation-Encoding UTF8
$Duplicates|Export-Csv(Join-Path $Run 'DUPLICATES.csv')-NoTypeInformation-Encoding UTF8
$Junk|Export-Csv(Join-Path $Run 'JUNK_DIRECTORIES.csv')-NoTypeInformation-Encoding UTF8
$Errors|Export-Csv(Join-Path $Run 'SCAN_ERRORS.csv')-NoTypeInformation-Encoding UTF8
$lines=@('VIBEOPS MASTER RECOVERY AUDIT','======================================================================',"Generated: $((Get-Date).ToString('s'))","Scan roots: $($Roots-join', ')","Files inventoried: $($Files.Count)","Projects found: $($ProjectRows.Count)","Launch candidates: $(@($ProjectRows|Where-Object Classification-eq'LAUNCH CANDIDATE').Count)","Exact duplicate groups: $(@($Duplicates|Select-Object -ExpandProperty Group -Unique).Count)",'','TOP PROJECTS','----------------------------------------------------------------------');$i=0;foreach($p in $ProjectRows|Select-Object -First 25){$i++;$lines+="$i. $($p.Name) | score $($p.ReadinessScore)/100 | $($p.Classification)";$lines+="   Path: $($p.Path)";$lines+="   Business: $($p.Businesses)";$lines+="   Capabilities: $($p.Capabilities)"};$lines+='';$lines+='IMPORTANT';$lines+='- No source files were deleted, moved, renamed, or modified.';$lines+='- Exact duplicate groups use SHA-256; nothing was deleted automatically.';$lines|Set-Content(Join-Path $Run 'SUMMARY_FOR_CHATGPT.txt')-Encoding UTF8
$Zip=Join-Path $Reports "VibeOps_Audit_Report_$Stamp.zip";Compress-Archive -Path(Join-Path $Run '*')-DestinationPath $Zip-Force
Write-Host '';Write-Host 'AUDIT COMPLETE' -ForegroundColor Green;Write-Host 'Nothing was deleted or moved.' -ForegroundColor Green;Write-Host "UPLOAD THIS ZIP TO CHATGPT: $Zip" -ForegroundColor Yellow;Set-Clipboard -Value $Zip;Start-Process explorer.exe -ArgumentList "/select,`"$Zip`""
