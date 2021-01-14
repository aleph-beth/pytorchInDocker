FROM nvidia/cuda:11.0-base-ubuntu20.04

# Install some basic utilities
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
 && rm -rf /var/lib/apt/lists/*

# Create a working directory
RUN mkdir /app
WORKDIR /app

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user \
 && chown -R user:user /app
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
USER user

# All users can use /home/user as their home directory
ENV HOME=/home/user
RUN chmod 777 /home/user

# Install Miniconda and Python 3.8
ENV CONDA_AUTO_UPDATE_CONDA=false
ENV PATH=/home/user/miniconda/bin:$PATH
RUN curl -sLo ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-py38_4.8.3-Linux-x86_64.sh \
 && chmod +x ~/miniconda.sh \
 && ~/miniconda.sh -b -p ~/miniconda \
 && rm ~/miniconda.sh \
 && conda install -y python==3.8.3 \
 && conda clean -ya

# CUDA 11.0-specific steps
RUN conda install -y -c pytorch \
    cudatoolkit=11.0.221 \
    "pytorch=1.7.0=py3.8_cuda11.0.221_cudnn8.0.3_0" \
    "torchvision=0.8.1=py38_cu110" \
 && conda clean -ya

RUN pip install  torch-scatter -f https://pytorch-geometric.com/whl/torch-1.7.0+cu110.html \
	pip install  torch-sparse -f https://pytorch-geometric.com/whl/torch-1.7.0+cu110.html \
	pip install  torch-cluster -f https://pytorch-geometric.com/whl/torch-1.7.0+cu110.html \
	pip install  torch-spline-conv -f https://pytorch-geometric.com/whl/torch-1.7.0+cu110.html \
	pip install  torch-geometric

RUN pip install jupyter \
	pip install jupyterlab
	
# Set the default command to python3
EXPOSE 8888
CMD ["jupyter-lab", "--ip=*"]