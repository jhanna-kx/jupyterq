:: Conda build
set OP=%PATH%
set PATH=C:\Miniconda3-x64;C:\Miniconda3-x64\Scripts;%PATH%
rmdir /S /Q C:\projects\jupyterq\q\
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86_amd64
:: install conda build requirements (use version < 3.12 to avoid warning about verify in output file)
conda install -y "conda-build<3.12"                                       || goto :error
conda install -y anaconda-client                                          || goto :error
:: set up requirements from requirements.txt
python -c "print('|'.join([line.strip('\n')for line in open('requirements.txt')]))" > reqs.txt
set /P JUPYTERQ_REQS=<reqs.txt
:: set up kdb+ if available
if defined QLIC_KC ( echo|set /P=%QLIC_KC% > kc.lic.enc & certutil -decode kc.lic.enc kc.lic & set QLIC=%CD%)
conda build --output conda-recipe > packagenames.txt                      || goto :error
if defined QLIC_KC (
 conda build -c kx -c jhanna-kx/label/dev conda-recipe                                           || goto :error
) else (
 conda build -c kx -c jhanna-kx/label/dev --no-test conda-recipe                                 || goto :error
)
set PATH=C:\Miniconda3-x64;C:\Miniconda3-x64\Scripts;%OP%
exit /b 0
:error 
echo ERROR
exit /b %errorLevel%

