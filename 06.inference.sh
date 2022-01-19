data_dir=data/news-commentary-v15.en-zh
data_bin_dir=$data_dir/bin
chkp_dir=model/checkpoints

fairseq-interactive ${data_bin_dir} \
--input test.en \
--path ${chkp_dir}/checkpoint_best.pt \
--source-lang en --target-lang zh \
--batch-size 1 --beam 8 \
--remove-bpe subword_nmt \
--bpe subword_nmt --bpe-codes ${data_dir}/code.en \
--tokenizer moses > ${data_dir}/result/inferBeam8.txt