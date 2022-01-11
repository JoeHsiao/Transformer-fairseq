# Zip and split source and target language files into train, validation, and test. Output:
#    train.en
#    train.zh
#    val.en
#    val.zh
#    test.en
#    test.zh

import os, argparse, random

'''
Usage:
python split.py --src=src_fpath --target=tgt_fpath --out-dir=output_dir
'''

def split(args):
    src = 'en'
    tgt = 'zh'
    ratio = (0.6, 0.2, 0.2) # train, validation, test
    random.seed(666)

    src_fp = open(args.src, encoding='utf-8')
    tgt_fp = open(args.target, encoding='utf-8')
    
    src_train, src_val, src_test = \
        open(os.path.join(args.out_dir, f'train.{src}'), 'w', encoding='utf-8'), \
        open(os.path.join(args.out_dir, f'val.{src}'), 'w', encoding='utf-8'), \
        open(os.path.join(args.out_dir, f'test.{src}'), 'w', encoding='utf-8')
        
    tgt_train, tgt_val, tgt_test = \
        open(os.path.join(args.out_dir, f'train.{tgt}'), 'w', encoding='utf-8'), \
        open(os.path.join(args.out_dir, f'val.{tgt}'), 'w', encoding='utf-8'), \
        open(os.path.join(args.out_dir, f'test.{tgt}'), 'w', encoding='utf-8')
    
    src_lines, tgt_lines = src_fp.readlines(), tgt_fp.readlines()
    for s, t in zip(src_lines, tgt_lines):
        rand = random.random()
        if 0 <= rand <= ratio[0]:
            src_train.write(s)
            tgt_train.write(t)
        elif ratio[0] < rand <= ratio[0] + ratio[1]:
            src_val.write(s)
            tgt_val.write(t)
        else:
            src_test.write(s)
            tgt_test.write(t)
            
    src_fp.close()
    tgt_fp.close()
    src_train.close()
    src_val.close()
    src_test.close()
    tgt_train.close()
    tgt_val.close()
    tgt_test.close()
   

if __name__ == '__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--src', help='source language file', required=True)
    parser.add_argument('--target', help='target language file', required=True)
    parser.add_argument('--out-dir', help='output directory', required=True)

    args=parser.parse_args()

    split(args)