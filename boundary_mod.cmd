@echo off
  set PATH=e:\usr\%username%\therm;%PATH%

    if not exist e:\usr\%username%\therm\cat.exe xcopy /y \\ws-3\e\usr\sr01201\therm\cat.exe e:\usr\%username%\therm >nul 2>&1
  if not exist e:\usr\%username%\therm\sed.exe xcopy /y \\ws-3\e\usr\sr01201\therm e:\usr\%username% >nul 2>&1
  if not exist e:\usr\%username%\therm\libiconv2.dll xcopy /y \\ws-3\e\usr\sr01201\therm e:\usr\%username% >nul 2>&1
  if not exist e:\usr\%username%\therm\libintl3.dll xcopy /y \\ws-3\e\usr\sr01201\therm e:\usr\%username% >nul 2>&1
  if not exist e:\usr\%username%\therm\regex2.dll xcopy /y \\ws-3\e\usr\sr01201\therm e:\usr\%username% >nul 2>&1
  if not exist e:\usr\%username%\therm\diff.exe xcopy /y \\ws-3\e\usr\sr01201\therm e:\usr\%username% >nul 2>&1
  if not exist e:\usr\%username%\therm\uniq.exe (
    echo "PUT sed.exe (>v4.0.1), libiconv2.dll, libintl3.dll, regex2.dll, grep.exe, diff.exe (optional), uniq.exe TO e:\usr\%username%\therm"
    goto pause
    )
  
::Вывод списка шагов (работаем с копией, которая будет меняться от шага к шагу)
copy /y abaqus.inp temp.inp >nul 2>&1
grep -i "solve for step" temp.inp > steps.txt

::Вывод списка шагов -1 (чтобы заранее иметь номер следующего шага)
copy /y steps.txt nexteps.txt >nul 2>&1
sed -i "1d" nexteps.txt

::Добавить в конец списка ...hare...
echo ** ------------ SOLVE FOR STEP hare ------------>> steps.txt

:loop
::Читать первую строку steps.txt в переменную и обрезать ее, 31 от начала и 13 от конца, чтобы получить номер шага	  
set curstep=
set nextep=
set /p curstep=<steps.txt
  set curstep=%curstep:~31%
  set curstep=%curstep:~0,-13%
	  if /i %curstep% neq hare echo %curstep%
	  
	  :: Читать заранее следующий шаг
	  set /p nextep=<nexteps.txt
		set nextep=%nextep:~31%
		set nextep=%nextep:~0,-13%

		::Если 'шаг == hare' то закончить процедуру
	  if /i %curstep% equ hare goto fin

		  ::Вывод inp вплоть до начала первого мудреного блока в файл
		  sed -n "/*HEADING/,$p;/(step %curstep%)/q" temp.inp > start.txt

		  ::Удаление строки, содержащей (step / , в данном случае - последней строки
		  ::sed -i -e "/(step/d" start.txt

        :: Вывод концовки1 (от (step x) до конца файла)
		sed -n "/(step %curstep%)/,$p" temp.inp > end.txt
	  
		::Выделить из концовки очередной мод (от (step x) до **Chaman):
		sed -n "/(step %curstep%)/,$p;/Chaman/q" end.txt > mod%curstep%.txt
		
		::Выделить из концовки очередной немод (от **Chaman до первого из найденных (step x+1)):
		sed -n "/Chaman/,$p;/(step %nextep%)/q" end.txt > nomod%curstep%.txt
		
		::Выделить новую концовку (от (step x+1) до конца файла):
		sed -n "/(step %nextep%)/,$p" end.txt > next_end.txt
		::move /y new_end.txt end.txt >nul 2>&1
		
				::Замена *TEMPERATURE, OP=MOD на *boundary внутри мода
				sed -i "s/*TEMPERATURE, OP=MOD/*boundary/g" mod%curstep%.txt

				::Замена , на ,11,11, внутри мода
				sed -i "s/, /,11,11,/g" mod%curstep%.txt
			
			::Дописать получившийся конец к первой части файла с перезаписью исходной копии
			cat start.txt mod%curstep%.txt nomod%curstep%.txt next_end.txt > mod.inp
			move /y new_end.txt end.txt >nul 2>&1

		::Удалить первую строку в steps.txt и перейти к следующему шагу (step 2)
		sed -i -e "1d" nexteps.txt
		sed -i -e "1d" steps.txt
	  
	  if /i %curstep% neq hare (
	  copy /y mod.inp temp.inp >nul 2>&1
	  ::uniq mod.inp > temp.inp
	  goto loop
	  )
	  
:fin
:: Удаление временных файлов
del *.txt >nul 2>&1
del sed* >nul 2>&1

move /y mod.inp abaqus_mod.inp >nul 2>&1

::Отчет по разнице между файлами
rem diff abaqus.inp abaqus_mod.inp > result.diff

:pause
pause
