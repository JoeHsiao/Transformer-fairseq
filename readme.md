# Neural Machine Translation (NMT) template in [fairseq](https://github.com/pytorch/fairseq)

This repository demos how to use build-in NMT models in fairseq. The example uses the vanilla Transformer to translate English to Mandarin from news commentaries. fairseq also has plenty of models to choose from, by changing the [--arch](https://fairseq.readthedocs.io/en/latest/command_line_tools.html#fairseq-train) parameter.

# Run
The scripts support Linux and Mac.

Run the command line `pip -r requirements.txt` first, and then execute the bash scripts in order.

To run on Google Colab, copy the repository onto Google Drive, and then launch `colab.ipynb` from there.

# CUDA Installation Links
- CUDA 11.3 installation

    https://developer.nvidia.com/cuda-11.3.0-download-archive?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=deb_local

    https://medium.com/@anarmammadli/how-to-install-cuda-11-4-on-ubuntu-18-04-or-20-04-63f3dee2099

- Pytorch installation (cuda 11.3)

    `pip3 install torch==1.10.1+cu113 torchvision==0.11.2+cu113 torchaudio==0.10.1+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html`

# Q&A
## Why validation loss won't drop during training (overfitting)?
***
Setting `--max-tokens` to 4096 should fix it. Translations of en-zh or zh-en cannot have a smaller value.


## Why do I get the warning `CUDA OOM` during training?
***
The video card simply runs out of memory. On my GTX 1660 TI with 6GB of memory, `--max-tokens 2048 --update-freq 4` removes the majority of the warnings. `--update-freq x` delays backpropagation until `x` batches are reached. This serves as a workaround of needing a larger batch size but video card does not have enough memory.