python3 ./src/bert_mouth.py --bert_model ./model/tachikoma_bert/20200507025909 --do_generate --seq_length 20 --max_iter 20 --fix_word バトー
python3 ./src/write_gss.py

python3 ./src/bert_mouth.py --bert_model ./model/tachikoma_bert/20200507025909 --do_generate --seq_length 20 --max_iter 20 --fix_word トグサ
python3 ./src/write_gss.py