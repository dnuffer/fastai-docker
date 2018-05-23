# to mount the fastai directory from locally for persistence, use the following docker run command:
# docker run --runtime=nvidia -it -p8888:8888 -v ~/src/fastai:/home/fastai/fastai -u $(id -u):$(id -g) fastai

FROM nvidia/cuda:9.2-cudnn7-devel-ubuntu16.04

LABEL com.nvidia.volumes.needed="nvidia_driver"

RUN echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

RUN apt-get update && apt-get install -y --allow-downgrades --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         vim \
         ca-certificates \
         libnccl2=2.2.12-1+cuda9.2 \
         libnccl-dev=2.2.12-1+cuda9.2 \
         python-qt4 \
         libjpeg-dev \
	 zip \
	 unzip \
         libpng-dev &&\
     rm -rf /var/lib/apt/lists/*


ENV PYTHON_VERSION=3.6
RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda && \
     rm ~/miniconda.sh && \
    /opt/conda/bin/conda install conda-build


RUN useradd -m -s /bin/bash -u 1000 fastai
USER fastai

WORKDIR /home/fastai

RUN git clone https://github.com/fastai/fastai.git
RUN cd fastai && /opt/conda/bin/conda env create
RUN /opt/conda/bin/conda clean -ya

ENV PATH /opt/conda/envs/fastai/bin:$PATH
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV USER fastai

CMD source activate fastai
CMD source ~/.bashrc


RUN mkdir /home/fastai/data
WORKDIR /home/fastai/data
RUN ln -s /home/fastai/data/ /home/fastai/fastai/courses/dl1/
RUN ln -s /home/fastai/data/ /home/fastai/fastai/courses/dl2/
USER root
RUN ln -s /home/fastai/data /
USER fastai

RUN curl http://files.fast.ai/data/dogscats.zip --output dogscats.zip
RUN unzip -d . dogscats.zip
RUN rm dogscats.zip

RUN mkdir /home/fastai/data/pascal
WORKDIR /home/fastai/data/pascal
RUN curl -OL http://pjreddie.com/media/files/VOCtrainval_06-Nov-2007.tar
RUN curl -OL https://storage.googleapis.com/coco-dataset/external/PASCAL_VOC.zip
RUN tar -xf VOCtrainval_06-Nov-2007.tar
RUN unzip PASCAL_VOC.zip
RUN mv PASCAL_VOC/*.json .
RUN rmdir PASCAL_VOC

RUN ls -la /home/fastai/fastai/courses/dl1/data/

ENV PATH /opt/conda/bin:$PATH
WORKDIR /home/fastai/fastai

ENV PATH /home/fastai/.conda/envs/fastai/bin:$PATH
ENV CONDA_PREFIX /home/fastai/.conda/envs/fastai
ENV CONDA_EXE /opt/conda/bin/conda
ENV CONDA_PYTHON_EXE /opt/conda/bin/python
ENV CONDA_DEFAULT_ENV fastai

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--no-browser"]
