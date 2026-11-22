echo "Calling convTextures"

@ECHO OFF
if %ToolType%==ASTC (
	@ECHO ON
	echo "Encoding as ASTC"
	"%~dp0astcenc-sse4.1.exe" -cl "%InputFile%" "%OutputFile%.astc" %CustomOptions%
	copy "%OutputFile%.astc" "%OutputFile%" /y
)

@ECHO OFF
if %ToolType%==BCN (
	@ECHO ON
	echo "Encoding as BC7 DDS"
	"%~dp0bc7enc.exe" -g %CustomOptions% "%InputFile%" "%OutputFile%.dds"
	copy "%OutputFile%.dds" "%OutputFile%" /y
)

@ECHO OFF
if %ToolType%==GNF_PS4 (
	@ECHO ON
	echo "Encoding as BC7 GNF for PS4"
	"%SCE_ORBIS_SDK_DIR%\host_tools\bin\orbis-image2gnf.exe" -m 1 -s RLL_GLL_BLL_ALL %CustomOptions% -i "%InputFile%" -o "%OutputFile%.gnf"
	copy "%OutputFile%.gnf" "%OutputFile%" /y
)

@ECHO OFF
if %ToolType%==GNF_PS5 (
	@ECHO ON
	echo "Encoding as BC7 GNF for PS5"
	"%SCE_PROSPERO_SDK_DIR%\host_tools\bin\image2gnf.exe" -m 1 -s RLL_GLL_BLL_ALL %CustomOptions% -i "%InputFile%" -o "%OutputFile%.gnf"
	copy "%OutputFile%.gnf" "%OutputFile%" /y
)