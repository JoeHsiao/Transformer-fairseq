data_dir=data/news-commentary-v15.en-zh
data_bin_dir=$data_dir/bin

fairseq-interactive $data_bin_dir \
    --input ${data_dir}/test.zh \
    --path $$chkp_dir/checkpoint_best.pt \
    --batch-size 1 --beam 8 --remove-bpe > ${data_dir}/result/inferBeam8.txt