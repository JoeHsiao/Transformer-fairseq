src=en
tgt=zh
data_dir=data/news-commentary-v15.en-zh
train_pre=bpe.train
val_pre=bpe.val
test_pre=bpe.test
out_dir=bin

rm -rf $data_dir/$out_dir
fairseq-preprocess --source-lang $src --target-lang $tgt \
    --trainpref $data_dir/$train_pre --validpref $data_dir/$val_pre --testpref $data_dir/$test_pre \
    --destdir $data_dir/$out_dir