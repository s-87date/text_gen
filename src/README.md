# Ref
https://qrunch.net/@opqrstuvcut/entries/O37ZGE1YhN5or3Oi

# BertMouth
This repository is a reimplementation of the paper (BERT has a Mouth, and It Must Speak: BERT as a Markov Random Field Language Model: https://arxiv.org/abs/1902.04094).
                                      
## Requirement
- Python3
- PyTorch (1.0+)
- Transformers (2.1.1)
- NumPy
- tqdm 

A trained Pokemon text generation model is https://drive.google.com/uc?id=1vAoIjqhNaru9OjV87VwS64-_WSjInGAQ&export=download.
                                                                                                                                                                      
## Usage                                                                                                                                                                                                   
### generate text

Command example:
```
python ./bert_mouth.py \
--bert_model ./pokemon_model \
--do_generate \
--seq_length 20 \
--max_iter 20
```

- bert_model: trained model path.                                                                                                                                                                     
- max_seq_length: maximum sequence length in BERT. This value depends on pretraining setting. 
- seq_length: generated text length.
- max_iter: maximum number of iteration in the Gibbs sampling.

generated text examples:
1. 弱い獲物を一度捕まえると止まらない。毎日１８時間鳴くチビノーズ。
2. この姿に変化して連れ去ることでお腹を自在に操るピィができるのだ。
3. ボールのように引っ張るため１匹。だが１匹ゆらゆら数は少ない。
4. いつもお腹のヤドンだけが黒真珠のように見える。１番はそのサイン。
5. ドロドロなダンバルはどんなに見境なく冷気でも一瞬でガブリする。
6. 不吉だが長生きでも大丈夫。太い尻尾は鋭いトゲっぺん。
7. 小さなムシを操る。よくゲンガーのクチバシやキバのおかげ。
8. 硬いお腹の模様は危険なＵＢ。大きな岩をもげるとすぐに生える。
9. 化石から復活した科学者を科学力で壊し散らす生命力を持つポケモン。
10. ただ絶対に捕まえないので傷ついた相手には容赦しない。なぜだか。

You can fix a word as below.
```
python ./bert_mouth.py \
--bert_model ./pokemon_model \
--do_generate \
--seq_length 20 \
--max_iter 20 \
--fix_word 花
```

generated text examples:
1. クチバシのように硬い美しい花を使い獲物をアブリーにしてしまうのだ。
2. 小柄で大好物は七色。ペルシアンやトレーナーの美しい花を見つめる。
3. 花を探しに舞い上がる。とりポケモンの中では花畑のペルシアンだ。
4. 大きな花びらの花を食べていて勇敢に戦うときは踊るようなお腹だ。
5. 花を自由に組み替えている。夜には活発に活動するので多くの説がある。

### train on your data 
#### preprocess for train.txt and valid.txt
1. Culate some sentences and save txt as the format below.
```
文1  
文2  
  
文N
```  
2. install juman++, pyknp, mojimoji. 
(you can install pyknp and mojimoji by pip)

3. execute preprocess.py to do morphological analysis and prep.

```
python ./preprocess.py \
--input_file 1で作ったテキストファイルのパス \  
--output_file 出力先のテキストファイルのパス \  
--model xxx/jumanpp-2.0.0-rc2/model/jumandic.jppmdl（jumanのモデルのパスが通っている場合は不要）  
```

4. divide output from preprocess.py into train.txt and valid.txt

#### execute train

Command example:
```
  python ./bert_mouth.py \
  --bert_model ./Japanese_L-12_H-768_A-12_E-30_BPE/ \                                                                                                                                               
  --output_dir ./models \
  --train_file train.txt \
  --valid_file valid.txt \
  --max_seq_length 128 \
  --do_train \
  --train_batch_size 10 \
  --num_train_epochs 100
  ```

- bert_model: pretrained BERT model path.
- output_dir: save path.
- train_file: training file path.
- valid_file: validation file path.
- max_seq_length: maximum sequence length in BERT. This value depends on pretraining setting. 
- train_batch_size: batch size.
- num_train_epochs number of epochs.

The format of training data and validation data: 
```
token_A,1 tokenA,2 ... tokenA,An
token_B,1 tokenB,2 ... tokenB,Bn
︙
```
Each row is tokenized by a tokenizer which is used in pretraining.

Training data example:
```
生まれた とき から 背中 に 不思議な タネ が 植えて あって 体 と ともに 育つ と いう 。
養分 を 摂って 大きく なった つぼみ から 香り が 漂い だす と もう すぐ ハナ が 開く 証拠 だ 。
生まれた とき から 尻尾 に 炎 が 点 って いる 。 炎 が 消えた とき その 命 は 終わって しまう 。
```

note
```
python3 ./src/preprocess.py --input_file ./dat/tachikoma_train.txt --output_file ./dat/tachikoma_train_wakachi.txt --model /Users/shu87/work/jumanpp-2.0.0-rc2/model/jumandic.jppmdl
```

```
python3 ./src/bert_mouth.py --bert_model ./model/Japanese_L-12_H-768_A-12_E-30_BPE/ --output_dir ./model/tachikoma_bert/ --train_file ./dat/train.txt --valid_file ./dat/valid.txt --max_seq_length 128 --do_train --train_batch_size 10 --num_train_epochs 2
```