csplit dat/tachikoma_train_wakachi.txt $(( $(wc -l < dat/tachikoma_train_wakachi.txt) * 2 / 10 + 1))
mv ./xx00 ./dat/valid.txt
mv ./xx01 ./dat/train.txt
