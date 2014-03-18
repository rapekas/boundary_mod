boundary_mod
============

This CMD modifies abaqus.inp with T_imposee, generated from WB cae4abaqus into Patran format (to be able to calculate)


Утилита переводит  abaqus.inp с подогревом формата WB в формат Patran, т.е. тот, который понимает решатель.

Утилита находит все шаги в INP со строками *TEMPERATURE, OP=MOD и делает замену на *boundary, а также вписывает в каждую строку таких блоков 11,11,

Как использовать:

В папку с boundary_mod.cmd подложить исходный файл abaqus.inp (переименовывать нельзя). Запустить командный файл, дождаться результата abaqus_mod.inp.

Утилита работает как со stabi, так и с mission. 
