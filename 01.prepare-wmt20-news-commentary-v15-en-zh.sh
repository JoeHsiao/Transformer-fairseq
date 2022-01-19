# Process tab-separated parallel corpus, final output in the 'data' folder.
# Steps:
#    1. Split parallel corpus into individual language files.
#    2. Punctuation normalization (’ to ', and “” to ").
#    3. Tokenize
#    4. Truecase (skip zh data)
#    5. Clean
#       -removes empty lines
#       -removes redundant space characters
#       -drops lines (and their corresponding lines), that are empty, too short, too long or violate sentence ratio limit
#    6. Split into training, validation and test
#    7. BPE
#       -learned on training, applied to training, val, and test

echo 'Cloning Moses github repository (for tokenization scripts)...'
git clone https://github.com/moses-smt/mosesdecoder.git

echo 'Cloning Subword NMT repository (for BPE pre-processing)...'
git clone https://github.com/rsennrich/subword-nmt.git

SCRIPTS=mosesdecoder/scripts
TOKENIZER=$SCRIPTS/tokenizer/tokenizer.perl
#LC=$SCRIPTS/tokenizer/lowercase.perl
TRUECASE_TRAIN=$SCRIPTS/recaser/train-truecaser.perl
TRUECASE=$SCRIPTS/recaser/truecase.perl
CLEAN=$SCRIPTS/training/clean-corpus-n.perl
NORM_PUNC=$SCRIPTS/tokenizer/normalize-punctuation.perl
REM_NON_PRINT_CHAR=$SCRIPTS/tokenizer/remove-non-printing-char.perl
BPEROOT=subword-nmt/subword_nmt
BPE_TOKENS=40000

URL="http://data.statmt.org/news-commentary/v15/training/news-commentary-v15.en-zh.tsv.gz"
GZ=news-commentary-v15.en-zh.tsv.gz
TSV=news-commentary-v15.en-zh.tsv

if [ ! -d "$SCRIPTS" ]; then
    echo "Not found Moses script directory."
    exit
fi

src=en
tgt=zh
orig=data
prep=$orig/${TSV%.*}
tmp=$prep/tmp

mkdir -p $tmp

echo "Download data from ${URL}..."
cd $prep
wget "$URL"

if [ -f $GZ ]; then
    echo "Data successfully downloaded."
else
    echo "Data was failed downloaded."
    exit
fi

gunzip -f $GZ
cd ..
cd ..

### Separate parallel corpus into individual source and target files
cut -f 1 $prep/${TSV} > $prep/raw.$src | cut -f 2 $prep/${TSV} > $prep/raw.$tgt

### Normalize punctuations
echo "Normalize punctuations..."
for l in $src $tgt; do
    cat $prep/raw.$l | \
        perl $NORM_PUNC $l | \
        perl $REM_NON_PRINT_CHAR | \
        # perl $LC | \
        sed -e "s/\&amp;/\&/g" | \
        sed -e "s/ampamp;/\&/g" | \
        sed -e "s/amp#160;//g" | \
        sed -e "s/lamp#160;//g" | \
        sed -e "s/amp#45;//g" | \
        sed -e "s/ampnbsp;//g" | \
        sed -e "s/\&nbsp;//g" | \
        sed -e "s/\&#160;//g" | \
        sed -e "s/\&#45;//g" | \
        sed -e "s/\&#124;/\|/g" | \
        sed -e "s/\&lt;/\</g" | \
        sed -e "s/amplt;/\</g" | \
        sed -e "s/\&gt;/\>/g" | \
        sed -e "s/ampgt;/\>/g" | \
        sed -e "s/\&apos;/\'/g" | \
        sed -e "s/\&quot;/\"/g" | \
        sed -e "s/ampquot;/\"/g" | \
        sed -e "s/&mdash;/-/g" | \
        sed -e "s/ \. /\./g" | \
        sed -e "s/\. /\./g" | \
        sed -e "s/ \./\./g" | \
        sed -e "s/\&#91;/\[/g" | \
        sed -e "s/\&#93;/\]/g" > $tmp/nor.$l
done

### Tokenize
echo "Tokenize ${src} data..."
cat $tmp/nor.$src | \
    perl $TOKENIZER -threads 8 -a -l $src > $tmp/tok.$src
echo "Tokenize ${tgt} data..."
python3 -m jieba -d " " $tmp/nor.$tgt > $tmp/tok.$tgt

### Truecase
echo "Apply truecase to ${src} data"
mkdir -p $prep/model
perl $TRUECASE_TRAIN --model $prep/model/truecase-model.$src --corpus $tmp/tok.$src
perl $TRUECASE --model $prep/model/truecase-model.$src < $tmp/tok.$src > $tmp/true.$src

### Remove outlier pairs
mv $tmp/true.$src $tmp/for.clean.$src
mv $tmp/tok.$tgt $tmp/for.clean.$tgt
perl $CLEAN -ratio 1.5 $tmp/for.clean $src $tgt $tmp/clean 1 250

### Split data
echo "Split data into training, validation, and test"
python3 split_into_training.py --src=$tmp/clean.$src --target=$tmp/clean.$tgt --out-dir=$tmp

### BPE
BPE_TRAIN=$tmp/bpe.train
BPE_CODE=$prep/code
BPE_VOCAB=$tmp/bpe.vocab

for l in $src $tgt; do
    rm -f $BPE_TRAIN.$l
    cat $tmp/train.$l >> $BPE_TRAIN.$l
    
    echo "learn_bpe.py on ${l}..."
    python3 $BPEROOT/learn_joint_bpe_and_vocab.py --input $BPE_TRAIN.$l -s $BPE_TOKENS -o $BPE_CODE.$l --write-vocabulary $BPE_VOCAB.$l

    for d in train val test; do
        echo "apply_bpe.py to ${d}.${l}..."
        python3 $BPEROOT/apply_bpe.py -c $BPE_CODE.$l --vocabulary $BPE_VOCAB.$l < $tmp/$d.$l > $prep/bpe.$d.$l
    done
done