# Neural Machine Translation (NMT) template in [fairseq](https://github.com/pytorch/fairseq)

This repository demos how to use build-in NMT models in fairseq. The example uses the vanilla Transformer to translate English to Mandarin from news commentaries. fairseq also has plenty of build-in models to choose from, check the [--arch](https://fairseq.readthedocs.io/en/latest/command_line_tools.html#fairseq-train) parameter.

# Run
The scripts run on Linux and Mac.

1. Execute `pip -r requirements.txt`.

2. Run bash scripts in the repository one by one through the `bash` command, e.g. `bash 01.prepare-wmt20-news-commentar.sh`.

The scrips also run on Google Colab, simply copy the repository to your Google Drive, and then launch `colab.ipynb` from there. A GPU runtime type on Colab is recommended.

# CUDA Installation Links
CUDA setup commands on my desktop.
- CUDA 11.3 installation

    https://developer.nvidia.com/cuda-11.3.0-download-archive?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=deb_local

    https://medium.com/@anarmammadli/how-to-install-cuda-11-4-on-ubuntu-18-04-or-20-04-63f3dee2099

- Pytorch installation (cuda 11.3)

    `pip3 install torch==1.10.1+cu113 torchvision==0.11.2+cu113 torchaudio==0.10.1+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html`

# Q&A
## Why is validation loss not dropping (overfitting)?
Set `--max-tokens 4096` should fix it. Translations for en-zh or zh-en require at least such value.


## Why do I get the warning `CUDA OOM` during training?
The video card simply runs out of memory. On my GTX 1660 TI with 6GB of memory, `--max-tokens 2048 --update-freq 4` gets rid of most warnings, and stablizes after epoch 2. `--update-freq x` delays weights adjustment until `x` batches are reached. This parameter serves as a workaround in situations where a larger batch size is needed but video card does not have enough memory.
