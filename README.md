# DLprocess
１．　00deep.pl :　*準備要訓練的 ref data　　
                   *調整json檔案
　　　              直到訓練出四個模型後，然後會用 LAMMPS 執行所輸入的溫度以及步數進行動力學測試

２．　01deep.pl :　＊執行前須先確定所有的動力學測試皆已完成（進行完動力學測試後會出現md.out），主要讀取誤差值，一旦　0.05＜誤差值＜0.2，程式會將此誤差的 data 重新轉換成 QE input 進行scf計算
         
