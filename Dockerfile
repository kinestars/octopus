ARG CUDA_BASE_VERSION=10.1
ARG UBUNTU_VERSION=18.04
ARG CUDNN_VERSION=7.6.5

# use CUDA + OpenGL
FROM nvidia/cudagl:${CUDA_BASE_VERSION}-devel-ubuntu${UBUNTU_VERSION}
MAINTAINER Domhnall Boyle (domhnallboyle@gmail.com)

# set environment variables
ENV CUDA_BASE_VERSION=${CUDA_BASE_VERSION}
ENV CUDNN_VERSION=${CUDNN_VERSION}
ENV TENSORFLOW_VERSION=${TENSORFLOW_VERSION}

# install apt dependencies
RUN apt-get update && apt-get install -y \
	python \
	python-pip \
	git \
	vim \
	wget

# install newest cmake version
RUN apt-get purge cmake && cd ~ && wget https://github.com/Kitware/CMake/releases/download/v3.14.5/cmake-3.14.5.tar.gz && tar -xvf cmake-3.14.5.tar.gz
RUN cd ~/cmake-3.14.5 && ./bootstrap && make && make install

ENV TENSORFLOW_VERSION=2.1.0
ENV CUDNN_VERSION=7.6.5.32
ENV CUDA_BASE_VERSION=10.1
# setting up cudnn
RUN apt-get install -y --no-install-recommends \             
	libcudnn7=$(echo $CUDNN_VERSION)-1+cuda$(echo $CUDA_BASE_VERSION) \             
	libcudnn7-dev=$(echo $CUDNN_VERSION)-1+cuda$(echo $CUDA_BASE_VERSION) 

# RUN apt-get install -y --no-install-recommends \             
# 	libcudnn7 \             
# 	libcudnn7-dev

RUN apt-mark hold libcudnn7 && rm -rf /var/lib/apt/lists/*

ENV PATH /opt/conda/bin:$PATH
ARG PYTHON_VERSION=3.7
RUN wget -O ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && chmod +x ~/miniconda.sh \
    && ~/miniconda.sh -b -p /opt/conda \
    && /opt/conda/bin/conda config --set repodata_threads 4 \
    && /opt/conda/bin/conda config --add channels huggingface \
    && /opt/conda/bin/conda config --add channels nvidia \
    && /opt/conda/bin/conda config --add channels pytorch \
    && /opt/conda/bin/conda config --append channels conda-forge \
    && rm ~/miniconda.sh

RUN /opt/conda/bin/conda install -y \
    python=${PYTHON_VERSION} \
    tensorflow=2.1 \
    tensorflow-gpu=2.1 \
    opencv \
    keras
RUN pip install chumpy 'h5py<3.0.0'
COPY dirt /dirt/
RUN cd /dirt/ && pip install -e .
COPY requirements.txt .
RUN pip install -r requirements.txt
# install dirt
ENV CUDAFLAGS='-DNDEBUG=1'
