@echo off
rem ===========================================================================
rem  build.bat — 一键构建（YYC 打包 zip）
rem
rem  流程：
rem    [1] 重跑数据表生成脚本
rem          tools\gen_level_hashes.py   关卡哈希表
rem          tools\gen_sprite_trim.py    敌人贴图包围盒表
rem    [2] 清理上一次的构建产物
rem          <父目录>\output\FVM-reborn  上一次的 data.win / exe / dll
rem          build_out\*.zip, *.log
rem    [3] Igor 命令行 + YYC 编译，产物 build_out\FVM-reborn_yyc.zip
rem
rem  用法：双击运行，或在命令行里
rem         build.bat              默认（清产物，走增量构建，最快）
rem         build.bat -noclean     什么都不删（连增量产物都留着）
rem         build.bat -deepclean   额外物理删除 cache\FVM-reborn（很慢，几十分钟）
rem                                只在怀疑资源缓存损坏时用
rem         build.bat -vm          改用 VM 编译（快，不跑 C++ 编译）
rem         build.bat -log         Igor 输出写入 build_out\igor_build.log
rem                                （构建期间控制台看不到进度）
rem         build.bat -nobuild     只跑生成脚本 + 清理，不构建
rem
rem  环境变量（可选，只有自动探测失败时才需要）：
rem         PYTHON          python 解释器命令，默认 py -3，其次 python
rem         GM_RUNTIME      运行时根目录 runtime-xxxx
rem         GM_USER_FOLDER  含 licence.plist 的用户目录
rem
rem  踩过的坑（改这个文件前先看）：
rem   1. 路径一律转成正斜杠再传给 Igor —— Igor 参数解析遇到反斜杠会抛
rem      ArgumentOutOfRangeException。
rem   2. 不要给 Igor 传 --of。runtime 2024.14.4 上 --of 会把 MSBuild 的输出
rem      目录一起改掉，而 Igor 收尾仍去 cache\...\Sln\x64\Release\ 找
rem      FVM_reborn.exe，结果 C++ 编译成功、打包阶段抛 FileNotFoundException。
rem   3. 本文件是 GBK(936) 编码 + CRLF 行尾。cmd 是按字节偏移读批处理的：
rem      存成 UTF-8 或 LF 会让解析错位（表现为一行被拆成几条命令、goto 跳错）。
rem   4. Igor / MSBuild 的输出是 UTF-8，所以调用它前后要 chcp 65001 / 切回来。
rem   5. 不要加 --ic（ignorecache）。它会让 Igor 重新生成 vcxproj 并把 MSBuild 的
rem      OutDir 指到目标输出目录，而打包阶段仍去 cache\...\Sln\x64\Release\
rem      找 FVM_reborn.exe，于是 C++ 编译成功、打包抛 FileNotFoundException。
rem ===========================================================================
setlocal EnableExtensions EnableDelayedExpansion

rem 带参数 = 命令行调用，跑完不等；双击（无参数）跑完停一下，好让结果留在屏幕上
set "HAS_ARGS=0"
if not "%~1"=="" set "HAS_ARGS=1"

cd /d "%~dp0.."
set "ROOT=%CD%"
for %%I in ("%ROOT%\..") do set "PARENT=%%~fI"

set "PROJNAME=FVM-reborn"
set "YYP=%ROOT%\%PROJNAME%.yyp"
set "OUTDIR=%ROOT%\build_out"
set "LOG_FILE=%OUTDIR%\igor_build.log"
set "GM_CACHE=%PARENT%\cache\%PROJNAME%"
set "GM_OUT=%PARENT%\output\%PROJNAME%"

rem ---------------------------------------------------------------------------
rem 参数
rem   OPT_CLEAN: 0=不清理  1=清产物（默认）  2=清产物+删缓存目录
rem ---------------------------------------------------------------------------
set "OPT_CLEAN=1"
set "OPT_RUNTIME=YYC"
set "OPT_LOG=0"
set "OPT_BUILD=1"

:parse_args
if "%~1"=="" goto :args_done
if /i "%~1"=="-noclean"   goto :arg_noclean
if /i "%~1"=="-deepclean" goto :arg_deepclean
if /i "%~1"=="-vm"        goto :arg_vm
if /i "%~1"=="-log"       goto :arg_log
if /i "%~1"=="-nobuild"   goto :arg_nobuild
echo [错误] 未知参数：%~1
echo        可用参数：-noclean  -deepclean  -vm  -log  -nobuild
goto :fail
:arg_noclean
set "OPT_CLEAN=0"
goto :next_arg
:arg_deepclean
set "OPT_CLEAN=2"
goto :next_arg
:arg_vm
set "OPT_RUNTIME=VM"
goto :next_arg
:arg_log
set "OPT_LOG=1"
goto :next_arg
:arg_nobuild
set "OPT_BUILD=0"
goto :next_arg
:next_arg
shift
goto :parse_args
:args_done

if not exist "%YYP%" (
    echo [错误] 找不到项目文件：%YYP%
    goto :fail
)

echo ===========================================================================
echo  美食大战老鼠：重生 — 一键构建
echo ---------------------------------------------------------------------------
echo   项目：%YYP%
echo   模式：%OPT_RUNTIME% / PackageZip
echo   清理：%OPT_CLEAN%  ^(0=不清理, 1=清产物, 2=再加删缓存目录^)
echo   日志：%OPT_LOG%  ^(1=写文件, 0=只在控制台^)
echo   开始：%DATE% %TIME%
echo ===========================================================================

rem 缓存被占用是清不掉的，提前吱一声
"%SystemRoot%\System32\tasklist.exe" /fi "imagename eq GameMaker.exe" 2>nul | "%SystemRoot%\System32\find.exe" /i "GameMaker.exe" >nul
if not errorlevel 1 (
    echo [提示] GameMaker IDE 正在运行，清理缓存和构建可能失败，建议先关掉它。
    echo.
)

rem ---------------------------------------------------------------------------
rem [1/3] 生成数据表
rem ---------------------------------------------------------------------------
echo [1/3] 重新生成数据表
set "PY="
if defined PYTHON set "PY=%PYTHON%"
if not defined PY (
    "%SystemRoot%\System32\where.exe" py >nul 2>nul
    if not errorlevel 1 set "PY=py -3"
)
if not defined PY (
    "%SystemRoot%\System32\where.exe" python >nul 2>nul
    if not errorlevel 1 set "PY=python"
)
if not defined PY (
    echo   [错误] 找不到 Python。装好 Python 3 后确保 py / python 在 PATH 里，
    echo          或先 set PYTHON=D:\Python313\python.exe 再运行本脚本。
    goto :fail
)
echo   - 解释器：%PY%
rem 固定 Python 输出编码，避免继承了 PYTHONUTF8 之类的环境变量时控制台出现乱码
set "PYTHONIOENCODING=gbk:replace"

call :run_py "tools\gen_level_hashes.py" "关卡哈希表"
if errorlevel 1 goto :fail
call :run_py "tools\gen_sprite_trim.py" "敌人贴图包围盒表"
if errorlevel 1 goto :fail

rem ---------------------------------------------------------------------------
rem [2/3] 清理
rem ---------------------------------------------------------------------------
echo.
echo [2/3] 清理上一次的构建产物
if "%OPT_CLEAN%"=="0" goto :clean_skipped

call :rmdir "%GM_OUT%"
if exist "%OUTDIR%" (
    if exist "%OUTDIR%\*.zip" (
        echo   - 删除 %OUTDIR%\*.zip
        del /q "%OUTDIR%\*.zip" 2>nul
    )
    if exist "%LOG_FILE%" del /q "%LOG_FILE%" 2>nul
    if exist "%OUTDIR%\*.manifest" del /q "%OUTDIR%\*.manifest" 2>nul
)
if not "%OPT_CLEAN%"=="2" goto :clean_done
echo   - 深清理：连资源缓存一起删（文件数万级，要几分钟）
call :rmdir_huge "%GM_CACHE%"
goto :clean_done

:clean_skipped
echo   - 跳过（-noclean，走增量构建）
:clean_done
if not exist "%OUTDIR%" mkdir "%OUTDIR%" 2>nul

if "%OPT_BUILD%"=="0" (
    echo.
    echo [跳过] 按要求不构建（-nobuild）。数据表已刷新。
    goto :done
)

rem ---------------------------------------------------------------------------
rem [3/3] 构建
rem ---------------------------------------------------------------------------
echo.
echo [3/3] 构建（%OPT_RUNTIME%）

set "IGOR="
set "RT="
set "RUNTIMES=%PROGRAMDATA%\GameMakerStudio2\Cache\runtimes"
if defined GM_RUNTIME set "RT=%GM_RUNTIME%"
rem 按名字倒序取第一个带 Igor.exe 的运行时
if not defined RT (
    for /f "delims=" %%D in ('dir /b /ad /o-n "%RUNTIMES%\runtime-*" 2^>nul') do (
        if not defined RT if exist "%RUNTIMES%\%%D\bin\igor\windows\x64\Igor.exe" set "RT=%RUNTIMES%\%%D"
    )
)
if defined RT if exist "%RT%\bin\igor\windows\x64\Igor.exe" set "IGOR=%RT%\bin\igor\windows\x64\Igor.exe"
if not defined IGOR (
    echo   [错误] 找不到 Igor.exe。请在 GameMaker IDE 里装好运行时，
    echo          或 set GM_RUNTIME=C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2024.14.4.268
    goto :fail
)

set "UF="
if defined GM_USER_FOLDER set "UF=%GM_USER_FOLDER%"
if not defined UF (
    for /d %%A in ("%APPDATA%\GameMakerStudio2*") do (
        for /d %%B in ("%%~A\*") do (
            if exist "%%~B\licence.plist" set "UF=%%~B"
        )
    )
)
if not defined UF (
    echo   [错误] 找不到带 licence.plist 的用户目录。先在 IDE 里登录一次，
    echo          或 set GM_USER_FOLDER=%%APPDATA%%\GameMakerStudio2-LTS2026\你的ID
    goto :fail
)

rem 路径转正斜杠（见文件头「坑 1」）
set "F_YYP=%YYP:\=/%"
set "F_RP=%RT:\=/%"
set "F_UF=%UF:\=/%"
set "F_TF=%OUTDIR%\%PROJNAME%_yyc.zip"

echo   Igor    : %IGOR%
echo   运行时  : %RT%
echo   用户目录: %UF%
echo   产物    : %F_TF%

rem 注意：不要传 --of、也不要传 --ic（见文件头「坑 2」「坑 5」）
set IGOR_ARGS=--project="%F_YYP%" --config=Default --runtime=%OPT_RUNTIME% --target=Windows --rp="%F_RP%" --uf="%F_UF%"
set IGOR_ARGS=%IGOR_ARGS% --tf="%F_TF%" windows PackageZip

echo ---------------------------------------------------------------------------
echo   构建中，冷缓存全量 YYC 大约十几分钟，请勿关闭本窗口。
if "%OPT_LOG%"=="1" echo   输出已重定向到日志，期间控制台不会有进度：%LOG_FILE%
echo ---------------------------------------------------------------------------

rem Igor 把 cache/ 和 output/ 建在**当前工作目录**下，必须固定在项目父目录，
rem 否则会在 tools\ 里生成一堆垃圾。
rem Igor / MSBuild 的输出是 UTF-8，控制台切到 65001 才不乱码；本脚本自己的
rem 提示是 GBK，所以调用完要切回原代码页。
for /f "tokens=2 delims=:" %%C in ('chcp') do set "OLDCP=%%C"
set "OLDCP=%OLDCP: =%"
chcp 65001 >nul
pushd "%PARENT%"
if "%OPT_LOG%"=="1" (
    "%IGOR%" %IGOR_ARGS% > "%LOG_FILE%" 2>&1
) else (
    "%IGOR%" %IGOR_ARGS%
)
set "IGOR_RC=%ERRORLEVEL%"
popd
if defined OLDCP chcp %OLDCP% >nul 2>nul

echo ---------------------------------------------------------------------------
echo   Igor 结束，退出码 %IGOR_RC%（Igor 出错也常返回 0，所以下面看产物判断）
if "%OPT_LOG%"=="1" if exist "%LOG_FILE%" echo   日志：%LOG_FILE%

rem Igor 的退出码不可靠，用「打包文件存在且非空」当成功凭据
set "ZSIZE=0"
if exist "%F_TF%" for %%F in ("%F_TF%") do set "ZSIZE=%%~zF"
if !ZSIZE! LEQ 0 goto :build_failed

set /a "ZMB=!ZSIZE! / 1048576"
echo.
echo ===========================================================================
echo   [完成] 构建成功（%OPT_RUNTIME%）
echo ---------------------------------------------------------------------------
echo   产物：%F_TF%
echo   大小：!ZMB! MB（!ZSIZE! 字节）
echo   结束：%DATE% %TIME%
if exist "%OUTDIR%\FVM_reborn.exe" echo   编译产物：%OUTDIR%\FVM_reborn.exe
echo.
echo   试跑提示：解压 zip 后直接运行里面的 FVM_Reborn.exe。
echo             存档目录是 %%LOCALAPPDATA%%\FVM_Reborn\，不要在压缩包里跑。
echo ===========================================================================
goto :done

:build_failed
echo.
echo ===========================================================================
echo   [失败] 没有生成打包文件：%F_TF%
echo ---------------------------------------------------------------------------
if /i "%OPT_RUNTIME%"=="YYC" (
    echo   YYC 需要 Visual Studio 2019/2022 的「C++ 桌面开发」工作负载，
    echo   并在 GameMaker 的 文件-首选项-平台-Windows 里指定它的路径。
    echo   想先确认逻辑没问题，可以用：build.bat -vm
) else (
    echo   编译出错，看上面的输出。
)
if "%OPT_LOG%"=="0" echo   加 -log 参数重跑可以把完整 Igor 输出存成 %LOG_FILE%
echo ===========================================================================
goto :fail

rem ---------------------------------------------------------------------------
rem 子过程
rem ---------------------------------------------------------------------------
:run_py
echo   - %~2（%~1）
pushd "%ROOT%"
%PY% "%~1"
set "PY_RC=%ERRORLEVEL%"
popd
if not "%PY_RC%"=="0" (
    echo   [失败] %~2 生成失败（退出码 %PY_RC%），已中止。
    exit /b 1
)
exit /b 0

:rmdir
rem 普通目录：文件不多，直接删
if not exist "%~1" exit /b 0
echo   - 删除 %~1
rd /s /q "%~1" 2>nul
if exist "%~1" echo     [警告] 没删干净（多半被游戏或 IDE 占着），关掉它们再重试。
exit /b 0

:rmdir_huge
rem 缓存目录里有几万个贴图页小文件（.tpe.qoi），rd /s 是一个个删，叠加 Defender
rem 实时扫描会慢到 10 个/秒；从空目录 /MIR 镜像过来是批量删除，实测快 25 倍。
if not exist "%~1" exit /b 0
echo   - 删除 %~1
set "EMPTYDIR=%TEMP%\__fvm_empty_dir"
if not exist "%EMPTYDIR%" mkdir "%EMPTYDIR%" 2>nul
if exist "%SystemRoot%\System32\robocopy.exe" (
    "%SystemRoot%\System32\robocopy.exe" "%EMPTYDIR%" "%~1" /MIR /NFL /NDL /NJH /NJS /NC /NS /NP >nul 2>nul
)
rd /s /q "%~1" 2>nul
rd "%EMPTYDIR%" 2>nul
if exist "%~1" echo     [警告] 没删干净（多半被游戏或 IDE 占着），关掉它们再重试。
exit /b 0

:done
if "%HAS_ARGS%"=="0" pause
endlocal
exit /b 0

:fail
if "%HAS_ARGS%"=="0" pause
endlocal
exit /b 1
