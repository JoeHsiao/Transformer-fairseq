data_dir=data/news-commentary-v15.en-zh
data_bin_dir=$data_dir/bin
chkp_dir=model/checkpoints
result_dir=$data_dir/result

mkdir -p $result_dir

fairseq-generate $data_bin_dir \
    --path $chkp_dir/checkpoint_best.pt \
    --batch-size 64 --beam 8 > $data_dir/result/benchmarkbeam8.txt