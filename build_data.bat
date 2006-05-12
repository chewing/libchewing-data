@echo 開始建造新酷音輸入法詞庫檔(Big5)
cd big5
dat2bin.exe
del *.dat_src
ren ch_index.dat *.dat_src
ren ph_index.dat *.dat_src
ren fonetree.dat *.dat_src
ren *.dat_bin *.dat

cd ..

@echo 開始建造新酷音輸入法詞庫檔 (UTF-8)
cd utf-8
dat2bin.exe
del *.dat_src
ren ch_index.dat *.dat_src
ren ph_index.dat *.dat_src
ren fonetree.dat *.dat_src
ren *.dat_bin *.dat

@echo 建造完成！
pause