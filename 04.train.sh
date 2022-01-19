src=en
tgt=zh
data_bin_dir=data/news-commentary-v15.en-zh/bin
chkp_dir=model/checkpoints
tensorboard_dir=loggin

fairseq-train $data_bin_dir \
    --arch transformer \
	--source-lang $src --target-lang $tgt  \
    --optimizer adam  --lr 0.001 --adam-betas '(0.9, 0.98)' \
    --lr-scheduler inverse_sqrt \
    --max-tokens 4096 --update-freq 4 --dropout 0.3 \
    --criterion label_smoothed_cross_entropy \
    --max-update 200000 \
    --keep-last-epochs 10 \
    --tensorboard-logdir $tensorboard_dir \
	--save-dir $chkp_dir | tee log.log
