@echo 開始建造新酷音輸入法詞庫檔(Big5)
dat2bin.exe big5
del *.dat_src
ren ch_index.dat *.dat_src
ren ph_index.dat *.dat_src
ren fonetree.dat *.dat_src
ren *.dat_bin *.dat

@echo 開始建造新酷音輸入法詞庫檔 (UTF-8)
dat2bin.exe utf-8
del *.dat_src
ren ch_index.dat *.dat_src
ren ph_index.dat *.dat_src
ren fonetree.dat *.dat_src
ren *.dat_bin *.dat

pause